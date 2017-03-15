SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
------------------------------------------------------------------------------------------------------------------------------------------
--	Description: Copies tables related to email preferences to DaxImports from Magento(read only instance, as defined by the link server)
------------------------------------------------------------------------------------------------------------------------------------------
--	Issue#	Date		Modified By		Details
------------------------------------------------------------------------------------------------------------------------------------------
--	US550	06/26/2015	BryantJ			Initial.
--	US2656	11/10/2016	BryantJ			Added new column for store id to epc_preference
------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[P_Import_Email_Preference]
	@Start_Date DATETIME = '',
	@End_Date DATETIME = '',
	@Copy_All BIT = 0
AS
BEGIN
	/* Tables Copied:
		epc_preference
		epc_preference_option
		epc_preference_history
		epc_email_status
		epc_survey
		epc_survey_question

	Not Copied by this(they are reference tables that are rarely updated):
		epc_reason
		epc_registration_source
		epc_frequency
		epc_option
	*/

	SET NOCOUNT ON

	DECLARE @query NVARCHAR(MAX),
		@count INT
		
	-- Error Variables
	DECLARE @error_description VARCHAR(MAX),
		@sp_name VARCHAR(MAX) = OBJECT_NAME(@@PROCID),
		@error_number INT,
		@error_line INT,
		@error_state VARCHAR(MAX),
		@error_severity VARCHAR(MAX),
		@user_name VARCHAR(MAX),
		@error_message VARCHAR(MAX)

	DECLARE @temp_summary TABLE
		(Change_Name SYSNAME)

	IF OBJECT_ID('tempdb.dbo.#epc_preference', 'U') IS NOT NULL 
		DROP TABLE #epc_preference
	CREATE TABLE #epc_preference
		(preference_id INT PRIMARY KEY,
		email VARCHAR(255),
		created_date DATETIME,
		last_updated_date DATETIME,
		snooze_end_date DATETIME,
		registration_source_id INT,
		snooze_start_date DATETIME,
		guest_key VARCHAR(32),
		store_id SMALLINT		--	US2656
		)

	IF OBJECT_ID('tempdb.dbo.#epc_preference_option', 'U') IS NOT NULL 
		DROP TABLE #epc_preference_option
	CREATE TABLE #epc_preference_option
		(preference_option_id INT PRIMARY KEY,
		preference_id INT,
		option_id INT,
		frequency_id INT 
		)

	IF OBJECT_ID('tempdb.dbo.#epc_preference_history', 'U') IS NOT NULL 
		DROP TABLE #epc_preference_history
	CREATE TABLE #epc_preference_history
		(preference_history_id INT PRIMARY KEY,
		preference_id INT,
		change_date DATETIME,
		change_type VARCHAR(255),
		change_source VARCHAR(MAX),
		value_old VARCHAR(MAX),
		value_new VARCHAR(MAX)
		)

	IF OBJECT_ID('tempdb.dbo.#epc_email_status', 'U') IS NOT NULL 
		DROP TABLE #epc_email_status
	CREATE TABLE #epc_email_status
		(recipient_failure_id INT PRIMARY KEY,
		email VARCHAR(255),
		created_date DATETIME,
		transaction_date DATETIME,
		category VARCHAR(255),
		type_number INT,
		reason VARCHAR(MAX),
		[user_id] VARCHAR(250)
		)

	IF OBJECT_ID('tempdb.dbo.#epc_survey', 'U') IS NOT NULL 
		DROP TABLE #epc_survey
	CREATE TABLE #epc_survey
		(survey_id INT PRIMARY KEY,
		preference_id INT,
		created_date DATETIME,
		feedback VARCHAR(MAX)
		)

	IF OBJECT_ID('tempdb.dbo.#epc_survey_question', 'U') IS NOT NULL 
		DROP TABLE #epc_survey_question
	CREATE TABLE #epc_survey_question
		(survey_question_id INT PRIMARY KEY,
		survey_id INT,
		reason_id INT
		)

	BEGIN TRY
		-- Validation
		IF @Copy_All = 0
		BEGIN
			IF ISNULL(@End_Date,'') = ''
			BEGIN
				SET @End_Date = GETDATE()
			END
		END


		-------------------------------------------------------------------------------------------------------
		-- Import Preferences
		-------------------------------------------------------------------------------------------------------
		BEGIN TRY
			-- Using dynamic sql here because we can't pass in variables into OPENQUERY
			SET @query =
				'INSERT INTO #epc_preference
					(preference_id,
					email,
					created_date,
					last_updated_date,
					snooze_end_date,
					registration_source_id,
					snooze_start_date,
					guest_key,
					store_id		--	US2656
					)
				SELECT preference_id,
					email,
					created_date,
					last_updated_date,
					snooze_end_date,
					registration_source_id,
					snooze_start_date,
					guest_key,
					store_id		--	US2656
				FROM OPENQUERY(MAGENTO, 
					''SELECT preference_id,
						email,
						created_date,
						last_updated_date AS last_updated_date,
						snooze_end_date,
						registration_source_id,
						snooze_start_date,
						guest_key,
						store_id		--	US2656
					FROM epc_preference
					WHERE ' + CONVERT(VARCHAR,@Copy_All) + ' = 1 
						OR last_updated_date BETWEEN ''''' + CONVERT(VARCHAR,@Start_Date,21) + ''''' AND ''''' + CONVERT(VARCHAR,@End_Date,21) + ''''' 
						OR created_date BETWEEN ''''' + CONVERT(VARCHAR,@Start_Date,21) + ''''' AND ''''' + CONVERT(VARCHAR,@End_Date,21) + ''''' 
					'')
					;'

			EXEC sp_executesql 
				@stmt = @query


			SET @query =
				'INSERT INTO #epc_preference_option
					(preference_option_id,
					preference_id,
					option_id,
					frequency_id
					)
				SELECT preference_option_id,
					preference_id,
					option_id,
					frequency_id
				FROM OPENQUERY(MAGENTO,
					''SELECT preference_option_id,
						epo.preference_id,
						option_id,
						frequency_id
					FROM epc_preference_option epo
						INNER JOIN epc_preference ep
							ON epo.preference_id = ep.preference_id
					WHERE ' + CONVERT(VARCHAR,@Copy_All) + ' = 1 
						OR last_updated_date BETWEEN ''''' + CONVERT(VARCHAR,@Start_Date,21) + ''''' AND ''''' + CONVERT(VARCHAR,@End_Date,21) + ''''' 
						OR created_date BETWEEN ''''' + CONVERT(VARCHAR,@Start_Date,21) + ''''' AND ''''' + CONVERT(VARCHAR,@End_Date,21) + ''''' 
				'')
				;'

			EXEC sp_executesql 
				@stmt = @query

			-- There can be updates in this data, so using a merge instead of insert
			BEGIN TRANSACTION
				-- The @Copy_All flag is used to determine if, rather than getting a smaller data set, you want the full table.
				--	So if it's selected, this will delete everything in the local table and record the counts
				IF @Copy_All = 1
				BEGIN
					SELECT @count = COUNT(*) FROM epc_preference
					TRUNCATE TABLE epc_preference

					INSERT INTO Import_Log (Operation_Date, Source, Table_Name, Operation, Operation_Count, After_Count)
					SELECT GETDATE(), @sp_name, 'epc_preference', 'DELETED', @count AS Operation_Count, (SELECT COUNT(*) FROM epc_preference) AS Total_Count

					SELECT @count = COUNT(*) FROM epc_preference_option
					TRUNCATE TABLE epc_preference_option

					INSERT INTO Import_Log (Operation_Date, Source, Table_Name, Operation, Operation_Count, After_Count)
					SELECT GETDATE(), @sp_name, 'epc_preference_option', 'DELETED', @count AS Operation_Count, (SELECT COUNT(*) FROM epc_preference_option)
				END

				MERGE epc_preference AS target_table
				USING (SELECT preference_id, email, created_date, last_updated_date, snooze_end_date, registration_source_id, snooze_start_date, guest_key, store_id
						FROM #epc_preference ) AS source_table (preference_id, email, created_date, last_updated_date, snooze_end_date, 
																registration_source_id, snooze_start_date, guest_key, store_id)
					ON (target_table.preference_id = source_table.preference_id)
				WHEN MATCHED 
					THEN UPDATE SET target_table.email = source_table.email,
									target_table.created_date = source_table.created_date,
									target_table.last_updated_date = source_table.last_updated_date,
									target_table.snooze_end_date = source_table.snooze_end_date,
									target_table.registration_source_id = source_table.registration_source_id,
									target_table.snooze_start_date = source_table.snooze_start_date,
									target_table.guest_key = source_table.guest_key,
									target_table.store_id = source_table.store_id		--	US2656
				WHEN NOT MATCHED BY TARGET		--	US2656
					THEN INSERT (preference_id, email, created_date, last_updated_date, snooze_end_date, registration_source_id, snooze_start_date, guest_key, store_id)
						 VALUES (preference_id, email, created_date, last_updated_date, snooze_end_date, registration_source_id, snooze_start_date, guest_key, store_id)
				OUTPUT $ACTION
					INTO @temp_summary;

				INSERT INTO Import_Log (Operation_Date, Source, Table_Name, Operation, Operation_Count, After_Count)
				SELECT GETDATE(), @sp_name, 'epc_preference', Change_Name, COUNT(*) Total, (SELECT COUNT(*) FROM epc_preference) AS After_Count
				FROM @temp_summary
				GROUP BY Change_Name

				DELETE FROM @temp_summary


				MERGE epc_preference_option AS target_table
				USING (SELECT preference_option_id, preference_id, option_id, frequency_id
						FROM #epc_preference_option ) AS source_table (preference_option_id, preference_id, option_id, frequency_id)
					ON (target_table.preference_option_id = source_table.preference_option_id)
				WHEN MATCHED 
					THEN UPDATE SET target_table.preference_id = source_table.preference_id,
									target_table.option_id = source_table.option_id,
									target_table.frequency_id = source_table.frequency_id
				WHEN NOT MATCHED BY TARGET
					THEN INSERT (preference_option_id, preference_id, option_id, frequency_id)
						 VALUES (preference_option_id, preference_id, option_id, frequency_id)
				OUTPUT $ACTION
					INTO @temp_summary;

				INSERT INTO Import_Log (Operation_Date, Source, Table_Name, Operation, Operation_Count, After_Count)
				SELECT GETDATE(), @sp_name, 'epc_preference_option', Change_Name, COUNT(*) Total, (SELECT COUNT(*) FROM epc_preference_option) AS After_Count
				FROM @temp_summary
				GROUP BY Change_Name

				DELETE FROM @temp_summary

			COMMIT TRANSACTION

		END TRY
		BEGIN CATCH
			SELECT
				@error_number = ERROR_NUMBER(),
				@error_severity = ERROR_SEVERITY(),
				@error_state = ERROR_STATE(),
				@error_line = ERROR_LINE(),
				@error_message = ERROR_MESSAGE()

			SELECT @error_description = ISNULL(@error_description,'')
				+ 'Error Number: ' + CONVERT(VARCHAR,@error_number) 
				+ ', Line: ' + CONVERT(VARCHAR,@error_line)
				+ ', Error Message: "' + @error_message + '"' + CHAR(13) + CHAR(13) 
		
			-- Close open transactions, only use if using transactions
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRANSACTION
			END

		END CATCH
		-------------------------------------------------------------------------------------------------------
		-- END Import Preferences
		-------------------------------------------------------------------------------------------------------



		-------------------------------------------------------------------------------------------------------
		-- Import Surveys
		-------------------------------------------------------------------------------------------------------
		BEGIN TRY
			SET @query =
				'INSERT INTO #epc_survey
					(survey_id,
					preference_id,
					created_date,
					feedback
					)
				SELECT survey_id,
					preference_id,
					created_date,
					feedback
				FROM OPENQUERY(MAGENTO, 
					''SELECT survey_id,
						preference_id,
						created_date,
						feedback
					FROM epc_survey
					WHERE ' + CONVERT(VARCHAR,@Copy_All) + ' = 1 
						OR created_date BETWEEN ''''' + CONVERT(VARCHAR,@Start_Date,21) + ''''' AND ''''' + CONVERT(VARCHAR,@End_Date,21) + ''''' 
					'')
					;'

			EXEC sp_executesql 
				@stmt = @query


			SET @query =
				'INSERT INTO #epc_survey_question
					(survey_question_id,
					survey_id,
					reason_id
					)
				SELECT survey_question_id,
					survey_id,
					reason_id
				FROM OPENQUERY(MAGENTO,
					''SELECT survey_question_id,
						esq.survey_id,
						reason_id
					FROM epc_survey_question esq
						INNER JOIN epc_survey es
							ON esq.survey_id = es.survey_id
						WHERE ' + CONVERT(VARCHAR,@Copy_All) + ' = 1 
							OR es.created_date BETWEEN ''''' + CONVERT(VARCHAR,@Start_Date,21) + ''''' AND ''''' + CONVERT(VARCHAR,@End_Date,21) + ''''' 
					'')
					;'

			EXEC sp_executesql 
				@stmt = @query

			-- There can be updates here, so using a merge instead of insert
			BEGIN TRANSACTION
				IF @Copy_All = 1
				BEGIN
					SELECT @count = COUNT(*) FROM epc_survey
					TRUNCATE TABLE epc_survey

					INSERT INTO Import_Log (Operation_Date, Source, Table_Name, Operation, Operation_Count, After_Count)
					SELECT GETDATE(), @sp_name, 'epc_survey', 'DELETED', @count AS Operation_Count, (SELECT COUNT(*) FROM epc_survey)

					SELECT @count = COUNT(*) FROM epc_survey_question
					TRUNCATE TABLE epc_survey_question

					INSERT INTO Import_Log (Operation_Date, Source, Table_Name, Operation, Operation_Count, After_Count)
					SELECT GETDATE(), @sp_name, 'epc_survey_question', 'DELETED', @count AS Operation_Count, (SELECT COUNT(*) FROM epc_survey_question)
				END

				INSERT INTO epc_survey
					(survey_id,
					preference_id,
					created_date,
					feedback
					)
				SELECT survey_id,
					preference_id,
					created_date,
					feedback
				FROM #epc_survey tes
				WHERE NOT EXISTS (SELECT 1					-- Verifying that this PK doesn't already exist in the table
									FROM epc_survey es
									WHERE tes.survey_id = es.survey_id
									)
				INSERT INTO Import_Log (Operation_Date, Source, Table_Name, Operation, Operation_Count, After_Count)
				SELECT GETDATE(), @sp_name, 'epc_survey', 'INSERTED', @@ROWCOUNT, (SELECT COUNT(*) FROM epc_survey) AS After_Count


				INSERT INTO epc_survey_question
					(survey_question_id,
					survey_id,
					reason_id
					)
				SELECT survey_question_id,
					survey_id,
					reason_id
				FROM #epc_survey_question tesq
				WHERE NOT EXISTS (SELECT 1					-- Verifying that this PK doesn't already exist in the table
									FROM epc_survey_question esq
									WHERE tesq.survey_question_id = esq.survey_question_id
									)
				INSERT INTO Import_Log (Operation_Date, Source, Table_Name, Operation, Operation_Count, After_Count)
				SELECT GETDATE(), @sp_name, 'epc_survey_question', 'INSERTED', @@ROWCOUNT, (SELECT COUNT(*) FROM epc_survey_question) AS After_Count
			COMMIT TRANSACTION

		END TRY
		BEGIN CATCH
			SELECT
				@error_number = ERROR_NUMBER(),
				@error_severity = ERROR_SEVERITY(),
				@error_state = ERROR_STATE(),
				@error_line = ERROR_LINE(),
				@error_message = ERROR_MESSAGE()

			SELECT @error_description = ISNULL(@error_description,'')
				+ 'Error Number: ' + CONVERT(VARCHAR,@error_number) 
				+ ', Line: ' + CONVERT(VARCHAR,@error_line)
				+ ', Error Message: "' + @error_message + '"' + CHAR(13) + CHAR(13) 
		
			-- Close open transactions, only use if using transactions
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRANSACTION
			END

		END CATCH
		-------------------------------------------------------------------------------------------------------
		-- END Import Surveys
		-------------------------------------------------------------------------------------------------------


		-------------------------------------------------------------------------------------------------------
		-- Import Preference History
		-------------------------------------------------------------------------------------------------------
		BEGIN TRY
			SET @query =
				'INSERT INTO #epc_preference_history
					(preference_history_id,
					preference_id,
					change_date,
					change_type,
					change_source,
					value_old,
					value_new
					)
				SELECT preference_history_id,
					preference_id,
					change_date,
					change_type,
					change_source,
					value_old,
					value_new
				FROM OPENQUERY(MAGENTO, 
					''SELECT preference_history_id,
						preference_id,
						change_date,
						change_type,
						change_source,
						value_old,
						value_new
					FROM epc_preference_history
					WHERE ' + CONVERT(VARCHAR,@Copy_All) + ' = 1 
						OR change_date BETWEEN ''''' + CONVERT(VARCHAR,@Start_Date,21) + ''''' AND ''''' + CONVERT(VARCHAR,@End_Date,21) + ''''' 
					'')
					;'

			EXEC sp_executesql 
				@stmt = @query


			-- There can be updates here, so using a merge instead of insert
			BEGIN TRANSACTION
				IF @Copy_All = 1
				BEGIN
					SELECT @count = COUNT(*) FROM epc_preference_history
					TRUNCATE TABLE epc_preference_history

					INSERT INTO Import_Log (Operation_Date, Source, Table_Name, Operation, Operation_Count, After_Count)
					SELECT GETDATE(), @sp_name, 'epc_preference_history', 'DELETED', @count AS Operation_Count, (SELECT COUNT(*) FROM epc_preference_history)
				END

				INSERT INTO epc_preference_history
					(preference_history_id,
					preference_id,
					change_date,
					change_type,
					change_source,
					value_old,
					value_new
					)
				SELECT preference_history_id,
					preference_id,
					change_date,
					change_type,
					change_source,
					value_old,
					value_new
				FROM #epc_preference_history teph
				WHERE NOT EXISTS (SELECT 1					-- Verifying that this PK doesn't already exist in the table
									FROM epc_preference_history eph
									WHERE teph.preference_history_id = eph.preference_history_id
									)
				INSERT INTO Import_Log (Operation_Date, Source, Table_Name, Operation, Operation_Count, After_Count)
				SELECT GETDATE(), @sp_name, 'epc_preference_history', 'INSERTED', @@ROWCOUNT, (SELECT COUNT(*) FROM epc_preference_history) AS After_Count
			COMMIT TRANSACTION

		END TRY
		BEGIN CATCH
			SELECT
				@error_number = ERROR_NUMBER(),
				@error_severity = ERROR_SEVERITY(),
				@error_state = ERROR_STATE(),
				@error_line = ERROR_LINE(),
				@error_message = ERROR_MESSAGE()

			SELECT @error_description = ISNULL(@error_description,'')
				+ 'Error Number: ' + CONVERT(VARCHAR,@error_number) 
				+ ', Line: ' + CONVERT(VARCHAR,@error_line)
				+ ', Error Message: "' + @error_message + '"' + CHAR(13) + CHAR(13) 
		
			-- Close open transactions, only use if using transactions
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRANSACTION
			END

		END CATCH
		-------------------------------------------------------------------------------------------------------
		-- END Import Preference History
		-------------------------------------------------------------------------------------------------------


		-------------------------------------------------------------------------------------------------------
		-- Import Email Status
		-------------------------------------------------------------------------------------------------------
		BEGIN TRY
			SET @query =
				'INSERT INTO #epc_email_status
					(
					recipient_failure_id,
					email,
					created_date,
					transaction_date,
					category,
					type_number,
					reason,
					[user_id]
					)
				SELECT 
					recipient_failure_id,
					email,
					created_date,
					transaction_date,
					category,
					type_number,
					reason,
					[user_id]
				FROM OPENQUERY(MAGENTO, 
					''SELECT recipient_failure_id,
						email,
						created_date,
						transaction_date,
						category,
						type_number,
						reason,
						''''user_id''''
					FROM epc_email_status
					WHERE ' + CONVERT(VARCHAR,@Copy_All) + ' = 1 
						OR created_date BETWEEN ''''' + CONVERT(VARCHAR,@Start_Date,21) + ''''' AND ''''' + CONVERT(VARCHAR,@End_Date,21) + ''''' 
					'')
					;'

			EXEC sp_executesql 
				@stmt = @query

			-- There can be updates here, so using a merge instead of insert
			BEGIN TRANSACTION
				IF @Copy_All = 1
				BEGIN
					SELECT @count = COUNT(*) FROM epc_email_status
					TRUNCATE TABLE epc_email_status

					INSERT INTO Import_Log (Operation_Date, Source, Table_Name, Operation, Operation_Count, After_Count)
					SELECT GETDATE(), @sp_name, 'epc_email_status', 'DELETED', @count AS Operation_Count, (SELECT COUNT(*) FROM epc_email_status)
				END

				INSERT INTO epc_email_status
					(recipient_failure_id,
					email,
					created_date,
					transaction_date,
					category,
					type_number,
					reason,
					[user_id]
					)
				SELECT recipient_failure_id,
					email,
					created_date,
					transaction_date,
					category,
					type_number,
					reason,
					[user_id]
				FROM #epc_email_status tes
				WHERE NOT EXISTS (SELECT 1					-- Verifying that this PK doesn't already exist in the table
									FROM epc_email_status es
									WHERE tes.recipient_failure_id = es.recipient_failure_id
									)
				INSERT INTO Import_Log (Operation_Date, Source, Table_Name, Operation, Operation_Count, After_Count)
				SELECT GETDATE(), @sp_name, 'epc_email_status', 'INSERTED', @@ROWCOUNT, (SELECT COUNT(*) FROM epc_email_status) AS After_Count
			COMMIT TRANSACTION

		END TRY
		BEGIN CATCH
			SELECT
				@error_number = ERROR_NUMBER(),
				@error_severity = ERROR_SEVERITY(),
				@error_state = ERROR_STATE(),
				@error_line = ERROR_LINE(),
				@error_message = ERROR_MESSAGE()

			SELECT @error_description = ISNULL(@error_description,'')
				+ 'Error Number: ' + CONVERT(VARCHAR,@error_number) 
				+ ', Line: ' + CONVERT(VARCHAR,@error_line)
				+ ', Error Message: "' + @error_message + '"' + CHAR(13) + CHAR(13) 
		
			-- Close open transactions, only use if using transactions
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRANSACTION
			END

		END CATCH
		-------------------------------------------------------------------------------------------------------
		-- END Import Email Statuses
		-------------------------------------------------------------------------------------------------------


		-- If any step failed, fail the SP here.
		IF @error_description IS NOT NULL
		BEGIN
			RAISERROR(@error_description,@error_severity, @error_state)
		END

	END TRY

	BEGIN CATCH
	    SELECT
			@error_number = ERROR_NUMBER(),
			@error_severity = ERROR_SEVERITY(),
			@error_state = ERROR_STATE(),
			@error_line = ERROR_LINE(),
			@error_message = ERROR_MESSAGE(),
			@user_name = SYSTEM_USER

		SELECT @error_description = '[' + @sp_name + '] has failed.' + CHAR(13)
			+ 'Error Number: ' + CONVERT(VARCHAR,@error_number) 
			+ ', Line: ' + CONVERT(VARCHAR,@error_line)
			+ ', User: "' + @user_name + '"'
			+ ', Error Message: "' + @error_message + '"' + CHAR(13) + CHAR(13)
			+ ISNULL(@error_description,'')

		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION
		END

		RAISERROR(@error_description,@error_severity, @error_state)

	END CATCH
	
	SET NOCOUNT OFF
END
GO
