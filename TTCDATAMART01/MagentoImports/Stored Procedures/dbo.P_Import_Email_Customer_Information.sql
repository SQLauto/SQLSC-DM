SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
------------------------------------------------------------------------------------------------------------------------------------------
-- Description: Queries the Magento Read Only link to get the current email customer mapping information.
--				Will be run by the job "Import Data From Magento".
------------------------------------------------------------------------------------------------------------------------------------------
-- Issue#	Date		Modified By		Details
------------------------------------------------------------------------------------------------------------------------------------------
-- DI1021	06/09/2015	BryantJ			Initial
-- US1385	08/13/2015	BryantJ			Fix Error Handling
-- US1331	09/22/2015	BryantJ			Changed datatype from 150 to 250 for subscriber_email in [#Email_Customer]
------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[P_Import_Email_Customer_Information]
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @insert_count INT

	-- Error Variables
	DECLARE @error_description VARCHAR(MAX),
		@sp_name VARCHAR(MAX),
		@error_number INT,
		@error_line INT,
		@error_state VARCHAR(MAX),
		@error_severity VARCHAR(MAX),
		@user_name VARCHAR(MAX),
		@error_message VARCHAR(MAX),
		@tran BIT

	IF OBJECT_ID('tempdb.dbo.#Email_Customer', 'U') IS NOT NULL 
		DROP TABLE #Email_Customer
	CREATE TABLE [dbo].[#Email_Customer]
	(
		subscriber_email	VARCHAR(255) NULL,
		subscriber_status	INT NULL,
		dax_customer_id		VARCHAR(25) NULL,
		web_user_id			VARCHAR(64) NULL,
		website_country		VARCHAR(255) NULL,
		store_country		VARCHAR(255) NULL,
		magento_created_date		DATETIME NULL,
		magento_last_updated_date	DATETIME NULL
	) 
	
	BEGIN TRY

		-- Using a staging temporary table to minimize the time the transaction is open
		INSERT INTO #Email_Customer
			(subscriber_email,
			dax_customer_id,
			web_user_id,
			website_country,
			store_country,
			magento_created_date,
			magento_last_updated_date
			)
		SELECT email,
			dax_customer_id,
			web_user_id,
			website_country,
			store_country,
			magento_created_date,
			magento_last_updated_date
		FROM OPENQUERY(MAGENTO,
			'SELECT 
				ce.email,	
				ce.dax_customer_id,
				ce.web_user_id,
				cw.name AS website_country,
				cs.code AS store_country,
				ce.created_at AS magento_created_date,
				ce.updated_at AS magento_last_updated_date
			FROM magento.customer_entity ce
				LEFT JOIN magento.core_website cw
					ON ce.website_id = cw.website_id
				LEFT JOIN magento.core_store cs 
					ON ce.store_id = cs.store_id
			;')		-- Using a connection to Magento read only copy
			
						--AND ce.store_id = csg.default_store_id
		IF @@ROWCOUNT > 0
		BEGIN
			BEGIN TRANSACTION
				TRUNCATE TABLE dbo.Email_Customer_Information

				INSERT INTO dbo.Email_Customer_Information
					(subscriber_email,
						dax_customer_id,
						web_user_id,
						website_country,
						store_country,
						magento_created_date,
						magento_last_updated_date
					)
				SELECT subscriber_email,
					dax_customer_id,
					web_user_id,
					website_country,
					store_country,
					magento_created_date,
					magento_last_updated_date
				FROM #Email_Customer

				SET @insert_count = @@ROWCOUNT
			COMMIT TRANSACTION

			PRINT('Email_Customer_Information inserted count: ' + CONVERT(VARCHAR(10),@insert_count) )
		END	-- IF @@ROWCOUNT > 0
		ELSE
		BEGIN
			PRINT('There were no Email_Customer records to import.  SP ended with no work done.')
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

		SELECT @error_description = 
			'[' + @sp_name + '] has failed.' + CHAR(13)
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
