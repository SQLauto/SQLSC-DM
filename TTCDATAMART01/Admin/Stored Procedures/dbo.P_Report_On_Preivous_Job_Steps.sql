SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
------------------------------------------------------------------------------------------------------------------------------------------
-- Description: Looks at the job history of the job it's currently executed in to see if there were any failures/retries
------------------------------------------------------------------------------------------------------------------------------------------
-- Issue#	Date		Modified By		Details
------------------------------------------------------------------------------------------------------------------------------------------
-- AS3751	04/15/2015	BryantJ			Initial
-- US1972	04/04/2016	BryantJ			Fixed an issue that cropped up with retries showing up on the report multiple times
------------------------------------------------------------------------------------------------------------------------------------------
/* -- Make a new job step, that runs last, and use this code to call this SP(this works
   --	you can use something else, but make sure you test it throughly.

   -- Change the recipients list, but not the job_id value.
DECLARE @Recipients VARCHAR(255) = '~DLApplicationSupport@teachco.com;~dldatamartalerts@TEACHCO.com',
	@Job_ID UNIQUEIDENTIFIER = CONVERT(Uniqueidentifier,$(ESCAPE_NONE(JOBID))) 

EXEC dbo.P_Report_On_Preivous_Job_Steps
	@Recipients = @Recipients,
	@Job_ID = @Job_ID
*/
CREATE PROCEDURE [dbo].[P_Report_On_Preivous_Job_Steps]
	@Recipients VARCHAR(255),
	@Job_ID UNIQUEIDENTIFIER	-- you should supply this from within the job step using $(ESCAPE_NONE(JOBID))
AS
BEGIN
	SET NOCOUNT ON

	-- Email 
	DECLARE 
		@subject VARCHAR(MAX),
		@xml NVARCHAR(MAX),
		@body NVARCHAR(MAX) = ''

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

	DECLARE @Job_Statuses TABLE
	(	[step_id] int  NOT NULL ,   
		[step_name] nvarchar(128)  NOT NULL ,   
		[Run_Status] varchar(20)  NULL ,   
		[Run_Duration_In_Seconds] int  NOT NULL ,   
		[message] nvarchar(4000)  NULL ,   
		[retries_attempted] int  NOT NULL 
	)

	BEGIN TRY
		INSERT INTO @Job_Statuses
		SELECT 
			sjh.step_id, 
			sjh.step_name,
			CASE sjh.run_status
				WHEN 0
					THEN 'Failed'
				WHEN 1
					THEN 'Succeeded'
				WHEN 2
					THEN 'Retried'
			END AS Run_Status,
			a.Total_Run_Duration AS Run_Duration_In_Seconds,
			sjh.[message] AS Error_Messsage,
			CASE WHEN sjh.run_status = 1 THEN sjh.retries_attempted + 1
				ELSE sjh.retries_attempted
				END AS Run_Status
		FROM msdb..sysjobhistory sjh WITH(NOLOCK)
			INNER JOIN (
				SELECT TOP 1000
					sjh.step_id, 
					sjh.step_name,
					SUM(sjh.run_duration) AS Total_Run_Duration,
					MAX(sjh.instance_id) AS MAX_Instance_ID,
					SUM(CASE
							WHEN sjh.run_status IN (0,2) THEN 1
							ELSE 0
						END) AS Total_Attempts
				FROM msdb..sysjobs sj WITH(NOLOCK)
					INNER JOIN msdb..sysjobhistory sjh WITH(NOLOCK)
						ON sj.job_id = sjh.job_id
					INNER JOIN msdb..sysjobactivity sja WITH(NOLOCK)
						ON sj.job_id = sja.job_id
					CROSS APPLY (SELECT TOP 1 sjh2.run_date, sjh2.run_time		-- for the most recent step 0 get the run_date and time
										FROM msdb..sysjobhistory sjh2 WITH(NOLOCK)
										WHERE sj.job_id = sjh2.job_id
											AND sjh2.step_id = 1
										ORDER BY instance_id DESC
										) mrd
				WHERE sj.job_id = @Job_ID
					AND sjh.step_id != 0
					AND sjh.run_status IN (0,1,2)	-- 0 = Failed, 1 = Success,2 = Retried
					AND sja.stop_execution_date IS NULL
					AND (sjh.run_date > mrd.run_date
						OR	(sjh.run_date = mrd.run_date
							AND sjh.run_time >= mrd.run_time
							)
						)
				GROUP BY sjh.step_id, 
					sjh.step_name
			) a
				ON sjh.instance_id = a.MAX_Instance_ID
		WHERE sjh.run_status IN (0,2)
			OR (sjh.run_status IN (1)
				AND a.Total_Attempts > 0
				)

		-- If there are any retries or failured steps, send an email
		IF EXISTS (SELECT 1 FROM @Job_Statuses)
		BEGIN
			SELECT @subject = 'The Job "' + name + '" encountered step failures. (' + @@SERVERNAME + ')'
			FROM msdb..sysjobs sj WITH(NOLOCK)
			WHERE job_id = @Job_ID

			-- Structured this way so you can have multipled tables worth of data chained in a row with minimum modification.
			SELECT @xml = 
						CAST( (
							SELECT td = CONVERT(VARCHAR,step_id) + '</td><td>'
										+ step_name + '</td><td>'
										+ run_status + '</td><td>'
										+ [message] + '</td><td>'
										+ CONVERT(VARCHAR,run_duration_in_seconds) + '</td><td>'
										+ CONVERT(VARCHAR,retries_attempted)
							FROM (	SELECT	DISTINCT
										step_id,
										step_name,
										run_status,
										run_duration_in_seconds,
										[message],
										retries_attempted
									FROM @Job_Statuses 
								) AS d
							ORDER BY step_id, retries_attempted
						FOR XML PATH('tr'), TYPE ) AS VARCHAR(MAX))

			SET @body += '<H3>Job Step Statuses</H3>
						<table border = 1> 
						<tr>'
						+ '<th> Step ID </th> '
						+ '<th> Step Name </th> '
						+ '<th> Run Status </th> '
						+ '<th> Error Message </th> '
						+ '<th> Total Run Duration (Seconds) </th> '
						+ '<th> Retry Count </th> '
						+ '</tr>'
						+ REPLACE( REPLACE( ISNULL(@xml,''), '&lt;', '<'), '&gt;', '>')
						+ '</table>'
			-- End converting query results to HTML section, you can copy this section multiple times for multiple sets

			SET @body = '<body><html>' + @body + '</body></html>'
	
			--Email
			EXEC msdb.dbo.sp_send_dbmail 
				@recipients = @Recipients,
				@subject = @subject,
				@body = @body,
				@body_format = 'HTML'

		END	--IF EXISTS (SELECT 1 FROM @Job_Statuses)
		ELSE
		BEGIN
			PRINT('No steps failed.  No Email was sent.')
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

		RAISERROR(@error_description, @error_severity, @error_state)

	END CATCH

	SET NOCOUNT OFF
END

GO
