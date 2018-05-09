SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Description: Archive MktWebCategoryCourses based on a specific date
------------------------------------------------------------------------------------------------------------------------------------------
-- Issue#	Date		Modified By		Details
------------------------------------------------------------------------------------------------------------------------------------------
-- US2101	04/11/2016	BryantJ			Initial
-- US3206	01/25/2018	BryantJ			Moved to Exports, renamed SP name and objects to the new EmailLander names
------------------------------------------------------------------------------------------------------------------------------------------         
CREATE PROCEDURE [Magento].[P_Archive_MktWebEmailLander]
	@Max_Date DATETIME	
AS
BEGIN 
	SET NOCOUNT ON

	DECLARE @date DATETIME = GETDATE()

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

		INSERT INTO Magento.MktWebEmailLander_Archive
			(CategoryID,
			CourseID,
			DisplayOrder,
			blnMarkdown,
			[message],
			expires,
			datemoved,
			date_added)
		SELECT CategoryID,
			CourseID,
			DisplayOrder,
			blnMarkdown,
			[message],
			expires, 
			@date AS datemoved, 
			date_added
		FROM Magento.MktWebEmailLander
		WHERE date_added <= @Max_Date

		DELETE FROM Magento.MktWebEmailLander 
		WHERE date_added <= @Max_Date

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
