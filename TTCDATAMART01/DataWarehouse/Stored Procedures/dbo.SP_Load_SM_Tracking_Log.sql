SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [dbo].[SP_Load_SM_Tracking_Log]
as

Begin

declare @vDest_max_dt datetime,@Counts varchar(20)

select 
@vDest_max_dt = isnull(MAX ([DateStamp]), '01/01/1900') 
from  archive.[SM_TRACKING_LOG] (nolock)


select @vDest_max_dt '@vDest_max_dt'

DECLARE @p_body as nvarchar(max), @p_subject as nvarchar(max), @p_recipients as nvarchar(max), @p_profile_name as nvarchar(max)

if exists 
 (select DATESTAMP, count(Hours)as Hours, Sum(Counts)as Counts 
			from ( select cast(DATESTAMP as date)DATESTAMP,DATEPART(hh,DATESTAMP)Hours
					,max( DATESTAMP)MaxDATESTAMP
					,count(*)Counts
					from Strongmailstats.dbo.SM_TRACKING_LOG t (nolock)
					where DATESTAMP >= cast(@vDest_max_dt as date) and  DATESTAMP < cast(dateadd(d,0,getdate()) as date)
					group by cast(DATESTAMP as date) ,DATEPART(hh,DATESTAMP) 
				)a
			group by DATESTAMP
			having count(Hours)<24 
			)

Begin

	declare @message varchar(2000) 
	set @message = '
					select DATESTAMP, count(Hours)as Hours, Sum(Counts)as Counts 
						from ( select cast(DATESTAMP as date)DATESTAMP,DATEPART(hh,DATESTAMP)Hours
						,max( DATESTAMP)MaxDATESTAMP
						,count(*)Counts
						from Strongmailstats.dbo.SM_TRACKING_LOG t (nolock)
						where DATESTAMP >= '''+ cast(cast(@vDest_max_dt as date) as varchar(10)) + '''and  DATESTAMP < cast(dateadd(d,0,getdate()) as date)
						group by cast(DATESTAMP as date) ,DATEPART(hh,DATESTAMP) 
					)a
				group by DATESTAMP
				having count(Hours)<24 

				'
	SET @p_profile_name = N'DL datamart alerts'
	SET @p_recipients = N'dldatamartalerts@TEACHCO.com'
	SET @p_subject = N'StrongMailStats Missing Data'
	SET @p_body = @message
	EXEC msdb.dbo.sp_send_dbmail
			  @profile_name = @p_profile_name,
			  @recipients = @p_recipients,
			  @body = @p_body,
			  @body_format = 'HTML',
			  @subject = @p_subject,
			  @query = @message,
		      @query_result_header = 0,
		      @append_query_error = 1,
			  @attach_query_result_as_file = 1,
			  @query_attachment_filename = 'Strongmailstats.txt',
			  @query_result_no_padding = 1,
			  @importance ='High'

Return 0

End

Insert into archive.[SM_TRACKING_LOG] 
(EMAIL, DATESTAMP, TType, MailingID, UserID )

select EMAIL, DATESTAMP, TType, MailingID, UserID 
from Strongmailstats.dbo.SM_TRACKING_LOG t (nolock)
where DATESTAMP>@vDest_max_dt

select @Counts = isnull(Count(*),0) from archive.[SM_TRACKING_LOG] 
where DATESTAMP>@vDest_max_dt

/* Send Counts*/
		Begin

			SET @p_profile_name = N'DL datamart alerts'
			SET @p_recipients = N'dldatamartalerts@TEACHCO.com'
			SET @p_subject = N'StrongMailStats Records Transfered'
			SET @p_body = '<b>StrongMailStats Records Transfered '+ @Counts +'</b>.'
			EXEC msdb.dbo.sp_send_dbmail
			  @profile_name = @p_profile_name,
			  @recipients = @p_recipients,
			  @body = @p_body,
			  @body_format = 'HTML',
			  @subject = @p_subject

		End


End

GO
