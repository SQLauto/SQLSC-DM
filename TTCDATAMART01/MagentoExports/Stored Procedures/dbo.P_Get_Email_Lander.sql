SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Description: Captures the data used by an SSIS package to create the Email Landers export file
------------------------------------------------------------------------------------------------------------------------------------------
-- Issue#	Date		Modified By		Details
------------------------------------------------------------------------------------------------------------------------------------------
--			12/23/2013	JonesT			Initial
--			03/18/2014	JonesT			Updated to go to the archive table if no records are in the landing page data - since this is running 
--											and archiving for current, pre-Magento data.
--			05/12/2014	JonesT			Updated for UTC-8 output - all nvarchar to nvarcha                          
--			09/15/2014	JonesT			Updated to continuously send most recent data - so that all data can be up to date.
--			09/30/2014	JonesT			Moved to Production
--			07/15/2015	BryantJ			Refactor/reformat/TryCatch/Rename from spMagento_ExportEmailLander, converted to read procedure
--	US1898	03/02/2016	BryantJ			Convert to using table variables instead of temp tables(makes it easier to call from SSIS in 2014)
--	US2101	04/06/2016	BryantJ			Remove section that pulls data from Archive as well as current, and all objects used only by it
------------------------------------------------------------------------------------------------------------------------------------------         
CREATE PROCEDURE [dbo].[P_Get_Email_Lander]
AS
BEGIN 
	SET NOCOUNT ON

	DECLARE @total_rows INT

	DECLARE @tmpEmailLander TABLE
		(email_category NVARCHAR(50), 
		email_courseid INT, 
		email_displayorder FLOAT, 
		markdown_flag BIT, 
		special_message VARCHAR(500), 
		date_expires NVARCHAR(15)
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
		INSERT INTO @tmpEmailLander
		SELECT email_category = CONVERT(NVARCHAR(50),CategoryID), 
			email_courseid = courseid, 
			email_displayorder = displayorder, 
			markdown_flag = blnMarkdown, 
			special_message = '"' + REPLACE(ISNULL(MESSAGE,''),'"','""') + '"', 
			date_expires = CONVERT(NVARCHAR(15), expires,101) 
		FROM Reports..MktWebCategoryCourses

		/* 2014-09-15 tlj End Changes */
		SELECT @total_rows = COUNT(*) FROM @tmpEmailLander

		INSERT INTO @tmpEmailLander 
		VALUES(N'Expected Records',@total_rows,0,0,'','')

		SELECT email_category AS email_landing_category,
			email_courseid AS course_id,
			email_displayorder AS displayorder,
			markdown_flag,
			special_message AS lander_msg,
			date_expires AS category_expires
		FROM @tmpEmailLander tel
		ORDER BY date_expires, email_category, email_displayorder

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
