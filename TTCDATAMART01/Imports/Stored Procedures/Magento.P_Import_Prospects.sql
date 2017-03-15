SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
------------------------------------------------------------------------------------------------------------------------------------------
-- Description: Copies Prospects data from Magento to DaxImports..TTCPROSPECTS(I know the DB is DaxImports, but we wanted this to be
--					as light as possible to existing processes on this server.  So we're just changing how the data gets here.
--					Deletes everything from the local TTCPROSPECTS table and reimports the data from Magento directly.
------------------------------------------------------------------------------------------------------------------------------------------
-- Issue#	Date		Modified By		Details
------------------------------------------------------------------------------------------------------------------------------------------
-- US2164	04/29/2016	BryantJ			Initial
------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Magento].[P_Import_Prospects]
AS
BEGIN
	SET NOCOUNT ON
	
	DECLARE @count INT
		
	-- Error Variables
	DECLARE @error_description VARCHAR(MAX),
		@sp_name SYSNAME = OBJECT_NAME(@@PROCID),
		@error_number INT,
		@error_line INT,
		@error_state VARCHAR(MAX),
		@error_severity VARCHAR(MAX),
		@user_name VARCHAR(MAX),
		@error_message VARCHAR(MAX)

	IF OBJECT_ID('tempdb.dbo.#prospects', 'U') IS NOT NULL 
		DROP TABLE #prospects
	CREATE TABLE #prospects
		( 
		ID INT IDENTITY(1,1),
		[WEBPROSPECTID] int  NULL,  
		[CUSTACCOUNT] nvarchar(25)  NULL,  
		[WEBUSERID] VARCHAR(64)  NULL,  
		[WEBDATECOLLECTED] datetime  NULL,  
		[INITIALSOURCECODE] int  NULL,  
		[EMAILADDRESS] nvarchar(255)  NULL,  
		[INITIALUSERAGENT] nvarchar(255)  NULL,  
		[LASTDATECOLLECTED] datetime  NULL,  
		[OPTINSTATUS] int  NULL,  
		[EMAILCONFIRMED] bigint  NOT NULL,  
		[EmailConfirmedDate] datetime  NULL,  
		[ConfirmationGuid] nvarchar(255)  NULL,  
		[IsAccountWhenCreated] int  NULL,  
		[UnsubscribeRequestDate] datetime  NULL,  
		[JSLastName] nvarchar(255)  NULL,  
		[JSFirstName] nvarchar(255)  NULL)

	BEGIN TRY
		-- Get Data from Magento
		-- Using dynamic sql here because we can't pass in variables into OPENQUERY
		INSERT INTO #prospects
				(WEBPROSPECTID,
				CUSTACCOUNT,
				WEBUSERID,
				WEBDATECOLLECTED,
				INITIALSOURCECODE,
				EMAILADDRESS,
				INITIALUSERAGENT,
				LASTDATECOLLECTED,
				OPTINSTATUS,
				EMAILCONFIRMED,
				EmailConfirmedDate,
				ConfirmationGuid,
				IsAccountWhenCreated,
				UnsubscribeRequestDate,
				JSLastName,
				JSFirstName
				)
			SELECT WEBPROSPECTID,
				CUSTACCOUNT,
				WEBUSERID,
				WEBDATECOLLECTED,
				INITIALSOURCECODE,
				EMAILADDRESS,
				INITIALUSERAGENT,
				LASTDATECOLLECTED,
				OPTINSTATUS,
				ACCOUNTVERIFIED,
				VERIFIEDDATE,
				ConfirmationGuid,
				AcctatSignup,
				UnsubscribeRequestDate,
				JSLastName,
				JSFirstName
			FROM OPENQUERY(MAGENTO, 'SELECT  
										a.value AS WEBPROSPECTID, 
										ce.dax_customer_id AS CUSTACCOUNT, 
										ce.entity_id AS WEBUSERID, 
										b.value AS WEBDATECOLLECTED, 
										c.value AS INITIALSOURCECODE,
										ce.email AS EMAILADDRESS, 
										f.value AS INITIALUSERAGENT, 
										g.value AS LASTDATECOLLECTED, 
										m.value AS OPTINSTATUS,
										IFNULL(h.value,0) AS ACCOUNTVERIFIED, 
										i.value AS VERIFIEDDATE, 
										j.value AS ConfirmationGuid, 
										k.value AS ACCTatSIGNUP, 
										l.value AS UnsubscribeRequestDate,
										e.value AS JSLastName,
										d.value AS JSFirstName
									FROM magento.customer_entity ce                                    
										LEFT JOIN customer_entity_int a
											ON ce.entity_id = a.entity_id
												AND a.attribute_id = (SELECT attribute_id FROM 	eav_attribute ea
																		WHERE ea.attribute_code = ''web_prospect_id''
																			AND ea.entity_type_id = 1) -- 251
										LEFT JOIN customer_entity_datetime b
											ON ce.entity_id = b.entity_id
												AND b.attribute_id = (SELECT attribute_id FROM 	eav_attribute ea
																		WHERE ea.attribute_code = ''free_lectures_date_collected''
																			AND ea.entity_type_id = 1) -- 252
										LEFT JOIN customer_entity_int c
											ON ce.entity_id = c.entity_id
												AND c.attribute_id = (SELECT attribute_id FROM 	eav_attribute ea
																		WHERE ea.attribute_code = ''free_lectures_initial_source''
																			AND ea.entity_type_id = 1) -- 254
										LEFT JOIN customer_entity_varchar d
											ON ce.entity_id = d.entity_id
												AND d.attribute_id = (SELECT attribute_id FROM 	eav_attribute ea
																		WHERE ea.attribute_code = ''firstname''
																			AND ea.entity_type_id = 1) -- 5
										LEFT JOIN customer_entity_varchar e
											ON ce.entity_id = e.entity_id
												AND e.attribute_id = (SELECT attribute_id FROM 	eav_attribute ea
																		WHERE ea.attribute_code = ''lastname''
																			AND ea.entity_type_id = 1) -- 7
										LEFT JOIN customer_entity_varchar f
											ON ce.entity_id = f.entity_id
												AND f.attribute_id = (SELECT attribute_id FROM 	eav_attribute ea
																		WHERE ea.attribute_code = ''free_lect_initial_user_agent''
																			AND ea.entity_type_id = 1) -- 255
										LEFT JOIN customer_entity_datetime g
											ON ce.entity_id = g.entity_id
												AND g.attribute_id = (SELECT attribute_id FROM 	eav_attribute ea
																		WHERE ea.attribute_code = ''free_lect_last_date_collected''
																			AND ea.entity_type_id = 1) -- 253
										LEFT JOIN customer_entity_int h
											ON ce.entity_id = h.entity_id
												AND h.attribute_id = (SELECT attribute_id FROM 	eav_attribute ea
																		WHERE ea.attribute_code = ''email_verified''
																			AND ea.entity_type_id = 1) -- 256
										LEFT JOIN customer_entity_datetime i
											ON ce.entity_id = i.entity_id
												AND i.attribute_id = (SELECT attribute_id FROM 	eav_attribute ea
																		WHERE ea.attribute_code = ''date_verified''
																			AND ea.entity_type_id = 1) -- 257
										LEFT JOIN customer_entity_varchar j
											ON ce.entity_id = j.entity_id
												AND j.attribute_id = (SELECT attribute_id FROM 	eav_attribute ea
																		WHERE ea.attribute_code = ''confirmation_guid''
																			AND ea.entity_type_id = 1) -- 258
										LEFT JOIN customer_entity_int k
											ON ce.entity_id = k.entity_id
												AND k.attribute_id = (SELECT attribute_id FROM 	eav_attribute ea
																		WHERE ea.attribute_code = ''is_account_at_signup''
																			AND ea.entity_type_id = 1) -- 259
										LEFT JOIN customer_entity_datetime l
											ON ce.entity_id = l.entity_id
												AND l.attribute_id = (SELECT attribute_id FROM 	eav_attribute ea
																		WHERE ea.attribute_code = ''free_lect_date_unsubscribed''
																			AND ea.entity_type_id = 1) -- 271
										LEFT JOIN customer_entity_int m
											ON ce.entity_id = m.entity_id
												AND m.attribute_id = (SELECT attribute_id FROM 	eav_attribute ea
																		WHERE ea.attribute_code = ''free_lect_subscribe_status''
																			AND ea.entity_type_id = 1)
									WHERE a.value IS NOT NULL'
								)
				
		-- Insert it into Prospects Table
		BEGIN TRANSACTION
			SELECT @count = COUNT(*) FROM Magento.Prospects
			TRUNCATE TABLE Magento.Prospects

			INSERT INTO Import_Log 
				(Operation_Date, Source, [Schema_Name], Table_Name, Operation, Operation_Count, After_Count)
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'Prospects', 'DELETED', @count, (SELECT COUNT(*) FROM Magento.Prospects)
			
			INSERT INTO Magento.Prospects
				(
				PROSPECTID,
				WEBPROSPECTID,
				CUSTACCOUNT,
				WebUserID,
				WEBDATECOLLECTED,
				INITIALSOURCECODE,
				EMAILADDRESS,
				INITIALUSERAGENT,
				LASTDATECOLLECTED,
				OPTINSTATUS,
				EMAILCONFIRMED,
				EmailConfirmedDate,
				ConfirmationGuid,
				IsAccountWhenCreated,
				UnsubscribeRequestDate,
				JSLastName,
				JSFirstName,
				UNSUBSCRIBEREQUESTDATETZID,
				UNSUBSCRIBEORIGIN,
				RESUBSCRIBEREQUESTDATE,
				RESUBSCRIBEREQUESTDATETZID,
				RESUBSCRIBEORIGIN,
				LASTCUSTOMERCHECKDATE,
				LASTCUSTOMERCHECKDATETZID,
				UNSUBSCRIBEREASON,
				WEBDATECOLLECTEDTZID,
				MODIFIEDDATETIME,
				MODIFIEDBY,
				CREATEDDATETIME,
				CREATEDBY,
				DATAAREAID,
				RECVERSION,
				RECID,
				CONVERSIONDATE,
				CONVERSIONDATETZID,
				EMAILCONFIRMEDDATETZID
				)
			SELECT
				CONVERT(NVARCHAR(30),ID),
				CONVERT(NVARCHAR(10),WEBPROSPECTID),
				ISNULL(CONVERT(NVARCHAR(20),CUSTACCOUNT),''),
				ISNULL(WEBUSERID,''),
				ISNULL(WEBDATECOLLECTED,''),
				ISNULL(CONVERT(NVARCHAR(10),INITIALSOURCECODE),''),
				ISNULL(CONVERT(NVARCHAR(80),EMAILADDRESS),''),
				ISNULL(CONVERT(NVARCHAR(100),INITIALUSERAGENT),''),
				ISNULL(LASTDATECOLLECTED,''), 
				ISNULL(OPTINSTATUS,''),
				ISNULL(CONVERT(INT,EMAILCONFIRMED),''),
				ISNULL(EmailConfirmedDate,''),
				ISNULL(CONVERT(NVARCHAR(50),ConfirmationGuid),''),
				ISNULL(IsAccountWhenCreated,''),
				ISNULL(UnsubscribeRequestDate,''),
				ISNULL(CONVERT(NVARCHAR(25),JSLastName),''),
				ISNULL(CONVERT(NVARCHAR(25),JSFirstName),''),
				'' AS UNSUBSCRIBEREQUESTDATETZID,
				'' AS UNSUBSCRIBEORIGIN,
				'' AS RESUBSCRIBEREQUESTDATE,
				'' AS RESUBSCRIBEREQUESTDATETZID,
				'' AS RESUBSCRIBEORIGIN,
				'' AS LASTCUSTOMERCHECKDATE,
				'' AS LASTCUSTOMERCHECKDATETZID,
				'' AS UNSUBSCRIBEREASON,
				'' AS WEBDATECOLLECTEDTZID,
				'' AS MODIFIEDDATETIME,
				'' AS MODIFIEDBY,
				'' AS CREATEDDATETIME,
				'' AS CREATEDBY,
				'' AS DATAAREAID,
				'' AS RECVERSION,
				'' AS RECID,
				'' AS CONVERSIONDATE,
				'' AS CONVERSIONDATETZID,
				'' AS EMAILCONFIRMEDDATETZID
			FROM #prospects
			
			INSERT INTO Import_Log
				([Operation_Date],[Source],[Schema_Name],[Table_Name],[Operation],[Operation_Count],[After_Count])
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'Prospects', 'INSERTED', @@ROWCOUNT, (SELECT COUNT(*) FROM Magento.Prospects)

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
