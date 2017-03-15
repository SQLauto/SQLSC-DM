SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

------------------------------------------------------------------------------------------------------------------------------------------
-- Description: Create's a file for the Upsell Export process, this will be called by an SSIS package which is called by a job
------------------------------------------------------------------------------------------------------------------------------------------
-- Issue#	Date		Modified By		Details
------------------------------------------------------------------------------------------------------------------------------------------
-- US2269	07/20/2016	BryantJ			Initial
-- DETBD	09/13/2016	BryantJ			When there are no records that fit the last_updated_date criteria, changed to create file not error
------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Magento].[P_Get_Upsell_Customer_List]
	@Count_Out INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	
	DECLARE @last_file_created_date DATETIME,
		@last_user_update_date DATETIME,
		@count INT = 0,
		@now DATETIME = GETDATE()

	DECLARE @Output_Table TABLE
		(dax_customer_id VARCHAR(64),
		location_id INT,
		ranked_list_ids VARCHAR(64)
		)

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
		-- Get last time this file was created
		SELECT @last_file_created_date = MAX(Operation_Date)
		FROM dbo.Export_Log
		WHERE [Schema_Name] = 'Magento'
			AND Table_Name = 'tgc_upsell_customer_list' 
			AND Destination_Name = 'File'
			AND Export_Row_Count > 0

		-- Get last time the table was updated
		SELECT @last_user_update_date = MAX(last_user_update)
		FROM sys.dm_db_index_usage_stats
		WHERE database_id = DB_ID( 'Exports')
			AND OBJECT_ID=OBJECT_ID('magento.tgc_upsell_customer_list')
			AND index_id = 1 -- Primary Key

		IF @last_file_created_date IS NULL
		BEGIN
			SET  @last_file_created_date = '' 
		END
		
		IF @last_user_update_date IS NULL
		BEGIN
			SET  @last_user_update_date = GETDATE()
		END

		-- Check if there are any new updates since the last time the file was made
		IF (@last_file_created_date IS NULL
			OR @last_file_created_date < @last_user_update_date
			)
			AND EXISTS (SELECT 1
				FROM Magento.V_pivot_tgc_upsell_customer_list
				WHERE @last_file_created_date IS NULL
					OR Max_Last_Updated_Date BETWEEN @last_file_created_date AND @now
				)
		BEGIN

			INSERT INTO @Output_Table
				(dax_customer_id,
				location_id,
				ranked_list_ids
				)
			SELECT
				dax_customer_id,
				location_id,
				ranked_list_ids
			FROM Magento.V_pivot_tgc_upsell_customer_list
			WHERE @last_file_created_date IS NULL
				OR Max_Last_Updated_Date BETWEEN @last_file_created_date AND @now

			SELECT @Count = COUNT(*)
			FROM @Output_Table

			INSERT INTO @Output_Table
				(dax_customer_id,
				location_id,
				ranked_list_ids
				)
			SELECT 'Expected Records' AS dax_customer_id, 
				@Count AS location_id, 
				'' AS ranked_list_ids

			-- Table has records, return a data set with the count
			SELECT dax_customer_id AS dax_customer_id,
					location_id AS location_id,
					ranked_list_ids 	-- this is done to guarantee count is first
			FROM @Output_Table
			ORDER BY CASE 
						WHEN dax_customer_id = 'Expected Records' 
							THEN 0
						ELSE 1
						END
			
		END	-- IF @last_file_created_date < @last_user_update_date

		-- If there is data, output it
		ELSE IF NOT EXISTS (SELECT 1
						FROM Magento.V_pivot_tgc_upsell_customer_list
						)
		BEGIN
			RAISERROR('Upsell Export: Exports.Magento.tgc_upsell_customer_list is empty.',16,1)
		END

		ELSE	-- IF NOT @last_file_created_date < @last_user_update_date
		BEGIN
			-- No New Data, send empty file with zero count.
			SELECT dax_customer_id, location_id, ranked_list_ids	
			FROM (
				SELECT CONVERT(VARCHAR(64),'Expected Records') AS dax_customer_id, 
					@Count AS location_id, 
					CONVERT(VARCHAR(64),'') AS ranked_list_ids
				UNION
				SELECT TOP 0 dax_customer_id AS dax_customer_id,
					location_id, 
					ranked_list_ids
				FROM @Output_Table	-- this table is more of a placeholder so SSIS can read the datatypes
				) a
			ORDER BY CASE			-- this is done to guarantee count is first
						WHEN dax_customer_id = 'Expected Records' 
							THEN 0
						ELSE 1
						END
		END

		SET @Count_Out = @Count
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
