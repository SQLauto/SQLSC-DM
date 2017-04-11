SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
------------------------------------------------------------------------------------------------------------------------------------------
-- Description: Imports Course information from Magento
------------------------------------------------------------------------------------------------------------------------------------------
-- Issue#	Date		Modified By		Details
------------------------------------------------------------------------------------------------------------------------------------------
-- US2564	11/01/2016	BryantJ			Initial
------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Magento].[P_Import_Courses]
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

	IF OBJECT_ID('tempdb.dbo.#catalog_product_entity', 'U') IS NOT NULL 
		DROP TABLE #catalog_product_entity
	CREATE TABLE #catalog_product_entity 
		(entity_id int NOT NULL,
		entity_type_id smallint NOT NULL,
		attribute_set_id smallint NOT NULL ,
		[type_id] varchar(32) NOT NULL ,
		sku varchar(64) ,
		has_options smallint NOT NULL ,
		required_options smallint NOT NULL ,
		created_at DATETIME NULL  ,
		updated_at DATETIME NULL ,
		course_id varchar(64) 
  		)

	IF OBJECT_ID('tempdb.dbo.#catalog_product_entity_datetime', 'U') IS NOT NULL 
		DROP TABLE #catalog_product_entity_datetime
	CREATE TABLE #catalog_product_entity_datetime 
		(value_id int NOT NULL,
		entity_type_id smallint NOT NULL,
		attribute_id smallint NOT NULL,
		store_id smallint NOT NULL,
		entity_id int NOT NULL,
		value datetime2
		)

	IF OBJECT_ID('tempdb.dbo.#catalog_product_entity_decimal', 'U') IS NOT NULL 
		DROP TABLE #catalog_product_entity_decimal
	CREATE TABLE #catalog_product_entity_decimal 
		(value_id int NOT NULL,
		entity_type_id smallint NOT NULL,
		attribute_id smallint NOT NULL,
		store_id smallint NOT NULL,
		entity_id int NOT NULL,
		value decimal(12,4) 
		)

	IF OBJECT_ID('tempdb.dbo.#catalog_product_entity_int', 'U') IS NOT NULL 
		DROP TABLE #catalog_product_entity_int
	CREATE TABLE #catalog_product_entity_int 
		(value_id int NOT NULL,
		entity_type_id int NOT NULL,
		attribute_id smallint NOT NULL,
		store_id smallint NOT NULL,
		entity_id int NOT NULL,
		value int DEFAULT NULL
		)

	IF OBJECT_ID('tempdb.dbo.#catalog_product_entity_text', 'U') IS NOT NULL 
		DROP TABLE #catalog_product_entity_text
	CREATE TABLE #catalog_product_entity_text 
		(value_id int NOT NULL,
		entity_type_id int NOT NULL,
		attribute_id smallint NOT NULL,
		store_id smallint NOT NULL,
		entity_id int NOT NULL,
		value text
		)

	IF OBJECT_ID('tempdb.dbo.#catalog_product_entity_varchar', 'U') IS NOT NULL 
		DROP TABLE #catalog_product_entity_varchar
	CREATE TABLE #catalog_product_entity_varchar 
		(value_id int NOT NULL,
		entity_type_id int NOT NULL,
		attribute_id smallint NOT NULL,
		store_id smallint NOT NULL,
		entity_id int NOT NULL,
		value varchar(255)
		)

	IF OBJECT_ID('tempdb.dbo.#eav_attribute', 'U') IS NOT NULL 
		DROP TABLE #eav_attribute
	CREATE TABLE #eav_attribute 
		(attribute_id smallint NOT NULL,
		entity_type_id smallint NOT NULL,
		attribute_code varchar(255),
		attribute_model varchar(255),
		backend_model varchar(255),
		backend_type varchar(8) NOT NULL,
		backend_table varchar(255),
		frontend_model varchar(255),
		frontend_input varchar(50),
		frontend_label varchar(255),
		frontend_class varchar(255),
		source_model varchar(255),
		is_required smallint NOT NULL,
		is_user_defined smallint NOT NULL,
		default_value text,
		is_unique smallint NOT NULL,
		note varchar(255) 
		)

	IF OBJECT_ID('tempdb.dbo.#eav_entity_type', 'U') IS NOT NULL 
		DROP TABLE #eav_entity_type
	CREATE TABLE #eav_entity_type 
		(entity_type_id smallint NOT NULL, -- AUTO_INCREMENT COMMENT 'Entity Type Id',
		entity_type_code varchar(50) NOT NULL, -- COMMENT 'Entity Type Code',
		entity_model varchar(255) NOT NULL, -- COMMENT 'Entity Model',
		attribute_model varchar(255), -- DEFAULT NULL COMMENT 'Attribute Model',
		entity_table varchar(255), -- DEFAULT NULL COMMENT 'Entity Table',
		value_table_prefix varchar(255), -- DEFAULT NULL COMMENT 'Value Table Prefix',
		entity_id_field varchar(255), -- DEFAULT NULL COMMENT 'Entity Id Field',
		is_data_sharing smallint NOT NULL, -- DEFAULT '1' COMMENT 'Defines Is Data Sharing',
		data_sharing_key varchar(100), -- DEFAULT 'default' COMMENT 'Data Sharing Key',
		default_attribute_set_id smallint NOT NULL, -- DEFAULT '0' COMMENT 'Default Attribute Set Id',
		increment_model varchar(255), -- DEFAULT '' COMMENT 'Increment Model',
		increment_per_store smallint NOT NULL, -- DEFAULT '0' COMMENT 'Increment Per Store',
		increment_pad_length smallint NOT NULL, -- DEFAULT '8' COMMENT 'Increment Pad Length',
		increment_pad_char varchar(1) NOT NULL, -- DEFAULT '0' COMMENT 'Increment Pad Char',
		additional_attribute_table varchar(255), -- DEFAULT '' COMMENT 'Additional Attribute Table',
		entity_attribute_collection varchar(255), -- DEFAULT NULL COMMENT 'Entity Attribute Collection',
		)

	IF OBJECT_ID('tempdb.dbo.#catalog_category_entity', 'U') IS NOT NULL 
		DROP TABLE #catalog_category_entity
	CREATE TABLE #catalog_category_entity (
	  entity_id int NOT NULL, -- COMMENT 'Entity ID',
	  entity_type_id smallint NOT NULL, -- COMMENT 'Entity Type ID',
	  attribute_set_id smallint NOT NULL, -- COMMENT 'Attriute Set ID',
	  parent_id int NOT NULL, -- COMMENT 'Parent Category ID',
	  created_at DATETIME NULL, -- DEFAULT NULL COMMENT 'Creation Time',
	  updated_at DATETIME NULL, -- DEFAULT NULL COMMENT 'Update Time',
	  path varchar(255) NOT NULL, -- COMMENT 'Tree Path',
	  position int NOT NULL, -- COMMENT 'Position',
	  level int NOT NULL, -- COMMENT 'Tree Level',
	  children_count int NOT NULL, -- COMMENT 'Child Count',
	  legacy_id int, -- DEFAULT NULL COMMENT 'Legacy category ID. Used for redirects from URLs /tgc/courses/courses.aspx?ps=ID.'
	  )

	IF OBJECT_ID('tempdb.dbo.#catalog_category_entity_int', 'U') IS NOT NULL 
		DROP TABLE #catalog_category_entity_int
	CREATE TABLE #catalog_category_entity_int 
		(value_id int NOT NULL, -- COMMENT 'Value ID',
		entity_type_id smallint NOT NULL, -- COMMENT 'Entity Type ID',
		attribute_id smallint NOT NULL, -- COMMENT 'Attribute ID',
		store_id smallint NOT NULL, -- COMMENT 'Store ID',
		entity_id int NOT NULL, -- COMMENT 'Entity ID',
		value int, -- DEFAULT NULL COMMENT 'Value'
		)

	IF OBJECT_ID('tempdb.dbo.#catalog_category_entity_text', 'U') IS NOT NULL 
		DROP TABLE #catalog_category_entity_text
	CREATE TABLE #catalog_category_entity_text 
		(value_id int NOT NULL, -- COMMENT 'Value ID',
		entity_type_id smallint NOT NULL, -- COMMENT 'Entity Type ID',
		attribute_id smallint NOT NULL, -- COMMENT 'Attribute ID',
		store_id smallint NOT NULL, -- COMMENT 'Store ID',
		entity_id int NOT NULL, -- COMMENT 'Entity ID',
		value text, -- COMMENT 'Value',
		) 

	IF OBJECT_ID('tempdb.dbo.#catalog_category_entity_varchar', 'U') IS NOT NULL 
		DROP TABLE #catalog_category_entity_varchar
	CREATE TABLE #catalog_category_entity_varchar 
		(value_id int NOT NULL, -- COMMENT 'Value ID',
		entity_type_id smallint NOT NULL, -- COMMENT 'Entity Type ID',
		attribute_id smallint NOT NULL, -- COMMENT 'Attribute ID',
		store_id smallint NOT NULL, -- COMMENT 'Store ID',
		entity_id int NOT NULL, -- COMMENT 'Entity ID',
		value varchar(255) DEFAULT NULL, -- COMMENT 'Value',
		)

	IF OBJECT_ID('tempdb.dbo.#lectures', 'U') IS NOT NULL 
		DROP TABLE #lectures
	CREATE TABLE #lectures 
		(id int NOT NULL,
		product_id int NOT NULL,
		audio_brightcove_id varchar(255),
		video_brightcove_id varchar(255),
		akamai_download_id varchar(255),
		professor varchar(255),
		original_lecture_number INT,
		lecture_number int NOT NULL,
		title varchar(255) NOT NULL,
		image VARCHAR(MAX),
		description VARCHAR(MAX),
		default_course_number varchar(255),
		audio_duration INT,
		video_duration INT,
		audio_available TINYINT NOT NULL,
		video_available TINYINT NOT NULL,
		audio_download_filesize float,
		video_download_filesize_pc float,
		video_download_filesize_mac float
		) 

	BEGIN TRY
		-------------------------------------------------------------------------------------------------------------
		-- catalog_product_entity
		-------------------------------------------------------------------------------------------------------------
		INSERT INTO #catalog_product_entity
			([entity_id],
			[entity_type_id],
			[attribute_set_id],
			[type_id],
			[sku],
			[has_options],
			[required_options],
			[created_at],
			[updated_at],
			[course_id])
		SELECT [entity_id],
			[entity_type_id],
			[attribute_set_id],
			[type_id],
			[sku],
			[has_options],
			[required_options],
			[created_at],
			[updated_at],
			[course_id]
		FROM OPENQUERY(Magento,
			'SELECT entity_id,
			  entity_type_id,
			  attribute_set_id,
			  type_id,
			  sku,
			  has_options,
			  required_options,
			  created_at,
			  updated_at,
			  course_id
			FROM catalog_product_entity')

		BEGIN TRANSACTION
			-- Delete/Insert into table
			SELECT @count = COUNT(*) FROM Magento.catalog_product_entity 
			TRUNCATE TABLE Magento.catalog_product_entity

			INSERT INTO Import_Log 
				(Operation_Date, Source, [Schema_Name], Table_Name, Operation, Operation_Count, After_Count)
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'catalog_product_entity', 'DELETED', @count, (SELECT COUNT(*) FROM Magento.catalog_product_entity)

			INSERT INTO Magento.catalog_product_entity
				([entity_id],
				[entity_type_id],
				[attribute_set_id],
				[type_id],
				[sku],
				[has_options],
				[required_options],
				[created_at],
				[updated_at],
				[course_id])
			SELECT [entity_id],
				[entity_type_id],
				[attribute_set_id],
				[type_id],
				[sku],
				[has_options],
				[required_options],
				[created_at],
				[updated_at],
				[course_id]
			FROM #catalog_product_entity

			INSERT INTO Import_Log
				([Operation_Date],[Source],[Schema_Name],[Table_Name],[Operation],[Operation_Count],[After_Count])
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'catalog_product_entity', 'INSERTED', @@ROWCOUNT, (SELECT COUNT(*) FROM Magento.catalog_product_entity)
		COMMIT TRANSACTION

		-------------------------------------------------------------------------------------------------------------
		-- catalog_product_entity_datetime
		-------------------------------------------------------------------------------------------------------------
		INSERT INTO #catalog_product_entity_datetime
			([value_id],
			[entity_type_id],
			[attribute_id],
			[store_id],
			[entity_id],
			[value])
		SELECT [value_id],
			[entity_type_id],
			[attribute_id],
			[store_id],
			[entity_id],
			[value]
		FROM OPENQUERY(Magento,
			'SELECT value_id,
				entity_type_id,
				attribute_id,
				store_id,
				entity_id,
				value
			FROM catalog_product_entity_datetime')

		BEGIN TRANSACTION
			-- Delete/Insert into table
			SELECT @count = COUNT(*) FROM Magento.catalog_product_entity_datetime 
			TRUNCATE TABLE Magento.catalog_product_entity_datetime

			INSERT INTO Import_Log 
				(Operation_Date, Source, [Schema_Name], Table_Name, Operation, Operation_Count, After_Count)
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'catalog_product_entity_datetime', 'DELETED', @count, (SELECT COUNT(*) FROM Magento.catalog_product_entity_datetime)

			INSERT INTO Magento.catalog_product_entity_datetime
				([value_id],
				[entity_type_id],
				[attribute_id],
				[store_id],
				[entity_id],
				[value])
			SELECT [value_id],
				[entity_type_id],
				[attribute_id],
				[store_id],
				[entity_id],
				[value]
			FROM #catalog_product_entity_datetime

			INSERT INTO Import_Log
				([Operation_Date],[Source],[Schema_Name],[Table_Name],[Operation],[Operation_Count],[After_Count])
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'catalog_product_entity_datetime', 'INSERTED', @@ROWCOUNT, (SELECT COUNT(*) FROM Magento.catalog_product_entity_datetime)
		COMMIT TRANSACTION

		-- catalog_product_entity_decimal
		INSERT INTO #catalog_product_entity_decimal
			([value_id],
			[entity_type_id],
			[attribute_id],
			[store_id],
			[entity_id],
			[value])
		SELECT [value_id],
			[entity_type_id],
			[attribute_id],
			[store_id],
			[entity_id],
			[value]
		FROM OPENQUERY(Magento,
			'SELECT value_id,
				entity_type_id,
				attribute_id,
				store_id,
				entity_id,
				value
			FROM catalog_product_entity_decimal')

		BEGIN TRANSACTION
			-- Delete/Insert into table
			SELECT @count = COUNT(*) FROM Magento.catalog_product_entity_decimal 
			TRUNCATE TABLE Magento.catalog_product_entity_decimal

			INSERT INTO Import_Log 
				(Operation_Date, Source, [Schema_Name], Table_Name, Operation, Operation_Count, After_Count)
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'catalog_product_entity_decimal', 'DELETED', @count, (SELECT COUNT(*) FROM Magento.catalog_product_entity_decimal)

			INSERT INTO Magento.catalog_product_entity_decimal
				([value_id],
				[entity_type_id],
				[attribute_id],
				[store_id],
				[entity_id],
				[value])
			SELECT [value_id],
				[entity_type_id],
				[attribute_id],
				[store_id],
				[entity_id],
				[value]
			FROM #catalog_product_entity_decimal

			INSERT INTO Import_Log
				([Operation_Date],[Source],[Schema_Name],[Table_Name],[Operation],[Operation_Count],[After_Count])
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'catalog_product_entity_decimal', 'INSERTED', @@ROWCOUNT, (SELECT COUNT(*) FROM Magento.catalog_product_entity_decimal)
		COMMIT TRANSACTION

		-------------------------------------------------------------------------------------------------------------
		-- catalog_product_entity_int
		-------------------------------------------------------------------------------------------------------------
		INSERT INTO #catalog_product_entity_int
			([value_id],
			[entity_type_id],
			[attribute_id],
			[store_id],
			[entity_id],
			[value])
		SELECT [value_id],
			[entity_type_id],
			[attribute_id],
			[store_id],
			[entity_id],
			[value]
		FROM OPENQUERY(Magento,
			'SELECT value_id,
				entity_type_id,
				attribute_id,
				store_id,
				entity_id,
				value
			FROM catalog_product_entity_int')

		BEGIN TRANSACTION
			-- Delete/Insert into table
			SELECT @count = COUNT(*) FROM Magento.catalog_product_entity_int 
			TRUNCATE TABLE Magento.catalog_product_entity_int

			INSERT INTO Import_Log 
				(Operation_Date, Source, [Schema_Name], Table_Name, Operation, Operation_Count, After_Count)
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'catalog_product_entity_int', 'DELETED', @count, (SELECT COUNT(*) FROM Magento.catalog_product_entity_int)

			INSERT INTO Magento.catalog_product_entity_int
				([value_id],
				[entity_type_id],
				[attribute_id],
				[store_id],
				[entity_id],
				[value])
			SELECT [value_id],
				[entity_type_id],
				[attribute_id],
				[store_id],
				[entity_id],
				[value]
			FROM #catalog_product_entity_int

			INSERT INTO Import_Log
				([Operation_Date],[Source],[Schema_Name],[Table_Name],[Operation],[Operation_Count],[After_Count])
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'catalog_product_entity_int', 'INSERTED', @@ROWCOUNT, (SELECT COUNT(*) FROM Magento.catalog_product_entity_int)
		COMMIT TRANSACTION

		-------------------------------------------------------------------------------------------------------------
		-- catalog_product_entity_text
		-------------------------------------------------------------------------------------------------------------
		INSERT INTO #catalog_product_entity_text
			([value_id],
			[entity_type_id],
			[attribute_id],
			[store_id],
			[entity_id],
			[value])
		SELECT [value_id],
			[entity_type_id],
			[attribute_id],
			[store_id],
			[entity_id],
			[value]
		FROM OPENQUERY(Magento,
			'SELECT value_id,
				entity_type_id,
				attribute_id,
				store_id,
				entity_id,
				value
			FROM catalog_product_entity_text')

		BEGIN TRANSACTION
			-- Delete/Insert into table
			SELECT @count = COUNT(*) FROM Magento.catalog_product_entity_text 
			TRUNCATE TABLE Magento.catalog_product_entity_text

			INSERT INTO Import_Log 
				(Operation_Date, Source, [Schema_Name], Table_Name, Operation, Operation_Count, After_Count)
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'catalog_product_entity_text', 'DELETED', @count, (SELECT COUNT(*) FROM Magento.catalog_product_entity_text)

			INSERT INTO Magento.catalog_product_entity_text
				([value_id],
				[entity_type_id],
				[attribute_id],
				[store_id],
				[entity_id],
				[value])
			SELECT [value_id],
				[entity_type_id],
				[attribute_id],
				[store_id],
				[entity_id],
				[value]
			FROM #catalog_product_entity_text

			INSERT INTO Import_Log
				([Operation_Date],[Source],[Schema_Name],[Table_Name],[Operation],[Operation_Count],[After_Count])
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'catalog_product_entity_text', 'INSERTED', @@ROWCOUNT, (SELECT COUNT(*) FROM Magento.catalog_product_entity_text)
		COMMIT TRANSACTION

		-------------------------------------------------------------------------------------------------------------
		-- catalog_product_entity_varchar
		-------------------------------------------------------------------------------------------------------------
		INSERT INTO #catalog_product_entity_varchar
			([value_id],
			[entity_type_id],
			[attribute_id],
			[store_id],
			[entity_id],
			[value])
		SELECT [value_id],
			[entity_type_id],
			[attribute_id],
			[store_id],
			[entity_id],
			[value]
		FROM OPENQUERY(Magento,
			'SELECT value_id,
				entity_type_id,
				attribute_id,
				store_id,
				entity_id,
				value
			FROM catalog_product_entity_varchar')

		BEGIN TRANSACTION
			-- Delete/Insert into table
			SELECT @count = COUNT(*) FROM Magento.catalog_product_entity_varchar 
			TRUNCATE TABLE Magento.catalog_product_entity_varchar

			INSERT INTO Import_Log 
				(Operation_Date, Source, [Schema_Name], Table_Name, Operation, Operation_Count, After_Count)
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'catalog_product_entity_varchar', 'DELETED', @count, (SELECT COUNT(*) FROM Magento.catalog_product_entity_varchar)

			INSERT INTO Magento.catalog_product_entity_varchar
				([value_id],
				[entity_type_id],
				[attribute_id],
				[store_id],
				[entity_id],
				[value])
			SELECT [value_id],
				[entity_type_id],
				[attribute_id],
				[store_id],
				[entity_id],
				[value]
			FROM #catalog_product_entity_varchar

			INSERT INTO Import_Log
				([Operation_Date],[Source],[Schema_Name],[Table_Name],[Operation],[Operation_Count],[After_Count])
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'catalog_product_entity_varchar', 'INSERTED', @@ROWCOUNT, (SELECT COUNT(*) FROM Magento.catalog_product_entity_varchar)
		COMMIT TRANSACTION

		-------------------------------------------------------------------------------------------------------------
		-- eav_attribute
		-------------------------------------------------------------------------------------------------------------
		INSERT INTO #eav_attribute
			([attribute_id],
			[entity_type_id],
			[attribute_code],
			[attribute_model],
			[backend_model],
			[backend_type],
			[backend_table],
			[frontend_model],
			[frontend_input],
			[frontend_label],
			[frontend_class],
			[source_model],
			[is_required],
			[is_user_defined],
			[default_value],
			[is_unique],
			[note])
		SELECT [attribute_id],
			[entity_type_id],
			[attribute_code],
			[attribute_model],
			[backend_model],
			[backend_type],
			[backend_table],
			[frontend_model],
			[frontend_input],
			[frontend_label],
			[frontend_class],
			[source_model],
			[is_required],
			[is_user_defined],
			[default_value],
			[is_unique],
			[note]
		FROM OPENQUERY(Magento,
			'SELECT attribute_id,
				entity_type_id,
				attribute_code,
				attribute_model,
				backend_model,
				backend_type,
				backend_table,
				frontend_model,
				frontend_input,
				frontend_label,
				frontend_class,
				source_model,
				is_required,
				is_user_defined,
				default_value,
				is_unique,
				note
			FROM eav_attribute')

		BEGIN TRANSACTION
			-- Delete/Insert into table
			SELECT @count = COUNT(*) FROM Magento.eav_attribute 
			TRUNCATE TABLE Magento.eav_attribute

			INSERT INTO Import_Log 
				(Operation_Date, Source, [Schema_Name], Table_Name, Operation, Operation_Count, After_Count)
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'eav_attribute', 'DELETED', @count, (SELECT COUNT(*) FROM Magento.eav_attribute)

			INSERT INTO Magento.eav_attribute
				([attribute_id],
				[entity_type_id],
				[attribute_code],
				[attribute_model],
				[backend_model],
				[backend_type],
				[backend_table],
				[frontend_model],
				[frontend_input],
				[frontend_label],
				[frontend_class],
				[source_model],
				[is_required],
				[is_user_defined],
				[default_value],
				[is_unique],
				[note])
			SELECT [attribute_id],
				[entity_type_id],
				[attribute_code],
				[attribute_model],
				[backend_model],
				[backend_type],
				[backend_table],
				[frontend_model],
				[frontend_input],
				[frontend_label],
				[frontend_class],
				[source_model],
				[is_required],
				[is_user_defined],
				[default_value],
				[is_unique],
				[note]
			FROM #eav_attribute

			INSERT INTO Import_Log
				([Operation_Date],[Source],[Schema_Name],[Table_Name],[Operation],[Operation_Count],[After_Count])
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'eav_attribute', 'INSERTED', @@ROWCOUNT, (SELECT COUNT(*) FROM Magento.eav_attribute)
		COMMIT TRANSACTION

		-------------------------------------------------------------------------------------------------------------
		-- eav_entity_type
		-------------------------------------------------------------------------------------------------------------
		INSERT INTO #eav_entity_type
			([entity_type_id],
			[entity_type_code],
			[entity_model],
			[attribute_model],
			[entity_table],
			[value_table_prefix],
			[entity_id_field],
			[is_data_sharing],
			[data_sharing_key],
			[default_attribute_set_id],
			[increment_model],
			[increment_per_store],
			[increment_pad_length],
			[increment_pad_char],
			[additional_attribute_table],
			[entity_attribute_collection])
		SELECT [entity_type_id],
			[entity_type_code],
			[entity_model],
			[attribute_model],
			[entity_table],
			[value_table_prefix],
			[entity_id_field],
			[is_data_sharing],
			[data_sharing_key],
			[default_attribute_set_id],
			[increment_model],
			[increment_per_store],
			[increment_pad_length],
			[increment_pad_char],
			[additional_attribute_table],
			[entity_attribute_collection]
		FROM OPENQUERY(Magento,
			'SELECT entity_type_id,
				entity_type_code,
				entity_model,
				attribute_model,
				entity_table,
				value_table_prefix,
				entity_id_field,
				is_data_sharing,
				data_sharing_key,
				default_attribute_set_id,
				increment_model,
				increment_per_store,
				increment_pad_length,
				increment_pad_char,
				additional_attribute_table,
				entity_attribute_collection
			FROM eav_entity_type')

		BEGIN TRANSACTION
			-- Delete/Insert into table
			SELECT @count = COUNT(*) FROM Magento.eav_entity_type 
			TRUNCATE TABLE Magento.eav_entity_type

			INSERT INTO Import_Log 
				(Operation_Date, Source, [Schema_Name], Table_Name, Operation, Operation_Count, After_Count)
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'eav_entity_type', 'DELETED', @count, (SELECT COUNT(*) FROM Magento.eav_entity_type)

			INSERT INTO Magento.eav_entity_type
				([entity_type_id],
				[entity_type_code],
				[entity_model],
				[attribute_model],
				[entity_table],
				[value_table_prefix],
				[entity_id_field],
				[is_data_sharing],
				[data_sharing_key],
				[default_attribute_set_id],
				[increment_model],
				[increment_per_store],
				[increment_pad_length],
				[increment_pad_char],
				[additional_attribute_table],
				[entity_attribute_collection])
			SELECT [entity_type_id],
				[entity_type_code],
				[entity_model],
				[attribute_model],
				[entity_table],
				[value_table_prefix],
				[entity_id_field],
				[is_data_sharing],
				[data_sharing_key],
				[default_attribute_set_id],
				[increment_model],
				[increment_per_store],
				[increment_pad_length],
				[increment_pad_char],
				[additional_attribute_table],
				[entity_attribute_collection]
			FROM #eav_entity_type

			INSERT INTO Import_Log
				([Operation_Date],[Source],[Schema_Name],[Table_Name],[Operation],[Operation_Count],[After_Count])
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'eav_entity_type', 'INSERTED', @@ROWCOUNT, (SELECT COUNT(*) FROM Magento.eav_entity_type)
		COMMIT TRANSACTION

		-------------------------------------------------------------------------------------------------------------
		-- catalog_category_entity
		-------------------------------------------------------------------------------------------------------------
		INSERT INTO #catalog_category_entity
			([entity_id],
			[entity_type_id],
			[attribute_set_id],
			[parent_id],
			[created_at],
			[updated_at],
			[path],
			[position],
			[level],
			[children_count],
			[legacy_id])
		SELECT [entity_id],
			[entity_type_id],
			[attribute_set_id],
			[parent_id],
			[created_at],
			[updated_at],
			[path],
			[position],
			[level],
			[children_count],
			[legacy_id]
		FROM OPENQUERY(Magento,
			'SELECT entity_id,
				entity_type_id,
				attribute_set_id,
				parent_id,
				created_at,
				updated_at,
				path,
				position,
				level,
				children_count,
				legacy_id
			FROM catalog_category_entity')

		BEGIN TRANSACTION
			-- Delete/Insert into table
			SELECT @count = COUNT(*) FROM Magento.catalog_category_entity 
			TRUNCATE TABLE Magento.catalog_category_entity

			INSERT INTO Import_Log 
				(Operation_Date, Source, [Schema_Name], Table_Name, Operation, Operation_Count, After_Count)
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'catalog_category_entity', 'DELETED', @count, (SELECT COUNT(*) FROM Magento.catalog_category_entity)

			INSERT INTO Magento.catalog_category_entity
				([entity_id],
				[entity_type_id],
				[attribute_set_id],
				[parent_id],
				[created_at],
				[updated_at],
				[path],
				[position],
				[level],
				[children_count],
				[legacy_id])
			SELECT [entity_id],
				[entity_type_id],
				[attribute_set_id],
				[parent_id],
				[created_at],
				[updated_at],
				[path],
				[position],
				[level],
				[children_count],
				[legacy_id]
			FROM #catalog_category_entity

			INSERT INTO Import_Log
				([Operation_Date],[Source],[Schema_Name],[Table_Name],[Operation],[Operation_Count],[After_Count])
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'catalog_category_entity', 'INSERTED', @@ROWCOUNT, (SELECT COUNT(*) FROM Magento.catalog_category_entity)
		COMMIT TRANSACTION

		-------------------------------------------------------------------------------------------------------------
		-- catalog_category_entity_int
		-------------------------------------------------------------------------------------------------------------
		INSERT INTO #catalog_category_entity_int
			([value_id],
			[entity_type_id],
			[attribute_id],
			[store_id],
			[entity_id],
			[value])
		SELECT [value_id],
			[entity_type_id],
			[attribute_id],
			[store_id],
			[entity_id],
			[value]
		FROM OPENQUERY(Magento,
			'SELECT value_id,
				entity_type_id,
				attribute_id,
				store_id,
				entity_id,
				value
			FROM catalog_category_entity_int')

		BEGIN TRANSACTION
			-- Delete/Insert into table
			SELECT @count = COUNT(*) FROM Magento.catalog_category_entity_int 
			TRUNCATE TABLE Magento.catalog_category_entity_int

			INSERT INTO Import_Log 
				(Operation_Date, Source, [Schema_Name], Table_Name, Operation, Operation_Count, After_Count)
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'catalog_category_entity_int', 'DELETED', @count, (SELECT COUNT(*) FROM Magento.catalog_category_entity_int)

			INSERT INTO Magento.catalog_category_entity_int
				([value_id],
				[entity_type_id],
				[attribute_id],
				[store_id],
				[entity_id],
				[value])
			SELECT [value_id],
				[entity_type_id],
				[attribute_id],
				[store_id],
				[entity_id],
				[value]
			FROM #catalog_category_entity_int

			INSERT INTO Import_Log
				([Operation_Date],[Source],[Schema_Name],[Table_Name],[Operation],[Operation_Count],[After_Count])
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'catalog_category_entity_int', 'INSERTED', @@ROWCOUNT, (SELECT COUNT(*) FROM Magento.catalog_category_entity_int)
		COMMIT TRANSACTION

		-------------------------------------------------------------------------------------------------------------
		-- catalog_category_entity_text
		-------------------------------------------------------------------------------------------------------------
		INSERT INTO #catalog_category_entity_text
			([value_id],
			[entity_type_id],
			[attribute_id],
			[store_id],
			[entity_id],
			[value])
		SELECT [value_id],
			[entity_type_id],
			[attribute_id],
			[store_id],
			[entity_id],
			[value]
		FROM OPENQUERY(Magento,
			'SELECT value_id,
				entity_type_id,
				attribute_id,
				store_id,
				entity_id,
				value
			FROM catalog_category_entity_text')

		BEGIN TRANSACTION
			-- Delete/Insert into table
			SELECT @count = COUNT(*) FROM Magento.catalog_category_entity_text 
			TRUNCATE TABLE Magento.catalog_category_entity_text

			INSERT INTO Import_Log 
				(Operation_Date, Source, [Schema_Name], Table_Name, Operation, Operation_Count, After_Count)
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'catalog_category_entity_text', 'DELETED', @count, (SELECT COUNT(*) FROM Magento.catalog_category_entity_text)

			INSERT INTO Magento.catalog_category_entity_text
				([value_id],
				[entity_type_id],
				[attribute_id],
				[store_id],
				[entity_id],
				[value])
			SELECT [value_id],
				[entity_type_id],
				[attribute_id],
				[store_id],
				[entity_id],
				[value]
			FROM #catalog_category_entity_text

			INSERT INTO Import_Log
				([Operation_Date],[Source],[Schema_Name],[Table_Name],[Operation],[Operation_Count],[After_Count])
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'catalog_category_entity_text', 'INSERTED', @@ROWCOUNT, (SELECT COUNT(*) FROM Magento.catalog_category_entity_text)
		COMMIT TRANSACTION

		-------------------------------------------------------------------------------------------------------------
		-- catalog_category_entity_varchar
		-------------------------------------------------------------------------------------------------------------
		INSERT INTO #catalog_category_entity_varchar
			([value_id],
			[entity_type_id],
			[attribute_id],
			[store_id],
			[entity_id],
			[value])
		SELECT [value_id],
			[entity_type_id],
			[attribute_id],
			[store_id],
			[entity_id],
			[value]
		FROM OPENQUERY(Magento,
			'SELECT value_id,
				entity_type_id,
				attribute_id,
				store_id,
				entity_id,
				value
			FROM catalog_category_entity_varchar')

		BEGIN TRANSACTION
			-- Delete/Insert into table
			SELECT @count = COUNT(*) FROM Magento.catalog_category_entity_varchar 
			TRUNCATE TABLE Magento.catalog_category_entity_varchar

			INSERT INTO Import_Log 
				(Operation_Date, Source, [Schema_Name], Table_Name, Operation, Operation_Count, After_Count)
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'catalog_category_entity_varchar', 'DELETED', @count, (SELECT COUNT(*) FROM Magento.catalog_category_entity_varchar)

			INSERT INTO Magento.catalog_category_entity_varchar
				([value_id],
				[entity_type_id],
				[attribute_id],
				[store_id],
				[entity_id],
				[value])
			SELECT [value_id],
				[entity_type_id],
				[attribute_id],
				[store_id],
				[entity_id],
				[value]
			FROM #catalog_category_entity_varchar

			INSERT INTO Import_Log
				([Operation_Date],[Source],[Schema_Name],[Table_Name],[Operation],[Operation_Count],[After_Count])
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'catalog_category_entity_varchar', 'INSERTED', @@ROWCOUNT, (SELECT COUNT(*) FROM Magento.catalog_category_entity_varchar)
		COMMIT TRANSACTION

		-------------------------------------------------------------------------------------------------------------
		-- lectures
		-------------------------------------------------------------------------------------------------------------
		INSERT INTO #lectures
			([id],
			[product_id],
			[audio_brightcove_id],
			[video_brightcove_id],
			[akamai_download_id],
			[professor],
			[original_lecture_number],
			[lecture_number],
			[title],
			[image],
			[description],
			[default_course_number],
			[audio_duration],
			[video_duration],
			[audio_available],
			[video_available],
			[audio_download_filesize],
			[video_download_filesize_pc],
			[video_download_filesize_mac])
		SELECT [id],
			[product_id],
			[audio_brightcove_id],
			[video_brightcove_id],
			[akamai_download_id],
			[professor],
			[original_lecture_number],
			[lecture_number],
			[title],
			[image],
			[description],
			[default_course_number],
			[audio_duration],
			[video_duration],
			[audio_available],
			[video_available],
			[audio_download_filesize],
			[video_download_filesize_pc],
			[video_download_filesize_mac]
		FROM OPENQUERY(Magento,
			'SELECT id,
				product_id,
				audio_brightcove_id,
				video_brightcove_id,
				akamai_download_id,
				professor,
				original_lecture_number,
				lecture_number,
				title,
				image,
				description,
				default_course_number,
				audio_duration,
				video_duration,
				audio_available,
				video_available,
				audio_download_filesize,
				video_download_filesize_pc,
				video_download_filesize_mac
			FROM lectures')

		BEGIN TRANSACTION
			-- Delete/Insert into table
			SELECT @count = COUNT(*) FROM Magento.lectures 
			TRUNCATE TABLE Magento.lectures

			INSERT INTO Import_Log 
				(Operation_Date, Source, [Schema_Name], Table_Name, Operation, Operation_Count, After_Count)
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'lectures', 'DELETED', @count, (SELECT COUNT(*) FROM Magento.lectures)

			INSERT INTO Magento.lectures
				([id],
				[product_id],
				[audio_brightcove_id],
				[video_brightcove_id],
				[akamai_download_id],
				[professor],
				[original_lecture_number],
				[lecture_number],
				[title],
				[image],
				[description],
				[default_course_number],
				[audio_duration],
				[video_duration],
				[audio_available],
				[video_available],
				[audio_download_filesize],
				[video_download_filesize_pc],
				[video_download_filesize_mac])
			SELECT [id],
				[product_id],
				[audio_brightcove_id],
				[video_brightcove_id],
				[akamai_download_id],
				[professor],
				[original_lecture_number],
				[lecture_number],
				[title],
				[image],
				[description],
				[default_course_number],
				[audio_duration],
				[video_duration],
				[audio_available],
				[video_available],
				[audio_download_filesize],
				[video_download_filesize_pc],
				[video_download_filesize_mac]
			FROM #lectures

			INSERT INTO Import_Log
				([Operation_Date],[Source],[Schema_Name],[Table_Name],[Operation],[Operation_Count],[After_Count])
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'lectures', 'INSERTED', @@ROWCOUNT, (SELECT COUNT(*) FROM Magento.lectures)
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
