SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
------------------------------------------------------------------------------------------------------------------------------------------
-- Description: Gets data from SailThru API and puts it to a local table, based on values in DataWarehouse
------------------------------------------------------------------------------------------------------------------------------------------
-- Issue#	Date		Modified By		Details
------------------------------------------------------------------------------------------------------------------------------------------
-- US3079	03/27/2017	BryantJ			Initial
------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [SailThru].[P_Import_Customer_Details]
	@Requests_Per_Minute INT = 18000 -- Current value is 18000 as of when this was created
AS
BEGIN
	SET NOCOUNT ON
	SET ANSI_WARNINGS OFF

	DECLARE @json VARCHAR(MAX) = '',
		@connection_path VARCHAR(MAX),
		@api_key VARCHAR(MAX),
		@api_secret VARCHAR(MAX)

	DECLARE @hdoc AS INT,
		@api_path VARCHAR(255),
		@object INT,
		@responsetext VARCHAR(8000),
		@pre_sig VARCHAR(MAX),
		@signature VARBINARY(8000),
		@payload VARCHAR(MAX),
		@email VARCHAR(MAX) ,
		@throttle_count INT = 0,
		@throttle_startdatetime DATETIME,
		@delay_in_seconds TINYINT,
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

	IF OBJECT_ID('tempdb.dbo.#Email_List', 'U') IS NOT NULL 
		DROP TABLE #Email_List
	CREATE TABLE #Email_List
			(Email VARCHAR(255),
			Import_Status TINYINT) --0 unprocessed, 1 successful, 2 fail

	IF OBJECT_ID('tempdb.dbo.#API_Response', 'U') IS NOT NULL 
		DROP TABLE #API_Response
	CREATE TABLE #API_Response
		(element_id INT IDENTITY(1, 1) NOT NULL,
		sequenceNo [int] NULL,					
		parent_ID INT,							
		Object_ID INT,							 											
		NAME NVARCHAR(2000),					
		StringValue NVARCHAR(MAX) NULL,			
		ValueType VARCHAR(MAX) NULL)		

	-- Create #Email_Details here
	IF OBJECT_ID('tempdb.dbo.#Email_Details', 'U') IS NOT NULL 
		DROP TABLE #Email_Details
	CREATE TABLE #Email_Details
		(Email VARCHAR(255) PRIMARY KEY,
		Engagement VARCHAR(MAX),
		Activity_Click_Time VARCHAR(MAX),
		Activity_Create_Time VARCHAR(MAX),
		Activity_Login_Time VARCHAR(MAX),
		Activity_Open_Time VARCHAR(MAX),
		Activity_Signup_Time VARCHAR(MAX),
		Top_Device_Email VARCHAR(MAX),
		Lifetime_Click INT,
		Lifetime_Message INT,
		Lifetime_Open INT,
		List_Count INT,
		Lists VARCHAR(MAX),	
		JSON VARCHAR(MAX))

	BEGIN TRY
		-- Get connection information
		OPEN SYMMETRIC KEY Connection_Information_Password_Key
		   DECRYPTION BY CERTIFICATE Connection_Information_Password_Cert;  
		SELECT TOP 1 
			@connection_path = Connection_Data,
			@api_key = Connection_Username,
			@api_secret = CONVERT(VARCHAR(MAX),DecryptByKey(Connection_Password) )
		FROM dbo.Connection_Information
		WHERE Connection_Name = 'ViewLift Export Lift Data'

		-- Get list of email addresses
		INSERT INTO #email_list
			(email,
			Import_Status)
		SELECT DISTINCT 
			email, 
			0 AS Import_Status	-- default is not imported
		FROM DataWarehouse.Archive.TGCPlus_User
		WHERE email IS NOT NULL


		SET @throttle_startdatetime = GETDATE()

		-- Import data for each of the emails listed
		WHILE EXISTS(SELECT 1 FROM #email_list WHERE Import_Status = 0)
		BEGIN

			-- Get new email
			SELECT TOP 1 
				@email = Email 
			FROM #email_list 
			WHERE Import_Status = 0

			-- Build Payload
			SELECT @payload = '{"id":"' + @email + '","fields":{"activity":1,"engagement":1,"lifetime":1,"lists":1,"optout_email":1,"device":1}}'	
			SELECT @pre_sig = @api_secret + @api_key + 'json' + @payload
			SELECT @signature = HashBytes('MD5', @pre_sig)

			-- Build API path
			SET @api_path = @connection_path + 'user' + 
							+ '?api_key=' + @api_key
							+ '&sig=' + LOWER(CONVERT(VARCHAR(MAX),@signature, 2))
							+ '&format=json'
							+ '&json=' + @payload 

			-- Send API request
			EXEC sp_OACreate 'MSXML2.ServerXMLHttp', @Object OUT;
			EXEC sp_OAMethod @Object, 'open', NULL, 'get', @api_path, 'false'
			EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Accept', 'application/xml'
			EXEC sp_OAMethod @Object, 'send'
			EXEC sp_OAMethod @Object, 'responseText', @responsetext OUT
			EXEC sp_OADestroy @Object

			-- pulls the response
			INSERT INTO #API_Response
				(sequenceNo,					
				parent_ID,							
				Object_ID,							 											
				NAME,					
				StringValue,			
				ValueType)
			SELECT 
				sequenceNo,					
				parent_ID,							
				Object_ID,							 											
				NAME,					
				StringValue,			
				ValueType
			FROM F_Parse_JSON(@responsetext)

			-- If there is an API error, record error, Else, flatten results and insert into table
			IF EXISTS (SELECT 1 FROM #API_Response WHERE NAME IN ('error','errormsg'))
			BEGIN
				INSERT INTO SailThru.API_Errors
					(Email,
					Log_Datetime,
					Error_Code,
					Error_Response,
					JSON)
				SELECT
					@email,
					GETDATE(),
					MAX(CASE WHEN NAME = 'error' THEN StringValue ELSE '' END) AS Error_Code,
					MAX(CASE WHEN NAME = 'errormsg' THEN StringValue ELSE '' END) AS Error_Response,
					@responsetext
				FROM #API_Response
			END
			ELSE
			BEGIN
				-- flatten results and insert into #Email_Details
				INSERT INTO #Email_Details
					(Email,
					Engagement,
					Activity_Click_Time,
					Activity_Create_Time,
					Activity_Login_Time,
					Activity_Open_Time,
					Activity_Signup_Time,
					Top_Device_Email,
					Lifetime_Click,
					Lifetime_Message,
					Lifetime_Open,
					List_Count,
					Lists,	
					JSON)
				SELECT 
					@email,
					MAX(CASE WHEN ar.NAME = 'engagement' THEN ar.StringValue ELSE NULL END) AS Engagement,
					MAX(CASE WHEN arp.NAME = 'activity' 
									AND ar.NAME = 'click_time'
								THEN ar.StringValue ELSE NULL END) AS Activity_Click_Time,
					MAX(CASE WHEN arp.NAME = 'activity' 
									AND ar.NAME = 'create_time'
								THEN ar.StringValue ELSE NULL END) AS Activity_Create_Time,
					MAX(CASE WHEN arp.NAME = 'activity' 
									AND ar.NAME = 'login_time'
								THEN ar.StringValue ELSE NULL END) AS Activity_Login_Time,
					MAX(CASE WHEN arp.NAME = 'activity' 
									AND ar.NAME = 'open_time'
								THEN ar.StringValue ELSE NULL END) AS Activity_Open_Time,
					MAX(CASE WHEN arp.NAME = 'activity' 
									AND ar.NAME = 'signup_time'
								THEN ar.StringValue ELSE NULL END) AS Activity_Signup_Time,
					MAX(CASE WHEN arp.NAME = 'device' 
									AND ar.NAME = 'top_device_email'
								THEN ar.StringValue ELSE NULL END) AS Top_Device_Email,
					MAX(CASE WHEN arp.NAME = 'lifetime' 
									AND ar.NAME = 'lifetime_click'
								THEN ar.StringValue ELSE NULL END) AS Lifetime_Click,
					MAX(CASE WHEN arp.NAME = 'lifetime' 
									AND ar.NAME = 'lifetime_message'
								THEN ar.StringValue ELSE NULL END) AS Lifetime_Message,
					MAX(CASE WHEN arp.NAME = 'lifetime' 
									AND ar.NAME = 'lifetime_open'
								THEN ar.StringValue ELSE NULL END) AS Lifetime_Open,
					SUM(CASE WHEN arp.NAME = 'lists' THEN 1 ELSE 0 END) AS List_Count,
					dbo.F_Group_Concat_D((CASE WHEN arp.NAME = 'lists' THEN ar.NAME ELSE NULL END),'|') AS Lists,
					@responsetext
				FROM #API_Response ar
					LEFT JOIN #API_Response arp	-- Get the parent/group labels
						ON ar.parent_ID = arp.Object_ID

			END	--Else IF NOT EXISTS (SELECT 1 FROM #API_Response WHERE NAME IN ('error','errormsg'))

			UPDATE #email_list
			SET Import_Status = 1
			WHERE Email = @email

			TRUNCATE TABLE #API_Response
			
			-- Throttle if going too fast
			SET @throttle_count += 1

			-- If more than 18000 records have been sent in the last minute
			IF @throttle_count >= @Requests_Per_Minute	
				AND GETDATE() <= DATEADD(MINUTE,1,@throttle_startdatetime)
			BEGIN
				-- how many seconds are left til the tracked minute is up
				SET @delay_in_seconds = DATEDIFF(S,GETDATE(),DATEADD(MINUTE,1,@throttle_startdatetime))
				
				WAITFOR DELAY @delay_in_seconds
				SET @throttle_startdatetime = GETDATE()
				SET @throttle_count = 0
			END
			-- If it's past a minute, reset the time and the count
			ELSE IF GETDATE() > DATEADD(MINUTE,1,@throttle_startdatetime)		--reset the start time if it goes past a minute
			BEGIN
				SET @throttle_startdatetime = GETDATE()
				SET @throttle_count = 0
			END
	
		END	--WHILE EXISTS(SELECT 1 FROM #email_list WHERE Import_Status = 0)
		
		-- Insert into Staging table
		IF EXISTS(SELECT 1 FROM #Email_Details)
		BEGIN
			BEGIN TRANSACTION
				-- Delete/Insert into SailThru.Email_Details table
				SELECT @count = COUNT(*) FROM SailThru.Email_Details
				TRUNCATE TABLE SailThru.Email_Details

				INSERT INTO Import_Log 
					(Operation_Date, Source, [Schema_Name], Table_Name, Operation, Operation_Count, After_Count)
				SELECT 
					GETDATE(), @sp_name, 'SailThru', 'Email_Details', 'DELETED', @count, (SELECT COUNT(*) FROM SailThru.Email_Details)

				INSERT INTO SailThru.Email_Details
					(Email,
					Engagement,
					Activity_Click_Time,
					Activity_Create_Time,
					Activity_Login_Time,
					Activity_Open_Time,
					Activity_Signup_Time,
					Top_Device_Email,
					Lifetime_Click,
					Lifetime_Message,
					Lifetime_Open,
					List_Count,
					Lists,	
					JSON)
				SELECT 
					Email,
					Engagement,
					Activity_Click_Time,
					Activity_Create_Time,
					Activity_Login_Time,
					Activity_Open_Time,
					Activity_Signup_Time,
					Top_Device_Email,
					Lifetime_Click,
					Lifetime_Message,
					Lifetime_Open,
					List_Count,
					Lists,	
					JSON
				FROM #Email_Details

				INSERT INTO Import_Log
					([Operation_Date],[Source],[Schema_Name],[Table_Name],[Operation],[Operation_Count],[After_Count])
				SELECT 
					GETDATE(), @sp_name, 'SailThru', 'Email_Details', 'INSERTED', @@ROWCOUNT, (SELECT COUNT(*) FROM SailThru.Email_Details)
			COMMIT TRANSACTION
			
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
	SET ANSI_WARNINGS ON
END
GO
