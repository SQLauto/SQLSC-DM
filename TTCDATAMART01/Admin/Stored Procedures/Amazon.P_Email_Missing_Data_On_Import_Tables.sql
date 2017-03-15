SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
------------------------------------------------------------------------------------------------------------------------------------------
-- Description: Send an email if no data has been put into Amazon Import Tables since a certain period
------------------------------------------------------------------------------------------------------------------------------------------
-- Issue#	Date		Modified By		Details
------------------------------------------------------------------------------------------------------------------------------------------
-- US2518	09/14/2016	BryantJ			Initial
-- US2636	10/31/2016	BryantJ			Modified to split the alert parameters for orders and returns
------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Amazon].[P_Email_Missing_Data_On_Import_Tables]
	@Order_Number_Of_Days INT,
	@Return_Number_Of_Days INT,
	@Recipients VARCHAR(255)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @orders_count INT,
		@returns_count INT,
		@order_start_date DATETIME = DATEADD(DAY,-@Order_Number_Of_Days,GETDATE()),
		@return_start_date DATETIME = DATEADD(DAY,-@Return_Number_Of_Days,GETDATE()),
		@end_date DATETIME = GETDATE()
	
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
		SELECT @orders_count = COUNT(*)
		FROM Imports.Amazon.Orders WITH(NOLOCK)
		WHERE Import_Timestamp BETWEEN @order_start_date AND @end_date

		SELECT @returns_count = COUNT(*)
		FROM Imports.Amazon.Returns WITH(NOLOCK)
		WHERE Import_Timestamp BETWEEN @return_start_date AND @end_date

		IF @orders_count = 0
			OR @returns_count = 0
		BEGIN
			SELECT @subject = 'FBA Import - No Imports in ' + CONVERT(VARCHAR(15),@Order_Number_Of_Days) + ' day(s)'
							+ ' or Returns in ' + CONVERT(VARCHAR(15),@Return_Number_Of_Days) + ' day(s)' + @@SERVERNAME
			
			SET @body = 'No records have been imported for one of the following tables.<br>' 
					  + 'Please contact our FBA Connector Vendor: eBridge.<br><br>'
					  + '<table border = 1>'
						+ '<tr><th>Table Name</th><th>Count</th></tr>'
						+ '<tr><td>Imports.Amazon.Orders</td><td>' + CONVERT(VARCHAR(15),@orders_count) +'</td></tr>'
						+ '<tr><td>Imports.Amazon.Returns</td><td>' + CONVERT(VARCHAR(15),@returns_count) +'</td></tr>'
					  + '</table>'
			
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

		RAISERROR(@error_description, @error_severity, @error_state)

	END CATCH

	SET NOCOUNT OFF
END

GO
