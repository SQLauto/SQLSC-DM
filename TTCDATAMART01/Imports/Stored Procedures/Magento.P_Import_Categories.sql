SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
------------------------------------------------------------------------------------------------------------------------------------------
-- Description: Imports Category information from Magento
------------------------------------------------------------------------------------------------------------------------------------------
-- Issue#	Date		Modified By		Details
------------------------------------------------------------------------------------------------------------------------------------------
-- US2266	06/28/2016	BryantJ			Initial
------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Magento].[P_Import_Categories]
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @count INT = 0

	-- Error Variables
	DECLARE @error_description VARCHAR(MAX),
		@sp_name VARCHAR(MAX) = OBJECT_NAME(@@PROCID),
		@error_number INT,
		@error_line INT,
		@error_state VARCHAR(MAX),
		@error_severity VARCHAR(MAX),
		@user_name VARCHAR(MAX),
		@error_message VARCHAR(MAX)
	
	-- Table variable for course category
	DECLARE @Course_Category TABLE
		(Course_ID INT,
		Category_ID INT,
		Position INT,
		PRIMARY KEY (Course_ID, Category_ID)
		)

	-- Table variable for category basic information
	DECLARE @Category_Basic_Info TABLE
		(Category_ID INT PRIMARY KEY,
		Parent_ID INT,
		[Path] VARCHAR(255),
		[Level] INT,
		Children_Count INT
		)

	-- Table variable for category eav
	DECLARE @Category_EAV TABLE
		(Category_ID INT,
		Attribute_Code VARCHAR(255),
		Value VARCHAR(255)
		)		

	-- Table variable for category eav
	DECLARE @Category_EAV_Pivot TABLE
		(Category_ID INT,
		Name VARCHAR(255),
		Category_Title VARCHAR(255),
		Is_Active INT
		)		

	BEGIN TRY
		-- Get course category mapping
		INSERT @Course_Category
			(Course_ID,
			Category_ID,
			Position
			)
		SELECT course_id,
			category_id,
			position
		FROM OPENQUERY(MAGENTO,'SELECT cpe.course_id, cp.category_id, cp.position
								FROM catalog_category_product cp
									INNER JOIN catalog_product_entity cpe
										ON cp.product_id = cpe.entity_id
											AND cpe.type_id = ''configurable'';'
						) a

		-- Get category basic information
		INSERT @Category_Basic_Info
			(Category_ID,
			Parent_ID,
			[Path],
			[Level],
			Children_Count
			)
		SELECT Category_ID,
			Parent_ID,
			[Path],
			[Level],
			Children_Count
		FROM OPENQUERY(MAGENTO,'SELECT cce.entity_id AS ''category_id'', cce.parent_id, cce.path, cce.level, cce.children_count
								FROM catalog_category_entity cce;'
						) a

		-- Get category eav information
		INSERT @Category_EAV
			(Category_ID,
			Attribute_Code,
			Value 
			)
		SELECT Category_ID,
			Attribute_Code,
			Value 
		FROM OPENQUERY(MAGENTO,'SELECT ccet.entity_id AS ''category_id'', ea.attribute_code, ccet.value
								FROM catalog_category_entity_varchar ccet
									INNER JOIN eav_attribute ea
										ON ccet.attribute_id = ea.attribute_id	
 											AND attribute_code IN (''name'',''category_title'')
								
								UNION 
								SELECT ccet.entity_id AS ''category_id'', ea.attribute_code, ccet.value
								FROM catalog_category_entity_int ccet
									INNER JOIN eav_attribute ea
										ON ccet.attribute_id = ea.attribute_id	
 											AND attribute_code IN (''is_active'');'
						) a

		-- Pivot EAV data		-- Flatten EAV information into one unified category table(pivot)
		INSERT INTO @Category_EAV_Pivot
			( eav_pivot.Category_ID, 
			eav_pivot.name, 
			eav_pivot.category_title, 
			eav_pivot.is_active
			)
		SELECT eav_pivot.Category_ID, 
			eav_pivot.name, 
			eav_pivot.category_title, 
			eav_pivot.is_active
		FROM (	SELECT category_id, attribute_code, CONVERT(VARCHAR(255),value) AS value
				FROM @Category_EAV a
			) eav
			PIVOT ( MAX(eav.value) 
				FOR eav.attribute_code IN ([name], [category_title], [is_active]) 
				  ) AS eav_pivot
		ORDER BY category_id, Name, Category_Title, Is_Active


		-- Insert into import tables
		BEGIN TRANSACTION
			-- Delete/Insert into Magento.Course_Category table
			SELECT @count = COUNT(*) FROM Magento.Course_Category
			TRUNCATE TABLE Magento.Course_Category

			INSERT INTO Import_Log 
				(Operation_Date, Source, [Schema_Name], Table_Name, Operation, Operation_Count, After_Count)
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'Course_Category', 'DELETED', @count, (SELECT COUNT(*) FROM Magento.Course_Category)

			TRUNCATE TABLE Magento.Course_Category

			INSERT INTO Magento.Course_Category
				(Course_ID,
				Category_ID,
				Position
				)
			SELECT Course_ID,
				Category_ID,
				Position
			FROM @Course_Category

			INSERT INTO Import_Log
				([Operation_Date],[Source],[Schema_Name],[Table_Name],[Operation],[Operation_Count],[After_Count])
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'Course_Category', 'INSERTED', @@ROWCOUNT, (SELECT COUNT(*) FROM Magento.Course_Category)

			-- Delete/Insert into Magento.Category table
			SELECT @count = COUNT(*) FROM Magento.Category
			TRUNCATE TABLE Magento.Category

			INSERT INTO Import_Log 
				(Operation_Date, Source, [Schema_Name], Table_Name, Operation, Operation_Count, After_Count)
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'Category', 'DELETED', @count, (SELECT COUNT(*) FROM Magento.Category)

			INSERT INTO Magento.Category
				(Category_ID,
				Name,
				Category_Title,
				Is_Active,
				Parent_ID,
				[Path],
				[Level],
				Children_Count
				)
			SELECT cbi.Category_ID,
				cep.Name,
				cep.Category_Title,
				cep.Is_Active,
				cbi.Parent_ID,
				cbi.[Path],
				cbi.[Level],
				cbi.Children_Count
			FROM @Category_Basic_Info cbi
				INNER JOIN @Category_EAV_Pivot cep
					ON cbi.Category_ID = cep.Category_ID

			INSERT INTO Import_Log
				([Operation_Date],[Source],[Schema_Name],[Table_Name],[Operation],[Operation_Count],[After_Count])
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'Category', 'INSERTED', @@ROWCOUNT, (SELECT COUNT(*) FROM Magento.Category)


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
