SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

------------------------------------------------------------------------------------------------------------------------------------------
-- Description: Queries the Magento Read Only link to get the current wishlist.
--				Will be run by the job "Import Data From Magento"
------------------------------------------------------------------------------------------------------------------------------------------
-- Issue#	Date		Modified By		Details
------------------------------------------------------------------------------------------------------------------------------------------
-- AS3751	04/15/2015	BryantJ			Initial
-- DI1021	06/19/2015	BryantJ			Fixing inserted count to be accurate
------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[P_Import_Wishlist]
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

	IF OBJECT_ID('tempdb.dbo.#Wishlist', 'U') IS NOT NULL 
		DROP TABLE #Wishlist
	CREATE TABLE [dbo].[#Wishlist]
	(
		[Wishlist_Id] [int] NULL,
		[Course_Id] [varchar](64) NULL,
		[Wishlist_Name] [varchar](255) NULL,
		[Magento_Customer_Id] [int] NULL,
		[Dax_Customer_Id] [varchar](25) NULL,
		[Customer_Name] [varchar](255) NULL,
		[Magento_Email_Address] [varchar](255) NULL,
		[Visibility] [smallint] NULL,
		[Item_Qty] [decimal](12, 4) NULL,
		[Wishlist_Description] [varchar](max) NULL,
		[Product_Qty] [decimal](12, 4) NULL,
		[Qty_Diff] [decimal](12, 4) NULL,
		[Item_Added_Date] [datetime] NULL,
		[Last_Modified_Date] [datetime] NULL
	) ON [PRIMARY] 
	
	BEGIN TRY

		-- Using a staging temporary table to minimize the time the transaction is open
		INSERT INTO #Wishlist
			([Wishlist_Id],
			[Course_Id],
			[Wishlist_Name],
			[Magento_Customer_Id],
			[Dax_Customer_Id],
			[Customer_Name],
			[Magento_Email_Address],
			[Visibility],
			[Item_Qty],
			[Wishlist_Description],
			[Product_Qty],
			[Qty_Diff],
			[Item_Added_Date],
			[Last_Modified_Date]
			)
		SELECT [Wishlist_Id],
			  [Course_Id],
			  [Wishlist_Name],
			  [Customer_Id],
			  [Dax_Id],
			  [Customer_Name],
			  [Email],
			  [Visibility],
			  [Item_Qty],
			  [Description],
			  [Product_Qty],
			  [Qty_Diff],
			  [Added_At],
			  [Updated_At]
		FROM OPENQUERY(MAGENTO,
			'SELECT 
			main_table.wishlist_id, 
			product_table.course_id, 
			IFNULL(name, ''Wishlist'') AS wishlist_name, 
			wishlist_table.customer_id AS customer_id, 
			customer_table.dax_customer_id AS dax_id, 
			CONCAT(IF(at_prefix.value IS NOT NULL AND at_prefix.value != '''', 
				CONCAT(LTRIM(RTRIM(at_prefix.value)), '' ''), ''''), LTRIM(RTRIM(at_firstname.value)), '' '', 
				IF(at_middlename.value IS NOT NULL AND at_middlename.value != '''', CONCAT(LTRIM(RTRIM(at_middlename.value)), '' ''), ''''), 
				LTRIM(RTRIM(at_lastname.value)), 
				IF(at_suffix.value IS NOT NULL AND at_suffix.value != '''', CONCAT('' '', LTRIM(RTRIM(at_suffix.value))), '''')) AS customer_name, 
			customer_table.email AS email, 
			wishlist_table.visibility AS visibility, 
			main_table.qty AS item_qty, 
			main_table.description, 
			item_stock.qty AS product_qty, 
			(item_stock.qty - main_table.qty) AS qty_diff,
			main_table.added_at, 
			wishlist_table.updated_at
			FROM wishlist_item AS main_table
			 INNER JOIN wishlist AS wishlist_table ON main_table.wishlist_id = wishlist_table.wishlist_id
			 INNER JOIN customer_entity AS customer_table ON customer_table.entity_id = wishlist_table.customer_id
			 LEFT JOIN customer_entity_varchar AS at_prefix ON at_prefix.entity_id = wishlist_table.customer_id AND at_prefix.attribute_id = 4
			 LEFT JOIN customer_entity_varchar AS at_firstname 
				ON at_firstname.entity_id = wishlist_table.customer_id AND at_firstname.attribute_id = 5
			 LEFT JOIN customer_entity_varchar AS at_middlename ON at_middlename.entity_id = wishlist_table.customer_id AND at_middlename.attribute_id = 6
			 LEFT JOIN customer_entity_varchar AS at_lastname ON at_lastname.entity_id = wishlist_table.customer_id AND at_lastname.attribute_id = 7
			 LEFT JOIN customer_entity_varchar AS at_suffix ON at_suffix.entity_id = wishlist_table.customer_id AND at_suffix.attribute_id = 8
			 LEFT JOIN cataloginventory_stock_item AS item_stock ON main_table.product_id = item_stock.product_id
			 INNER JOIN catalog_product_entity AS product_table ON product_table.entity_id = main_table.product_id
			')	-- Using a connection to Magento read only copy

		IF @@ROWCOUNT > 0
		BEGIN
			BEGIN TRANSACTION
				TRUNCATE TABLE Wishlist

				INSERT INTO Wishlist
					([Wishlist_Id],
					  [Course_Id],
					  [Wishlist_Name],
					  [Magento_Customer_Id],
					  [Dax_Customer_Id],
					  [Customer_Name],
					  [Magento_Email_Address],
					  [Visibility],
					  [Item_Qty],
					  [Wishlist_Description],
					  [Product_Qty],
					  [Qty_Diff],
					  [Item_Added_Date],
					  [Last_Modified_Date]
					  )
				SELECT [Wishlist_Id],
					  [Course_Id],
					  [Wishlist_Name],
					  [Magento_Customer_Id],
					  [DAX_Customer_Id],
					  [Customer_Name],
					  [Magento_Email_Address],
					  [Visibility],
					  [Item_Qty],
					  [Wishlist_Description],
					  [Product_Qty],
					  [Qty_Diff],
					  [Item_Added_Date],
					  [Last_Modified_Date]
				FROM #Wishlist
			
				SET @insert_count = @@ROWCOUNT
			COMMIT TRANSACTION

			PRINT('Wishlist inserted count: ' + CONVERT(VARCHAR(10),@insert_count) )
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

	END CATCH

	SET NOCOUNT OFF
END

GO
