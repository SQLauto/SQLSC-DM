SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

------------------------------------------------------------------------------------------------------------------------------------------
-- Description: 
------------------------------------------------------------------------------------------------------------------------------------------
-- Issue#	Date		Modified By		Details
------------------------------------------------------------------------------------------------------------------------------------------
-- US2804	01/03/2017	BryantJ			Initial
------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Report].[P_Email_digital_library_merge_accounts_Counts]
	@Recipients VARCHAR(255)
AS
BEGIN
	SET NOCOUNT ON

	-- Error Variables
	DECLARE @error_description VARCHAR(MAX),
		@sp_name VARCHAR(MAX),
		@error_number INT,
		@error_line INT,
		@error_state VARCHAR(MAX),
		@error_severity VARCHAR(MAX),
		@user_name VARCHAR(MAX),
		@error_message VARCHAR(MAX)

	DECLARE @count INT = 0,
		@subject VARCHAR(MAX)
		
	BEGIN TRY
		IF NOT EXISTS(SELECT 1 FROM OPENQUERY(MAGENTO, 'SHOW TABLES LIKE ''digital_library_merge_accounts'''))
		BEGIN
			INSERT INTO Admin.Magento.[Digital_library_merge_accounts_counts]
				(Date_Timestamp, total, Table_Exists)
			VALUES 
				(GETDATE(),0,0)

			-- Send Critical Email
			SET @subject = 'Magento Merge Counts - digital_library_merge_accounts Does Not Exist - ' + @@SERVERNAME
		END
		ELSE
		BEGIN
			SELECT @count = total
			FROM OPENQUERY(MAGENTO, 'SELECT COUNT(*) total FROM digital_library_merge_accounts')

			-- Record values
			INSERT INTO Admin.Magento.[Digital_library_merge_accounts_counts]
				(Date_Timestamp, total, Table_Exists)
			VALUES 
				(GETDATE(), @count, 1 )

			IF @Count = 0
			BEGIN
				-- Send Non Critical Email
				SET @subject = 'Magento Merge Counts - digital_library_merge_accounts Is Empty - ' + @@SERVERNAME
			END
		END 

		IF @subject IS NOT NULL
		BEGIN
			EXEC msdb.dbo.sp_send_dbmail 
				@recipients = @Recipients,
				@subject = @subject,
				@body = '',
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
