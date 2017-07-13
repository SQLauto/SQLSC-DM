SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
------------------------------------------------------------------------------------------------------------------------------------------
-- Description: Imports Sets information from Magento
------------------------------------------------------------------------------------------------------------------------------------------
-- Issue#	Date		Modified By		Details
------------------------------------------------------------------------------------------------------------------------------------------
-- US2652	03/14/2017	BryantJ			Initial
------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Magento].[P_Import_Sets]
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
	DECLARE @Sets TABLE
		(course_id VARCHAR(64),
			set_course_ids VARCHAR(255)
		)

	BEGIN TRY
		-- Get Sets
		INSERT @Sets
			(Course_ID,
			set_course_ids
			)
		SELECT course_id,
			set_course_ids
		FROM OPENQUERY(MAGENTO,'SELECT cpe.course_id, 
									cpev.value AS set_course_ids
								FROM catalog_product_entity cpe
									LEFT JOIN catalog_product_entity_varchar cpev
										ON cpe.entity_id = cpev.entity_id
											AND cpev.attribute_id = 238
								WHERE cpe.attribute_set_id = 12
									AND cpe.type_id = ''configurable'';'
						) a

		-- Insert into import tables
		BEGIN TRANSACTION
			-- Delete/Insert into Magento.Course_Category table
			SELECT @count = COUNT(*) FROM Magento.Sets
			TRUNCATE TABLE Magento.Sets

			INSERT INTO Import_Log 
				(Operation_Date, Source, [Schema_Name], Table_Name, Operation, Operation_Count, After_Count)
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'Sets', 'DELETED', @count, (SELECT COUNT(*) FROM Magento.Sets)

			INSERT INTO Magento.Sets
				(course_id,
				set_course_ids
				)
			SELECT course_id,
				set_course_ids
			FROM @Sets

			INSERT INTO Import_Log
				([Operation_Date],[Source],[Schema_Name],[Table_Name],[Operation],[Operation_Count],[After_Count])
			SELECT 
				GETDATE(), @sp_name, 'Magento', 'Sets', 'INSERTED', @@ROWCOUNT, (SELECT COUNT(*) FROM Magento.Sets)
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
