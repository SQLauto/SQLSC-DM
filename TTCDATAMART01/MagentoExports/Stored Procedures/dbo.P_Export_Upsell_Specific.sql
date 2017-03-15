SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

------------------------------------------------------------------------------------------------------------------------------------------
-- Description: Populates the table upsellCustomer for use by the export to magento process.
------------------------------------------------------------------------------------------------------------------------------------------
-- Issue#	Date		Modified By		Details
------------------------------------------------------------------------------------------------------------------------------------------
-- US844	06/30/2015	BryantJ			Initial. Based on the contents of spMagento_ExportCustomerUpsell and spMagento_CustomerUpsellSetup
------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[P_Export_Upsell_Specific] 
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @rows_inserted INT,
			@today DATETIME = GETDATE(),
			@current_count INT = 1

	-- Error Variables
	DECLARE @error_description VARCHAR(MAX),
		@sp_name VARCHAR(MAX),
		@error_number INT,
		@error_line INT,
		@error_state VARCHAR(MAX),
		@error_severity VARCHAR(MAX),
		@user_name VARCHAR(MAX),
		@error_message VARCHAR(MAX)
		
	CREATE TABLE #upsellcustomer
		(CustomerID NVARCHAR(20),
		SegmentGroup VARCHAR(40)
		)

	BEGIN TRY

		-- minimizing the time the transaction is open
		INSERT INTO #upsellcustomer
			(CustomerID,
			SegmentGroup
			)
		SELECT DISTINCT dw.CustomerID, 
			dw.SegmentGroup
		FROM [DataWarehouse].[Marketing].[Upsell_CustomerSegmentGroup] dw
			LEFT JOIN Upsellcustomer_Archive uca
				ON dw.CustomerID = uca.customerid
		WHERE dw.SegmentGroup != ISNULL(uca.SegmentGroup,'')

		BEGIN TRANSACTION
			TRUNCATE TABLE upsellCustomer

			INSERT INTO UpsellCustomer
				(dax_customer_id, 
				SegmentGroup
				)
			SELECT CustomerID, 
				SegmentGroup
			FROM #upsellcustomer

			SELECT @rows_inserted = @@ROWCOUNT
			INSERT INTO UpsellCustomer 
			VALUES ('Expected Records', @rows_inserted)
		COMMIT TRANSACTION							

		WHILE @current_count > 0
		BEGIN
			DELETE TOP(3000) FROM UpsellCustomer_Archive
			WHERE customerid IN (SELECT dax_customer_id FROM upsellcustomer)
			SET @current_count = @@ROWCOUNT					-- loop control
		END	

		IF EXISTS(SELECT * FROM Upsellcustomer
					WHERE dax_customer_id != 'Expected Records')
		BEGIN
			INSERT INTO UpsellCustomer_Archive
			SELECT *, 
				''--@today 
			FROM Upsellcustomer
			WHERE dax_customer_id != 'Expected Records'
		END
		ELSE
		BEGIN
			SELECT @today = MAX(dateupdated) FROM UpsellCustomer_Archive
	
			INSERT INTO UpsellCustomer
			SELECT customerid, 
				segmentgroup 
			FROM UpsellCustomer_Archive
			WHERE DateUpdated = @today
				AND customerid != 'Expected Records'
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
