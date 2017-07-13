SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[SP_FB_TGCPlus_Weekly_Report_20170630]
as
Begin

/* TGCPlus Emails Exclusion list for Facebook FB */

Declare @SQL Nvarchar(2000),@Date varchar(8),@Dest Nvarchar(200),@File Nvarchar(200)

set @Date = convert(varchar, getdate(),112)


/* Create Directoty */
set @Dest = '\\File1\Groups\Marketing\Marketing Strategy and Analytics\Subscription\SnagFilms\FaceBookCampaigns\FBFiles_'+ @Date
EXEC master.dbo.xp_create_subdir @Dest



/*Subscribers who have not Cancelled*/
set @SQL =	'
			IF OBJECT_ID (''RFM..FB_TGCP_Subscribers_' + @Date +''')IS NOT NULL
			DROP TABLE rfm..FB_TGCP_Subscribers_' + @Date +'
			select distinct rtrim(ltrim(EmailAddress)) as EmailAddress
			into rfm..FB_TGCP_Subscribers_' + @Date +'
			from DataWarehouse.Marketing.TGCPlus_CustomerSignature 
			Where TransactionType <> ''Cancelled'''
Print @SQL
Exec  (@SQL)
set @File = 'FB_TGCP_Subscribers_' + @Date

/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @File, @Dest




/*Subscribers who have Cancelled more than 30 days ago*/
set @SQL =	'
			IF OBJECT_ID (''RFM..FB_TGCP_UnSubscribes_before30days_' + @Date +''')IS NOT NULL
			DROP TABLE rfm..FB_TGCP_UnSubscribes_before30days_' + @Date +'
			select distinct rtrim(ltrim(EmailAddress)) as EmailAddress
			into rfm..FB_TGCP_UnSubscribes_before30days_' + @Date +'
			from DataWarehouse.Marketing.TGCPlus_CustomerSignature 
			Where TransactionType = ''Cancelled''
			and datediff(d,subdate,getdate())>30
			'
Print @SQL
Exec  (@SQL)
set @File = 'FB_TGCP_UnSubscribes_before30days_' + @Date

/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @File, @Dest



/*Subscribers who have Cancelled less than or equal to 30 days */
set @SQL =	'
			IF OBJECT_ID (''RFM..FB_TGCP_UnSubscribes_last30days_' + @Date +''')IS NOT NULL
			DROP TABLE rfm..FB_TGCP_UnSubscribes_last30days_' + @Date +'
			select distinct rtrim(ltrim(EmailAddress)) as EmailAddress
			into rfm..FB_TGCP_UnSubscribes_last30days_' + @Date +'
			from DataWarehouse.Marketing.TGCPlus_CustomerSignature 
			Where TransactionType = ''Cancelled''
			and datediff(d,subdate,getdate())<=30
			'
Print @SQL
Exec  (@SQL)
set @File = 'FB_TGCP_UnSubscribes_last30days_' + @Date

/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @File, @Dest



/* So that we exclude test accounts and any other emails that we dont consider for TGCplus_Customersignature in last 30 days*/
set @SQL =	'
			IF OBJECT_ID (''RFM..FB_TGCP_Registrations_last30days_' + @Date +''')IS NOT NULL
			DROP TABLE rfm..FB_TGCP_Registrations_last30days_' + @Date +'
			select rtrim(ltrim(U.email))EmailAddress
			into rfm..FB_TGCP_Registrations_last30days_' + @Date +'
			from DataWarehouse.Archive.TGCPlus_user U
			left join DataWarehouse.Marketing.TGCPlus_CustomerSignature tcs
			on tcs.EmailAddress = u.Email 
			Where TCS.EmailAddress is null
			and U.entitled_dt is null 
			and U.email not like ''%+%''
			and U.email not like ''%plustest%''
			and datediff(d,joined,getdate())<=30 
			'

Print @SQL
Exec  (@SQL)
set @File = 'FB_TGCP_Registrations_last30days_' + @Date

/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @File, @Dest


/* So that we exclude test accounts and any other emails that we dont consider for TGCplus_Customersignature before 30 days*/
set @SQL =	'
			IF OBJECT_ID (''RFM..FB_TGCP_Registrations_before30days_' + @Date +''')IS NOT NULL
			DROP TABLE rfm..FB_TGCP_Registrations_before30days_' + @Date +'
			select rtrim(ltrim(U.email))EmailAddress
			into rfm..FB_TGCP_Registrations_before30days_' + @Date +'
			from DataWarehouse.Archive.TGCPlus_user U
			left join DataWarehouse.Marketing.TGCPlus_CustomerSignature tcs
			on tcs.EmailAddress = u.Email 
			Where TCS.EmailAddress is null
			and U.entitled_dt is null 
			and U.email not like ''%+%''
			and U.email not like ''%plustest%''
			and datediff(d,joined,getdate())>30 '

Print @SQL
Exec  (@SQL)
set @File = 'FB_TGCP_Registrations_before30days_' + @Date

/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @File, @Dest






/*Monthly paid customers*/
set @SQL =	'
			IF OBJECT_ID (''RFM..FB_TGCP_MonthlyPaidSubscribers_' + @Date +''')IS NOT NULL
			DROP TABLE rfm..FB_TGCP_MonthlyPaidSubscribers_' + @Date +'
			select distinct rtrim(ltrim(EmailAddress)) as EmailAddress
			into rfm..FB_TGCP_Subscribers_' + @Date +'
			from DataWarehouse.Marketing.TGCPlus_CustomerSignature 
			Where TransactionType <> ''Cancelled''
			and PaidFlag = 1 and SubType = ''MONTH'' '
			
Print @SQL
Exec  (@SQL)
set @File = 'FB_TGCP_MonthlyPaidSubscribers_' + @Date

/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @File, @Dest





/*Monthly paid customers*/
set @SQL =	'
			IF OBJECT_ID (''RFM..FB_TGCP_YearlyPaidSubscribers_' + @Date +''')IS NOT NULL
			DROP TABLE rfm..FB_TGCP_YearlyPaidSubscribers_' + @Date +'
			select distinct rtrim(ltrim(EmailAddress)) as EmailAddress
			into rfm..FB_TGCP_YearlyPaidSubscribers_' + @Date +'
			from DataWarehouse.Marketing.TGCPlus_CustomerSignature 
			Where TransactionType <> ''Cancelled''
			and PaidFlag = 1 and SubType = ''YEAR'' '
			
Print @SQL
Exec  (@SQL)
set @File = 'FB_TGCP_YearlyPaidSubscribers_' + @Date

/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @File, @Dest


DECLARE @p_body as nvarchar(max), @p_subject as nvarchar(max)
DECLARE @p_recipients as nvarchar(max), @p_profile_name as nvarchar(max)
SET @p_profile_name = N'DL datamart alerts'
SET @p_recipients = N'~dldatamartalerts@TEACHCO.com'
SET @p_subject = N'FaceBook TGCPlus Weekly Report'
SET @p_body = '<b>Facebook TGCPlus Weekly Report has been created</b>.  let others know that the report is ready here ' + @Dest
EXEC msdb.dbo.sp_send_dbmail
  @profile_name = @p_profile_name,
  @recipients = @p_recipients,
  @body = @p_body,
  @body_format = 'HTML',
  @subject = @p_subject

End 



GO
