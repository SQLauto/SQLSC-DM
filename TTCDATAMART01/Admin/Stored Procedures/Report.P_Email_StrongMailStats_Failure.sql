SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
------------------------------------------------------------------------------------------------------------------------------------------
-- Description: Sends an email that indicates that data in StrongMailStats has not been updated recently
------------------------------------------------------------------------------------------------------------------------------------------
-- Issue#	Date		Modified By		Details
------------------------------------------------------------------------------------------------------------------------------------------
-- US1978	03/30/2016	BryantJ			Initial
------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Report].[P_Email_StrongMailStats_Failure]
	@Recipients VARCHAR(MAX),
	@Max_Days_With_No_Updates INT = 3
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @max_data_date DATETIME,
		@now DATETIME = GETDATE()

	-- Email 
	DECLARE 
		@subject VARCHAR(MAX),
		@xml NVARCHAR(MAX),
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
		
	BEGIN TRY
		-- Check to make sure the StrongMailStats DB is reachable, if not send an email saying there is no DB
		IF NOT EXISTS(SELECT 1 FROM sys.databases sb WHERE name = 'StrongMailStats')
		BEGIN
			SELECT @subject = 'StrongMail Alert: StrongMailStats Database Not Found on Server - ' + @@SERVERNAME		
			SET @body = 'Please investigate, the StrongMailStats database is either missing or unreachable.'
		END
		-- If it is reachable, check to make sure the most recent log date is within the threshold
		ELSE
		BEGIN
			SELECT @max_data_date = MAX(DATESTAMP)
			FROM StrongMailStats..SM_SUCCESS_LOG WITH(NOLOCK)
			WHERE DATESTAMP < @now

			IF @max_data_date < DATEADD(DAY,-@Max_Days_With_No_Updates,@now)
			BEGIN			
				SELECT @subject = 'StrongMail Alert: StrongMailStats Has No New Data Since ' + CONVERT(VARCHAR,@max_data_date,20) + ' - ' + @@SERVERNAME

				-- Structured this way so you can have multipled tables worth of data chained in a row with minimum modification.
				SELECT @xml = 
							CAST( (
								SELECT td = CONVERT(VARCHAR,Log_Day,20) + '</td><td>'
											+ CONVERT(VARCHAR,Total)
								FROM (	
										SELECT CONVERT(DATE,DATESTAMP) AS Log_Day, 
											COUNT(*) Total
										FROM StrongMailStats..SM_SUCCESS_LOG WITH(NOLOCK)
										WHERE DATESTAMP > DATEADD(MONTH,-1,@now)
										GROUP BY CONVERT(DATE,DATESTAMP)
									) AS d
								ORDER BY Log_Day DESC
							FOR XML PATH('tr'), TYPE ) AS VARCHAR(MAX))

				SET @body += '<H3>Count of Records Per Day for the Last Month (Based on SM_SUCCESS_Log Table)</H3>
							<table border = 1> 
							<tr>'
							+ '<th> Log Day </th> '
							+ '<th> Total </th> '
							+ '</tr>'
							+ REPLACE( REPLACE( ISNULL(@xml,''), '&lt;', '<'), '&gt;', '>')
							+ '</table>'
				-- End converting query results to HTML section, you can copy this section multiple times for multiple sets

				SET @body = '<body><html>' + @body + '</body></html>'
			END	-- IF @max_data_date < DATEADD(DAY,-@Max_Days_With_No_Updates,GETDATE())
		END

		IF @subject IS NOT NULL
		BEGIN		
			--Email
			EXEC msdb.dbo.sp_send_dbmail 
				@recipients = @Recipients,
				@subject = @subject,
				@body = @body,
				@body_format = 'HTML'
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
