SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
------------------------------------------------------------------------------------------------------------------------------------------
-- Description: Copies information for StrongMailStats tables to an archive Schema, the delete the original records
------------------------------------------------------------------------------------------------------------------------------------------
-- Issue#	Date		Modified By		Details
------------------------------------------------------------------------------------------------------------------------------------------
-- US2920	01/30/2017	BryantJ			Initial.
------------------------------------------------------------------------------------------------------------------------------------------
Create PROCEDURE [Archive].[P_Archive_StrongMail_Tables]
	@Years_To_Keep INT,
	@Loop_Size INT,
	@Max_Run_Time_In_Minutes INT 
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @end_datetime DATETIME = DATEADD(YEAR,-@Years_To_Keep,
											DATEADD(SECOND,-1,'01/01/' + CONVERT(VARCHAR,DATEPART(YEAR,GETDATE())) + ' 00:00:00.000')),
			@stop_datetime DATETIME = DATEADD(MINUTE,@Max_Run_Time_In_Minutes,GETDATE())

	-- Error Variables
	DECLARE @error_description VARCHAR(MAX),
		@sp_name VARCHAR(MAX),
		@error_number INT,
		@error_line INT,
		@error_state VARCHAR(MAX),
		@error_severity VARCHAR(MAX),
		@user_name VARCHAR(MAX),
		@error_message VARCHAR(MAX)

	IF OBJECT_ID('tempdb.dbo.#SM_AGGREGATE_LOG', 'U') IS NOT NULL 
		DROP TABLE #SM_AGGREGATE_LOG
	CREATE TABLE #SM_AGGREGATE_LOG
		(ID BIGINT PRIMARY KEY)

	IF OBJECT_ID('tempdb.dbo.#SM_SUCCESS_LOG', 'U') IS NOT NULL 
		DROP TABLE #SM_SUCCESS_LOG
	CREATE TABLE #SM_SUCCESS_LOG
		(ID BIGINT PRIMARY KEY)

	IF OBJECT_ID('tempdb.dbo.#SM_TRACKING_LOG', 'U') IS NOT NULL 
		DROP TABLE #SM_TRACKING_LOG
	CREATE TABLE #SM_TRACKING_LOG
		(ID BIGINT PRIMARY KEY)
		
	BEGIN TRY
		-- Archive SM_AGGREGATE_LOG
		WHILE EXISTS(SELECT 1 
					FROM dbo.SM_AGGREGATE_LOG sal
					WHERE sal.LOGDATE <= @end_datetime
					) 
		BEGIN
			INSERT INTO #SM_AGGREGATE_LOG
				(ID)
			SELECT TOP (@Loop_Size) ID 
			FROM dbo.SM_AGGREGATE_LOG sal
			WHERE sal.LOGDATE <= @end_datetime
				AND NOT EXISTS(SELECT 1 FROM Archive.SM_AGGREGATE_LOG asal
							WHERE sal.ID = asal.ID
							)

			INSERT INTO Archive.SM_AGGREGATE_LOG
			SELECT sal.* 
			FROM #SM_AGGREGATE_LOG tsal
				INNER JOIN dbo.SM_AGGREGATE_LOG sal
					ON sal.ID = tsal.ID
			
			DELETE sal
			FROM #SM_AGGREGATE_LOG tsal
				INNER JOIN dbo.SM_AGGREGATE_LOG sal
					ON sal.ID = tsal.ID

			TRUNCATE TABLE #SM_AGGREGATE_LOG

			IF GETDATE() > @stop_datetime
			BEGIN
				PRINT('Stopped during the archive of SM_AGGREGATE_LOG, due to time.')
				RETURN
			END
		END	-- Archive SM_AGGREGATE_LOG

		-- Archive SM_SUCCESS_LOG
		WHILE EXISTS(SELECT 1 
					FROM dbo.SM_SUCCESS_LOG smsl
					WHERE smsl.DATESTAMP <= @end_datetime
					) 
		BEGIN
			INSERT INTO #SM_SUCCESS_LOG
				(ID)
			SELECT TOP (@Loop_Size) ID 
			FROM dbo.SM_SUCCESS_LOG smsl
			WHERE smsl.DATESTAMP <= @end_datetime
				AND NOT EXISTS(SELECT 1 FROM Archive.SM_SUCCESS_LOG asmsl
							WHERE smsl.ID = asmsl.ID
							)

			INSERT INTO Archive.SM_SUCCESS_LOG
			SELECT smsl.* 
			FROM #SM_SUCCESS_LOG tsmsl
				INNER JOIN dbo.SM_SUCCESS_LOG smsl
					ON smsl.ID = tsmsl.ID
				
			DELETE smsl
			FROM #SM_SUCCESS_LOG tsmsl
				INNER JOIN dbo.SM_SUCCESS_LOG smsl
					ON smsl.ID = tsmsl.ID

			TRUNCATE TABLE #SM_SUCCESS_LOG

			IF GETDATE() > @stop_datetime
			BEGIN
				PRINT('Stopped during the archive of SM_SUCCESS_LOG, due to time.')
				RETURN
			END
		END	-- Archive SM_SUCCESS_LOG

		-- Archive SM_TRACKING_LOG
		WHILE EXISTS(SELECT 1 
					FROM dbo.SM_TRACKING_LOG stl
					WHERE stl.DATESTAMP <= @end_datetime
					) 
		BEGIN
			INSERT INTO #SM_TRACKING_LOG
				(ID)
			SELECT TOP (@Loop_Size) ID 
			FROM dbo.SM_TRACKING_LOG stl
			WHERE stl.DATESTAMP <= @end_datetime
				AND NOT EXISTS(SELECT 1 FROM Archive.SM_TRACKING_LOG astl
							WHERE stl.ID = astl.ID
							)

			INSERT INTO Archive.SM_TRACKING_LOG
			SELECT stl.* 
			FROM #SM_TRACKING_LOG tstl
				INNER JOIN dbo.SM_TRACKING_LOG stl
					ON stl.ID = tstl.ID
			
			DELETE stl
			FROM dbo.SM_TRACKING_LOG stl
			WHERE EXISTS(SELECT 1 FROM #SM_TRACKING_LOG astl
						WHERE stl.ID = astl.ID
						)

			TRUNCATE TABLE #SM_TRACKING_LOG

			IF GETDATE() > @stop_datetime
			BEGIN
				PRINT('Stopped during the archive of SM_TRACKING_LOG, due to time.')
				RETURN
			END	-- Archive SM_TRACKING_LOG
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

		SELECT @error_description = CHAR(13) + '[' + @sp_name + '] has failed.' + CHAR(13)
			+ 'Error Number: ' + CONVERT(VARCHAR,@error_number) 
			+ ', Line: ' + CONVERT(VARCHAR,@error_line)
			+ ', User: "' + @user_name + '"'
			+ ', Error Message: "' + @error_message + '"'

		RAISERROR(@error_description, @error_severity, @error_state)

	END CATCH

	SET NOCOUNT OFF
END
GO
