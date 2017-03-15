SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
------------------------------------------------------------------------------------------------------------------------------------------
-- Description: Copies the Upsell files to their final destinations if all of them are in the staging directory
------------------------------------------------------------------------------------------------------------------------------------------
-- Issue#	Date		Modified By		Details
------------------------------------------------------------------------------------------------------------------------------------------
-- US2269	07/25/2016	BryantJ			Initial
------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Magento].[P_Upsell_Move_Files]
	@Source_Path VARCHAR(4000),			-- eg. \\ttcwebsvc02\ProdData\Dm2M_Upsell_Gathering_Area\
	@Destination_Path VARCHAR(4000),	-- eg. \\ttcwebsvc02\ProdData\
	@Recipients VARCHAR(4000)			-- eg. ~DLApplicationSupport@teachco.com;~dldatamartalerts@TEACHCO.com
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @source_full_path VARCHAR(4000),
		@destination_full_path VARCHAR(4000),
		@is_exists INT,
		@sql VARCHAR(4000),
		@xp_cmdshell_status INT,	-- 0 = success, 1 = fail
		@id INT,
		@id_rollback INT,
		@rollback_source_full_path VARCHAR(4000),
		@rollback_destination_full_path VARCHAR(4000)
	
	DECLARE @File_Statuses TABLE
		(ID INT IDENTITY(1,1) PRIMARY KEY,
		Name VARCHAR(128),
		[Filename] VARCHAR(400),
		Source_Full_Path VARCHAR(4000),
		Destination_Path_Suffix VARCHAR(400),
		Destination_Full_Path VARCHAR(4000),
		File_Exists_Status INT DEFAULT(0),
		Copy_Worked_Status INT
		)

	INSERT INTO @File_Statuses
		(Name, [Filename], Destination_Path_Suffix)
	VALUES
		('Cart','cart.csv','Dm2M_Upsell_Cart\'),
		('Customer List','customer_list.csv','Dm2M_Upsell_Customer_List\'),
		('Just For You','just_for_you.csv','Dm2M_Upsell_Just_For_You\'),
		('List','list.csv','Dm2M_Upsell_List\'),
		('My Digital Library','my_digital_library.csv','Dm2M_Upsell_My_Digital_Library\'),
		('Product Detail Page','product_detail_page.csv','Dm2M_Upsell_Product_Detail_Page\'),
		('You May Like','you_may_like.csv','Dm2M_Upsell_You_May_Like\')

	-- Email 
	DECLARE 
		@subject VARCHAR(MAX),
		@xml NVARCHAR(MAX) = '',
		@body NVARCHAR(MAX) = ''

	-- Error Variables
	DECLARE @error_description VARCHAR(MAX),
		@sp_name VARCHAR(MAX),
		@error_number INT,
		@error_line INT,
		@error_state VARCHAR(MAX),
		@error_severity VARCHAR(MAX),
		@user_name VARCHAR(MAX),
		@error_message VARCHAR(MAX)

	DECLARE @sql_results TABLE
		(command_output VARCHAR(4000))

	DECLARE @sql_results_rollback TABLE
		(command_output VARCHAR(4000))
		
	BEGIN TRY
		-- prepping the full paths
		UPDATE fs
		SET Destination_Full_Path = @Destination_Path + Destination_Path_Suffix + [Filename],
			Source_Full_Path = @Source_Path + [Filename]
		FROM @File_Statuses fs

		-- checking to see if the files exist
		UPDATE fs
		SET File_Exists_Status = Admin.dbo.F_File_Exists(Source_Full_Path)
		FROM @File_Statuses fs

		-- If all files exist, copy them to their destinations
		IF NOT EXISTS (SELECT 1 FROM @File_Statuses WHERE ISNULL(File_Exists_Status,0) = 0)
		BEGIN
			BEGIN TRY
				WHILE EXISTS (SELECT 1 FROM @File_Statuses WHERE Copy_Worked_Status IS NULL)
				BEGIN 
					SELECT TOP 1 @id = id,
						@source_full_path = Source_Full_Path,
						@destination_full_path = Destination_Full_Path
					FROM @File_Statuses 
					WHERE Copy_Worked_Status IS NULL

					SET @sql = N'MOVE /Y "' + @source_full_path + '" "' + @destination_full_path + '"'

					-- execute the move command. collect results and status
					INSERT INTO @sql_results
						(command_output)
					EXEC @xp_cmdshell_status = master..xp_cmdshell @sql

					-- I don't like the meaning of the flag output from cmdshell. reversing to make sense
					SET @xp_cmdshell_status = CASE @xp_cmdshell_status
												WHEN 0 THEN 1	-- success
												WHEN 1 THEN 0	-- failure
												ELSE @xp_cmdshell_status
											END

					-- update tracking table with status
					UPDATE fs
					SET Copy_Worked_Status = @xp_cmdshell_status
					FROM @File_Statuses fs
					WHERE ID = @id

					-- if there is a failure
					IF @xp_cmdshell_status != 1
					BEGIN
						-- Move previously successful files back to source locations
						WHILE EXISTS (SELECT 1 FROM @File_Statuses WHERE Copy_Worked_Status = 1)
						BEGIN
							SELECT TOP 1 @id_rollback = id,
								@rollback_source_full_path = Source_Full_Path,
								@rollback_destination_full_path = Destination_Full_Path
							FROM @File_Statuses 
							WHERE Copy_Worked_Status = 1

							IF @id_rollback IS NOT NULL
							BEGIN
								SET @sql = N'MOVE /Y "' + @rollback_destination_full_path + '" "' + @rollback_source_full_path + '"'

								-- execute the move command. collect results and status
								INSERT INTO @sql_results_rollback
									(command_output)
								EXEC master..xp_cmdshell @sql

								UPDATE fs
								SET Copy_Worked_Status = 2			-- rolled back
								FROM @File_Statuses fs
								WHERE ID = @id_rollback
							END	--IF @id_rollback IS NOT NULL

							SET @id_rollback = NULL
						END	-- WHILE EXISTS (SELECT 1 FROM @File_Statuses WHERE Copy_Worked_Status = 1)

						-- Prep email indicating a file copy failure happened
						SELECT @subject = 'Upsell Export - File copy to final destination failed - ' + @@SERVERNAME

						-- Structured this way so you can have multipled tables worth of data chained in a row with minimum modification.
						-- get the error generated by this file move
						SELECT @xml =
									CAST( (
										SELECT td = command_output
										FROM (	SELECT	command_output										
												FROM @sql_results
												WHERE command_output IS NOT NULL
											) AS d
									FOR XML PATH('tr'), TYPE ) AS VARCHAR(MAX))

						SET @body += '<H3>Error Generated</H3>
									<table border = 1> 
									<tr>'
									+ '<th> Move Command Output </th> '
									+ '</tr>'
									+ REPLACE( REPLACE( ISNULL(@xml,''), '&lt;', '<'), '&gt;', '>')
									+ '</table>'

						-- get status of each move
						SELECT @xml =
									CAST( (
										SELECT td = Upsell_Name + '</td><td>'
													+ Source_Full_Path + '</td><td>'
													+ Destination_Full_Path + '</td><td>'
													+ File_Exist_Status
										FROM (	SELECT	Name AS Upsell_Name,
														Source_Full_Path,
														Destination_Full_Path,
														CASE Copy_Worked_Status
															WHEN 0 THEN 'Failed'
															WHEN 1 THEN 'Successfully copied to destination' -- this shouldn't happen, they should rollback
															WHEN 2 THEN 'Copied back to Source'
															ELSE 'Did Not Attempt'
														END AS File_Exist_Status											
												FROM @File_Statuses
											) AS d
										ORDER BY d.Upsell_Name
									FOR XML PATH('tr'), TYPE ) AS VARCHAR(MAX))

						SET @body += '<H3>Files Missing</H3>
									<table border = 1> 
									<tr>'
									+ '<th> Upsell Name </th> '
									+ '<th> Source File Path </th> '
									+ '<th> Destination File Path </th> '
									+ '<th> File Copy Status </th> '
									+ '</tr>'
									+ REPLACE( REPLACE( ISNULL(@xml,''), '&lt;', '<'), '&gt;', '>')
									+ '</table>'
						-- End converting query results to HTML section, you can copy this section multiple times for multiple sets

						SET @body = '<body><html>' + @body + '</body></html>'

						-- Generate an error so that it doesn't continue to try to process files
						RAISERROR('An error occured attempting to copy the files to their desinations', 16, 1)
					END		-- IF @xp_cmdshell_status != 1

				END --WHILE EXISTS (SELECT 1 FROM @File_Statuses WHERE Copy_Worked_Status IS NULL)
			
			END TRY
			BEGIN CATCH
				SELECT
					@error_number = ERROR_NUMBER(),
					@error_severity = ERROR_SEVERITY(),
					@error_state = ERROR_STATE(),
					@sp_name = ISNULL(OBJECT_NAME(@@PROCID),''),
					@error_line = ERROR_LINE(),
					@error_message = ERROR_MESSAGE(),
					@user_name = SYSTEM_USER

				SELECT @error_description = ISNULL(@error_description,'') + CHAR(13) + '[' + @sp_name + '] has failed.' + CHAR(13)
					+ 'Error Number: ' + CONVERT(VARCHAR,@error_number) 
					+ ', Line: ' + CONVERT(VARCHAR,@error_line)
					+ ', User: "' + @user_name + '"'
					+ ', Error Message: "' + @error_message + '"'
			END CATCH
		END		-- IF NOT EXISTS (SELECT 1 FROM @File_Statuses

		-- If any file is missing, send an email indicating which ones are missing
		ELSE
		BEGIN
			SELECT @subject = 'Upsell Export - Not all files were found in Staging Location - ' + @@SERVERNAME

			-- Structured this way so you can have multipled tables worth of data chained in a row with minimum modification.
			SELECT @xml = 
						CAST( (
							SELECT td = Upsell_Name + '</td><td>'
										+ Source_Full_Path + '</td><td>'
										+ File_Exist_Status
							FROM (	SELECT	Name AS Upsell_Name,
											Source_Full_Path,
											CASE File_Exists_Status
												WHEN 0 THEN 'Does Not Exist'
												WHEN 1 THEN 'Exists'
												ELSE 'Status not 0 or 1'
											END AS File_Exist_Status											
									FROM @File_Statuses
									WHERE File_Exists_Status != 1
								) AS d
							ORDER BY d.Upsell_Name
						FOR XML PATH('tr'), TYPE ) AS VARCHAR(MAX))

			SET @body += '<H3>Files Missing</H3>
						<table border = 1> 
						<tr>'
						+ '<th> Upsell Name </th> '
						+ '<th> Source File Path </th> '
						+ '<th> File Exists Status </th> '
						+ '</tr>'
						+ REPLACE( REPLACE( ISNULL(@xml,''), '&lt;', '<'), '&gt;', '>')
						+ '</table>'
			-- End converting query results to HTML section, you can copy this section multiple times for multiple sets

			SET @body = '<body> Location checked: ' + @Source_Path + '<html>' + @body + '</body></html>'
		END	-- ELSE

		IF ISNULL(@body,'') != ''
		BEGIN
			--Email
			EXEC msdb.dbo.sp_send_dbmail 
				@recipients = @Recipients,
				@subject = @subject,
				@body = @body,
				@body_format = 'HTML'
		END

		-- An error was generated earlier, this is to make sure the job fails
		IF @error_description IS NOT NULL
		BEGIN
			RAISERROR(@error_description, @error_severity, @error_state)
		END
	END TRY

	BEGIN CATCH
	    SELECT
			@error_number = ERROR_NUMBER(),
			@error_severity = ERROR_SEVERITY(),
			@error_state = ERROR_STATE(),
			@sp_name = ISNULL(OBJECT_NAME(@@PROCID),''),
			@error_line = ERROR_LINE(),
			@error_message = ERROR_MESSAGE(),
			@user_name = SYSTEM_USER

		SELECT @error_description = ISNULL(@error_description,'') + CHAR(13) + '[' + @sp_name + '] has failed.' + CHAR(13)
			+ 'Error Number: ' + CONVERT(VARCHAR,@error_number) 
			+ ', Line: ' + CONVERT(VARCHAR,@error_line)
			+ ', User: "' + @user_name + '"'
			+ ', Error Message: "' + @error_message + '"'
		
		RAISERROR(@error_description, @error_severity, @error_state)

	END CATCH

	SET NOCOUNT OFF
END




GO
