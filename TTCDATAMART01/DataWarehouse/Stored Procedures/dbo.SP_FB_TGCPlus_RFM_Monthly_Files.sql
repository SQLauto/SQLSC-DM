SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
    
CREATE Proc [dbo].[SP_FB_TGCPlus_RFM_Monthly_Files]    
as    
Begin    
    
/* TGCPlus Emails by RFM segments */    
    
Declare @SQL Nvarchar(2000)
	,@Date varchar(8)
	,@Dest Nvarchar(200)
	,@File Nvarchar(200)
	,@rfmGroup varchar(30)     
    
--set @Date = convert(varchar, getdate(),112)
    
	set @Date = convert(varchar,getdate(),112)
    
/* Create Directoty */    
set @Dest = '\\File1\Groups\Marketing\Marketing Strategy and Analytics\Subscription\SnagFilms\FaceBookCampaigns\RFMLoad\FB_Plus_ByRFM_'+ @Date    
EXEC master.dbo.xp_create_subdir @Dest    
    
    
 --------------------------------------------------------   
/*Subscribers with High RF, High Monetary*/  
 --------------------------------------------------------

	set @rfmGroup = 'HighRFHighM'

	IF OBJECT_ID ('staging.FB_TGCPlus_RFM_HighRFHighM')IS NOT NULL    
	   DROP TABLE staging.FB_TGCPlus_RFM_HighRFHighM  

		Select b.EmailAddress, a.RFMGroup 
		into staging.FB_TGCPlus_RFM_HighRFHighM
		from marketing.tgcplus_rfm (nolock) a 
		left join marketing.TGCPlus_CustomerSignature (nolock) b on a.CustomerID = b.CustomerID
		where a.currentflag = 1
		and a.RFMGroup = 'High RF, High Monetary'

	set @SQL = '    
	   IF OBJECT_ID (''rfm..FB_TGCPlus_RFM_' + @rfmGroup + '_' + @Date +''')IS NOT NULL    
	   DROP TABLE rfm..FB_TGCPlus_RFM_' + @rfmGroup + '_' + @Date +'    

	   select *   
	   into rfm..FB_TGCPlus_RFM_' + @rfmGroup + '_' + @Date +'    
	   from staging.FB_TGCPlus_RFM_HighRFHighM'    
	Print @SQL    
	Exec  (@SQL)    
	set @File = 'FB_TGCPlus_RFM_' + @rfmGroup + '_' + @Date    
    
	/*Export @File to @Dest*/    
	exec staging.ExportTableToPipeText rfm, dbo, @File, @Dest    
    

 --------------------------------------------------------
/*Subscribers with High RF, Low Monetary*/  
 --------------------------------------------------------

	set @rfmGroup = 'HighRFLowM'

	IF OBJECT_ID ('staging.FB_TGCPlus_RFM_HighRFLowM')IS NOT NULL    
	   DROP TABLE staging.FB_TGCPlus_RFM_HighRFLowM  

		Select b.EmailAddress, a.RFMGroup 
		into staging.FB_TGCPlus_RFM_HighRFLowM
		from marketing.tgcplus_rfm (nolock) a 
		left join marketing.TGCPlus_CustomerSignature (nolock) b on a.CustomerID = b.CustomerID
		where a.currentflag = 1
		and a.RFMGroup = 'High RF, Low Monetary'

	set @SQL = '    
	   IF OBJECT_ID (''rfm..FB_TGCPlus_RFM_' + @rfmGroup + '_' + @Date +''')IS NOT NULL    
	   DROP TABLE rfm..FB_TGCPlus_RFM_' + @rfmGroup + '_' + @Date +'    

	   select *   
	   into rfm..FB_TGCPlus_RFM_' + @rfmGroup + '_' + @Date +'    
	   from staging.FB_TGCPlus_RFM_HighRFLowM'    
	Print @SQL    
	Exec  (@SQL)    
	set @File = 'FB_TGCPlus_RFM_' + @rfmGroup + '_' + @Date    
    
	/*Export @File to @Dest*/    
	exec staging.ExportTableToPipeText rfm, dbo, @File, @Dest    
	

 --------------------------------------------------------	
	/*Subscribers with Low RF, High Monetary*/  
 --------------------------------------------------------

	set @rfmGroup = 'LowRFHighM'

	IF OBJECT_ID ('staging.FB_TGCPlus_RFM_LowRFHighM')IS NOT NULL    
	   DROP TABLE staging.FB_TGCPlus_RFM_LowRFHighM  

		Select b.EmailAddress, a.RFMGroup 
		into staging.FB_TGCPlus_RFM_LowRFHighM
		from marketing.tgcplus_rfm (nolock) a 
		left join marketing.TGCPlus_CustomerSignature (nolock) b on a.CustomerID = b.CustomerID
		where a.currentflag = 1
		and a.RFMGroup = 'Low RF, High Monetary'

	set @SQL = '    
	   IF OBJECT_ID (''rfm..FB_TGCPlus_RFM_' + @rfmGroup + '_' + @Date +''')IS NOT NULL    
	   DROP TABLE rfm..FB_TGCPlus_RFM_' + @rfmGroup + '_' + @Date +'    

	   select *   
	   into rfm..FB_TGCPlus_RFM_' + @rfmGroup + '_' + @Date +'    
	   from staging.FB_TGCPlus_RFM_LowRFHighM'    
	Print @SQL    
	Exec  (@SQL)    
	set @File = 'FB_TGCPlus_RFM_' + @rfmGroup + '_' + @Date    
    
	/*Export @File to @Dest*/    
	exec staging.ExportTableToPipeText rfm, dbo, @File, @Dest     
   
    
 --------------------------------------------------------
/*Subscribers with Low RF, Low Monetary*/  
 --------------------------------------------------------

	set @rfmGroup = 'LowRFLowM'

	IF OBJECT_ID ('staging.FB_TGCPlus_RFM_LowRFLowM')IS NOT NULL    
	   DROP TABLE staging.FB_TGCPlus_RFM_LowRFLowM  

		Select b.EmailAddress, a.RFMGroup 
		into staging.FB_TGCPlus_RFM_LowRFLowM
		from marketing.tgcplus_rfm (nolock) a 
		left join marketing.TGCPlus_CustomerSignature (nolock) b on a.CustomerID = b.CustomerID
		where a.currentflag = 1
		and a.RFMGroup = 'Low RF, Low Monetary'

	set @SQL = '    
	   IF OBJECT_ID (''rfm..FB_TGCPlus_RFM_' + @rfmGroup + '_' + @Date +''')IS NOT NULL    
	   DROP TABLE rfm..FB_TGCPlus_RFM_' + @rfmGroup + '_' + @Date +'    

	   select *   
	   into rfm..FB_TGCPlus_RFM_' + @rfmGroup + '_' + @Date +'    
	   from staging.FB_TGCPlus_RFM_LowRFLowM'    
	Print @SQL    
	Exec  (@SQL)    
	set @File = 'FB_TGCPlus_RFM_' + @rfmGroup + '_' + @Date    
    
	/*Export @File to @Dest*/    
	exec staging.ExportTableToPipeText rfm, dbo, @File, @Dest    
	    

DECLARE @p_body as nvarchar(max), @p_subject as nvarchar(max), @p_query as nvarchar(max)
DECLARE @p_recipients as nvarchar(max), @p_profile_name as nvarchar(max)    
SET @p_profile_name = N'DL datamart alerts'
--set @p_query = 
SET @p_recipients = N'~dldatamartalerts@TEACHCO.com;durmusm@teachco.com'    
--SET @p_recipients = N'ramanujamp@TEACHCO.com'    
SET @p_subject = N'FaceBook TGCPlus RFM Files'    
--SET @p_body = '<b>Facebook TGCPlus RFM files have been created under this folder: </b><br/>' + char(13) + char(10) + @Dest    
SET @p_body = '<b>Facebook TGCPlus RFM files have been created under this folder: </b><br/>' + @Dest
EXEC msdb.dbo.sp_send_dbmail    
  @profile_name = @p_profile_name,    
  @recipients = @p_recipients,    
  --@query = @p_query,
  @body = @p_body,    
  @body_format = 'HTML',    
  @subject = @p_subject    
    
End     
    
GO
