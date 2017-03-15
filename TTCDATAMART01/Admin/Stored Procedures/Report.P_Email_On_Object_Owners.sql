SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


------------------------------------------------------------------------------------------------------------------------------------------
-- Description: Reports via email which objects are not owned by the passed in account
------------------------------------------------------------------------------------------------------------------------------------------
--	Issue#	Date		Modified By		Details
------------------------------------------------------------------------------------------------------------------------------------------
--	DI906	01/28/2015	BryantJ			Create					
------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Report].[P_Email_On_Object_Owners]
	@Recipients VARCHAR(MAX),
	@Approved_Owner VARCHAR(255)
AS
BEGIN
	SET NOCOUNT ON

	-- Email 
	DECLARE 
		@subject VARCHAR(MAX),
		@xml NVARCHAR(MAX),
		@body NVARCHAR(MAX) = ''

	-- Error 
	DECLARE @error_description VARCHAR(MAX),
		@sp_name VARCHAR(MAX),
		@error_number INT,
		@error_line INT,
		@error_state VARCHAR(MAX),
		@error_severity VARCHAR(MAX),
		@user_name VARCHAR(MAX),
		@error_message VARCHAR(MAX),
		@tran BIT
		
	BEGIN TRY
		SELECT @subject = 'DAX Database Ownership Report - ' + @@SERVERNAME

		-- Get information for the Database Ownership table
		SELECT @xml = 
					CAST( (
						SELECT td = Job_Name + '</td><td>'
									+ Owner_Name + '</td><td>'
									+ Is_Enabled
						FROM (	SELECT	name AS Job_Name,
										SUSER_SNAME(owner_sid) AS Owner_Name,
										CASE [enabled]
											WHEN 0 
												THEN 'Disabled'
											ELSE 'Enabled'
										END AS Is_Enabled
								FROM msdb..sysjobs WITH(NOLOCK)
								WHERE owner_sid != SUSER_SID(@Approved_Owner)
								--ORDER BY name
							) AS d
						ORDER BY d.Job_Name
					FOR XML PATH('tr'), TYPE ) AS VARCHAR(MAX))

		SET @body += '<H3>Job Ownership</H3>
					<table border = 1> 
					<tr>'
					+ '<th> Job Name </th> '
					+ '<th> Owner </th> '
					+ '<th> Is Enabled </th> '
					+ '</tr>'
					+ REPLACE( REPLACE( ISNULL(@xml,''), '&lt;', '<'), '&gt;', '>')
					+ '</table>'

		-- Get information for database owners
		SELECT @xml = 
					CAST( (
						SELECT td = Database_Name + '</td><td>'
									+ Owner_Name 
						FROM (	SELECT	name AS Database_Name,
										SUSER_SNAME(owner_sid) AS Owner_Name
								FROM master.sys.databases WITH(NOLOCK)
								WHERE owner_sid != SUSER_SID(@Approved_Owner)
									AND database_id > 4
							) AS d
						ORDER BY d.Database_Name
					FOR XML PATH('tr'), TYPE ) AS VARCHAR(MAX))

		SET @body += '<H3>Database Ownership</H3>
					<table border = 1> 
					<tr>'
					+ '<th> Database Name </th> '
					+ '<th> Owner </th> '
					+ '</tr>'
					+ REPLACE( REPLACE( ISNULL(@xml,''), '&lt;', '<'), '&gt;', '>')
					+ '</table>'
		

		SET @body = '<html><body>' + @body + '</body></html>'
		
		--Email
		EXEC msdb.dbo.sp_send_dbmail 
			@recipients = @Recipients,
			@subject = @subject,
			@body = @body,
			@body_format = 'HTML'

	END TRY

	BEGIN CATCH
	    SELECT
			@error_number = ERROR_NUMBER(),
			@error_severity = ERROR_SEVERITY(),
			@error_state = ERROR_STATE(),
			@sp_name = ERROR_PROCEDURE(),
			@error_line = ERROR_LINE(),
			@error_message = ERROR_MESSAGE(),
			@user_name = SYSTEM_USER

		SELECT @error_description = '[' + @sp_name + '] has failed.' + CHAR(13)
			+ 'Error Number: ' + CONVERT(VARCHAR,@error_number) 
			+ ', Line: ' + CONVERT(VARCHAR,@error_line)
			+ ', User: "' + @user_name + '"'
			+ ', Error Message: "' + @error_message + '"'
		
		RAISERROR(@error_description,@error_severity, @error_state)

	END CATCH

	SET NOCOUNT OFF

END

GO
