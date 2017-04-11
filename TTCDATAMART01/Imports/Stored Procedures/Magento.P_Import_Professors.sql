SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
------------------------------------------------------------------------------------------------------------------------------------------
-- Description: Imports Course information from Magento
------------------------------------------------------------------------------------------------------------------------------------------
-- Issue#	Date		Modified By		Details
------------------------------------------------------------------------------------------------------------------------------------------
-- US2564	11/01/2016	BryantJ			Initial
------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Magento].[P_Import_Professors]
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @count INT = 0

	-- Error Variables
	DECLARE @error_description VARCHAR(MAX),
		@sp_name VARCHAR(MAX) = OBJECT_NAME(@@PROCID),
		@error_number INT,
		@error_line INT,
		@error_state VARCHAR(MAX),
		@error_severity VARCHAR(MAX),
		@user_name VARCHAR(MAX),
		@error_message VARCHAR(MAX)

	IF OBJECT_ID('tempdb.dbo.#professor', 'U') IS NOT NULL 
		DROP TABLE #professor
	CREATE TABLE #professor
		(professor_id int NOT NULL,
		first_name varchar(128) NOT NULL,
		last_name varchar(128) NOT NULL,
		qual varchar(255) NOT NULL,
		bio VARCHAR(MAX) NOT NULL,
		[rank] INT,
		quote VARCHAR(MAX) NOT NULL,
		title varchar(64) NOT NULL,
		category_id int,
		email varchar(255) NOT NULL,
		facebook varchar(255) NOT NULL,
		twitter varchar(255) NOT NULL,
		pinterest varchar(255) NOT NULL,
		youtube varchar(255) NOT NULL,
		photo varchar(255) NOT NULL,
		testimonial VARCHAR(MAX) NOT NULL,
		import_row_num INT,
		url_key varchar(100) NOT NULL,
		meta_title varchar(200) NOT NULL,
		meta_keywords varchar(200) NOT NULL,
		meta_description VARCHAR(MAX) NOT NULL
		)

	IF OBJECT_ID('tempdb.dbo.#professor_alma_mater', 'U') IS NOT NULL 
		DROP TABLE #professor_alma_mater
	CREATE TABLE #professor_alma_mater
		(professor_id int NOT NULL,
		institution_id int NOT NULL
		)

	IF OBJECT_ID('tempdb.dbo.#professor_product', 'U') IS NOT NULL 
		DROP TABLE #professor_product
	CREATE TABLE #professor_product
		(professor_id int NOT NULL,
		product_id int NOT NULL
		) 

	IF OBJECT_ID('tempdb.dbo.#professor_teaching', 'U') IS NOT NULL 
		DROP TABLE #professor_teaching
	CREATE TABLE #professor_teaching 
		(professor_id int NOT NULL,
		institution_id int NOT NULL
		)

	IF OBJECT_ID('tempdb.dbo.#institution', 'U') IS NOT NULL 
		DROP TABLE #institution
	CREATE TABLE #institution
		(institution_id int NOT NULL,
		name varchar(128) NOT NULL
		)

	BEGIN TRY
		-------------------------------------------------------------------------------------------------------------
		-- professor
		-------------------------------------------------------------------------------------------------------------
		INSERT INTO #professor
			([professor_id],
			[first_name],
			[last_name],
			[qual],
			[bio],
			[rank],
			[quote],
			[title],
			[category_id],
			[email],
			[facebook],
			[twitter],
			[pinterest],
			[youtube],
			[photo],
			[testimonial],
			[import_row_num],
			[url_key],
			[meta_title],
			[meta_keywords],
			[meta_description])
		SELECT [professor_id],
			[first_name],
			[last_name],
			[qual],
			[bio],
			[rank],
			[quote],
			[title],
			[category_id],
			[email],
			[facebook],
			[twitter],
			[pinterest],
			[youtube],
			[photo],
			[testimonial],
			[import_row_num],
			[url_key],
			[meta_title],
			[meta_keywords],
			[meta_description]
		FROM OPENQUERY(Magento,
			'SELECT professor_id,
				first_name,
				last_name,
				qual,
				bio,
				rank,
				quote,
				title,
				category_id,
				email,
				facebook,
				twitter,
				pinterest,
				youtube,
				photo,
				testimonial,
				import_row_num,
				url_key,
				meta_title,
				meta_keywords,
				meta_description
			FROM professor')

		BEGIN TRANSACTION
			-- Delete/Insert into table
			SELECT @count = COUNT(*) FROM Magento.professor 
			TRUNCATE TABLE Magento.professor

			INSERT INTO Import_Log 
				(Operation_Date, Source, [Schema_Name], Table_Name, Operation, Operation_Count, After_Count)
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'professor', 'DELETED', @count, (SELECT COUNT(*) FROM Magento.professor)

			INSERT INTO Magento.professor
				([professor_id],
				[first_name],
				[last_name],
				[qual],
				[bio],
				[rank],
				[quote],
				[title],
				[category_id],
				[email],
				[facebook],
				[twitter],
				[pinterest],
				[youtube],
				[photo],
				[testimonial],
				[import_row_num],
				[url_key],
				[meta_title],
				[meta_keywords],
				[meta_description])
			SELECT [professor_id],
				[first_name],
				[last_name],
				[qual],
				[bio],
				[rank],
				[quote],
				[title],
				[category_id],
				[email],
				[facebook],
				[twitter],
				[pinterest],
				[youtube],
				[photo],
				[testimonial],
				[import_row_num],
				[url_key],
				[meta_title],
				[meta_keywords],
				[meta_description]
			FROM #professor

			INSERT INTO Import_Log
				([Operation_Date],[Source],[Schema_Name],[Table_Name],[Operation],[Operation_Count],[After_Count])
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'professor', 'INSERTED', @@ROWCOUNT, (SELECT COUNT(*) FROM Magento.professor)
		COMMIT TRANSACTION

		-------------------------------------------------------------------------------------------------------------
		-- professor_alma_mater
		-------------------------------------------------------------------------------------------------------------
		INSERT INTO #professor_alma_mater
			([professor_id],
			[institution_id])
		SELECT [professor_id],
			[institution_id]
		FROM OPENQUERY(Magento,
			'SELECT professor_id,
				institution_id
			FROM professor_alma_mater')

		BEGIN TRANSACTION
			-- Delete/Insert into table
			SELECT @count = COUNT(*) FROM Magento.professor_alma_mater 
			TRUNCATE TABLE Magento.professor_alma_mater

			INSERT INTO Import_Log 
				(Operation_Date, Source, [Schema_Name], Table_Name, Operation, Operation_Count, After_Count)
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'professor_alma_mater', 'DELETED', @count, (SELECT COUNT(*) FROM Magento.professor_alma_mater)

			INSERT INTO Magento.professor_alma_mater
				([professor_id],
				[institution_id])
			SELECT [professor_id],
				[institution_id]
			FROM #professor_alma_mater

			INSERT INTO Import_Log
				([Operation_Date],[Source],[Schema_Name],[Table_Name],[Operation],[Operation_Count],[After_Count])
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'professor_alma_mater', 'INSERTED', @@ROWCOUNT, (SELECT COUNT(*) FROM Magento.professor_alma_mater)
		COMMIT TRANSACTION

		-------------------------------------------------------------------------------------------------------------
		-- professor_product
		-------------------------------------------------------------------------------------------------------------
		INSERT INTO #professor_product
			([professor_id],
			[product_id])
		SELECT [professor_id],
			[product_id]
		FROM OPENQUERY(Magento,
			'SELECT professor_id,
				product_id
			FROM professor_product')

		BEGIN TRANSACTION
			-- Delete/Insert into table
			SELECT @count = COUNT(*) FROM Magento.professor_product 
			TRUNCATE TABLE Magento.professor_product

			INSERT INTO Import_Log 
				(Operation_Date, Source, [Schema_Name], Table_Name, Operation, Operation_Count, After_Count)
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'professor_product', 'DELETED', @count, (SELECT COUNT(*) FROM Magento.professor_product)

			INSERT INTO Magento.professor_product
				([professor_id],
				[product_id])
			SELECT [professor_id],
				[product_id]
			FROM #professor_product

			INSERT INTO Import_Log
				([Operation_Date],[Source],[Schema_Name],[Table_Name],[Operation],[Operation_Count],[After_Count])
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'professor_product', 'INSERTED', @@ROWCOUNT, (SELECT COUNT(*) FROM Magento.professor_product)
		COMMIT TRANSACTION

		-------------------------------------------------------------------------------------------------------------
		-- professor_teaching
		-------------------------------------------------------------------------------------------------------------
		INSERT INTO #professor_teaching
			([professor_id],
			[institution_id])
		SELECT [professor_id],
			[institution_id]
		FROM OPENQUERY(Magento,
			'SELECT professor_id,
				institution_id
			FROM professor_teaching')

		BEGIN TRANSACTION
			-- Delete/Insert into table
			SELECT @count = COUNT(*) FROM Magento.professor_teaching 
			TRUNCATE TABLE Magento.professor_teaching

			INSERT INTO Import_Log 
				(Operation_Date, Source, [Schema_Name], Table_Name, Operation, Operation_Count, After_Count)
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'professor_teaching', 'DELETED', @count, (SELECT COUNT(*) FROM Magento.professor_teaching)

			INSERT INTO Magento.professor_teaching
				([professor_id],
				[institution_id])
			SELECT [professor_id],
				[institution_id]
			FROM #professor_teaching

			INSERT INTO Import_Log
				([Operation_Date],[Source],[Schema_Name],[Table_Name],[Operation],[Operation_Count],[After_Count])
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'professor_teaching', 'INSERTED', @@ROWCOUNT, (SELECT COUNT(*) FROM Magento.professor_teaching)
		COMMIT TRANSACTION

		-------------------------------------------------------------------------------------------------------------
		-- institution
		-------------------------------------------------------------------------------------------------------------
		INSERT INTO #institution
			([institution_id],
			[name])
		SELECT [institution_id],
			[name]
		FROM OPENQUERY(Magento,
			'SELECT institution_id,
				name
			FROM institution')

		BEGIN TRANSACTION
			-- Delete/Insert into table
			SELECT @count = COUNT(*) FROM Magento.institution 
			TRUNCATE TABLE Magento.institution

			INSERT INTO Import_Log 
				(Operation_Date, Source, [Schema_Name], Table_Name, Operation, Operation_Count, After_Count)
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'institution', 'DELETED', @count, (SELECT COUNT(*) FROM Magento.institution)

			INSERT INTO Magento.institution
				([institution_id],
				[name])
			SELECT [institution_id],
				[name]
			FROM #institution

			INSERT INTO Import_Log
				([Operation_Date],[Source],[Schema_Name],[Table_Name],[Operation],[Operation_Count],[After_Count])
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'institution', 'INSERTED', @@ROWCOUNT, (SELECT COUNT(*) FROM Magento.institution)
		COMMIT TRANSACTION
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

		SELECT @error_description = CHAR(13) + '[' + @sp_name + '] has failed.' + CHAR(13)
			+ 'Error Number: ' + CONVERT(VARCHAR,@error_number) 
			+ ', Line: ' + CONVERT(VARCHAR,@error_line)
			+ ', User: "' + @user_name + '"'
			+ ', Error Message: "' + @error_message + '"'
		
		-- Close open transactions, only use if using transactions
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION
		END

		RAISERROR(@error_description, @error_severity, @error_state)

	END CATCH

	SET NOCOUNT OFF
END
GO
