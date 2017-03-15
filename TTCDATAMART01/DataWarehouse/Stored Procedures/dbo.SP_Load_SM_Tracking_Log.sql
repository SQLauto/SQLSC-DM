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
 

Insert into archive.[SM_TRACKING_LOG] 
(EMAIL, DATESTAMP, TType, MailingID, UserID )

select EMAIL, DATESTAMP, TType, MailingID, UserID 
from Strongmailstats.dbo.SM_TRACKING_LOG t (nolock)
where DATESTAMP>@vDest_max_dt

select @Counts = isnull(Count(*),0) from archive.[SM_TRACKING_LOG] 
where DATESTAMP>@vDest_max_dt

/* Send Counts*/
		Begin

			DECLARE @p_body as nvarchar(max), @p_subject as nvarchar(max)
			DECLARE @p_recipients as nvarchar(max), @p_profile_name as nvarchar(max)
			SET @p_profile_name = N'DL datamart alerts'
			SET @p_recipients = N'~dldatamartalerts@TEACHCO.com'
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


--~dldatamartalerts@TEACHCO.com
 
GO
