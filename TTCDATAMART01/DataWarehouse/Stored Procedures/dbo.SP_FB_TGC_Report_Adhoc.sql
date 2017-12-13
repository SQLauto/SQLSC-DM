SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[SP_FB_TGC_Report_Adhoc]
as
Begin

/* TGCPlus Emails Exclusion list for Facebook FB */

Declare @SQL Nvarchar(2000),@Date varchar(8),@Dest Nvarchar(200),@Dest2 Nvarchar(200),@File Nvarchar(200), @Year varchar(4)

set @Date = convert(varchar, getdate(),112)

set  @Year = year(@Date)

/* Create Directoty */
set @Dest = '\\File1\Groups\Marketing\Marketing Strategy and Analytics\FaceBook\FaceBookCampaigns\FBFiles_'+ @Date
EXEC master.dbo.xp_create_subdir @Dest


--set @Dest = '\\File1\Groups\Marketing\Marketing Strategy and Analytics\FaceBook\FaceBookCampaigns'
------------------------------------------------------------------------------------------------------------------------------

 /*TGC Active Multis – Emailable*/
set @SQL =	'
			IF OBJECT_ID (''RFM..FBTGC_Active_Multi_Emailable_' + @Date +''')IS NOT NULL
			DROP TABLE rfm..FBTGC_Active_Multi_Emailable_' + @Date +'
			select distinct EPC.Email as Emailaddress
			into rfm..FBTGC_Active_Multi_Emailable_' + @Date +'
			from DataWarehouse.Marketing.CampaignCustomerSignature CCS  
			inner join DataWarehouse.Marketing.epc_preference EPC 
			on EPC.CustomerID = CCS.CustomerID  
			where EPC.Subscribed = 1 /*Emailable*/ 
			AND CCS.NewSeg IN (3,4,5,8,9,10) /*Active Multi*/'

Print @SQL
Exec  (@SQL)
set @File = 'FBTGC_Active_Multi_Emailable_' + @Date

/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @File, @Dest




------------------------------------------------------------------------------------------------------------------------------

 /*TGC Active Multis – Non-emailable*/
set @SQL =	'
			IF OBJECT_ID (''RFM..FBTGC_Active_Multi_NonEmailable_' + @Date +''')IS NOT NULL
			DROP TABLE rfm..FBTGC_Active_Multi_NonEmailable_' + @Date +'
			select distinct EPC.Email as Emailaddress
			into rfm..FBTGC_Active_Multi_NonEmailable_' + @Date +'
			from DataWarehouse.Marketing.CampaignCustomerSignature CCS  
			inner join DataWarehouse.Marketing.epc_preference EPC 
			on EPC.CustomerID = CCS.CustomerID  
			where EPC.Subscribed = 0  /*NonEmailable*/ 
			AND CCS.NewSeg IN (3,4,5,8,9,10) /*Active Multi*/'

Print @SQL
Exec  (@SQL)
set @File = 'FBTGC_Active_Multi_NonEmailable_' + @Date

/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @File, @Dest



 
------------------------------------------------------------------------------------------------------------------------------

 /*TGC Inctive Multis – Emailable*/
set @SQL =	'
			IF OBJECT_ID (''RFM..FBTGC_InAct_Multi_Emailable_' + @Date +''')IS NOT NULL
			DROP TABLE rfm..FBTGC_InAct_Multi_Emailable_' + @Date +'
			select distinct EPC.Email as Emailaddress
			into rfm..FBTGC_InAct_Multi_Emailable_' + @Date +'
			from DataWarehouse.Marketing.CampaignCustomerSignature CCS  
			inner join DataWarehouse.Marketing.epc_preference EPC 
			on EPC.CustomerID = CCS.CustomerID  
			where EPC.Subscribed = 1							/*Emailable*/ 
			AND CCS.NewSeg IN (select distinct newseg
							from mapping.rfmcombolookup
							where CustomerSegmentFnl = ''Inactive_Multi'') /*Inactive Multi*/'

Print @SQL
Exec  (@SQL)
set @File = 'FBTGC_InAct_Multi_Emailable_' + @Date

/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @File, @Dest




------------------------------------------------------------------------------------------------------------------------------

 /*TGC Inactive Multis – Non-emailable*/
set @SQL =	'
			IF OBJECT_ID (''RFM..FBTGC_InAct_Multi_NonEmailable_' + @Date +''')IS NOT NULL
			DROP TABLE rfm..FBTGC_InAct_Multi_NonEmailable_' + @Date +'
			select distinct EPC.Email as Emailaddress
			into rfm..FBTGC_InAct_Multi_NonEmailable_' + @Date +'
			from DataWarehouse.Marketing.CampaignCustomerSignature CCS  
			inner join DataWarehouse.Marketing.epc_preference EPC 
			on EPC.CustomerID = CCS.CustomerID  
			where EPC.Subscribed = 0  /*NonEmailable*/ 
			AND CCS.NewSeg IN (select distinct newseg
							from mapping.rfmcombolookup
							where CustomerSegmentFnl = ''Inactive_Multi'') /*Inactive Multi*/'

Print @SQL
Exec  (@SQL)
set @File = 'FBTGC_InAct_Multi_NonEmailable_' + @Date

/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @File, @Dest



------------------------------------------------------------------------------------------------------------------------------


 /*TGC Deep Inctive Multis – Emailable*/
set @SQL =	'
			IF OBJECT_ID (''RFM..FBTGC_DpInAct_Multi_Emailable_' + @Date +''')IS NOT NULL
			DROP TABLE rfm..FBTGC_DpInAct_Multi_Emailable_' + @Date +'
			select distinct EPC.Email as Emailaddress
			into rfm..FBTGC_DpInAct_Multi_Emailable_' + @Date +'
			from DataWarehouse.Marketing.CampaignCustomerSignature CCS  
			inner join DataWarehouse.Marketing.epc_preference EPC 
			on EPC.CustomerID = CCS.CustomerID  
			where EPC.Subscribed = 1							/*Emailable*/ 
			AND CCS.NewSeg IN (select distinct newseg
							from mapping.rfmcombolookup
							where CustomerSegmentFnl = ''DeepInactive_Multi'') /*Inactive Multi*/'

Print @SQL
Exec  (@SQL)
set @File = 'FBTGC_DpInAct_Multi_Emailable_' + @Date

/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @File, @Dest




------------------------------------------------------------------------------------------------------------------------------

 /*TGC Deep Inactive Multis – Non-emailable*/
set @SQL =	'
			IF OBJECT_ID (''RFM..FBTGC_DpInAct_Multi_NonEmailable_' + @Date +''')IS NOT NULL
			DROP TABLE rfm..FBTGC_DpInAct_Multi_NonEmailable_' + @Date +'
			select distinct EPC.Email as Emailaddress
			into rfm..FBTGC_DpInAct_Multi_NonEmailable_' + @Date +'
			from DataWarehouse.Marketing.CampaignCustomerSignature CCS  
			inner join DataWarehouse.Marketing.epc_preference EPC 
			on EPC.CustomerID = CCS.CustomerID  
			where EPC.Subscribed = 0  /*NonEmailable*/ 
			AND CCS.NewSeg IN (select distinct newseg
							from mapping.rfmcombolookup
							where CustomerSegmentFnl = ''DeepInactive_Multi'') /*Inactive Multi*/'

Print @SQL
Exec  (@SQL)
set @File = 'FBTGC_DpInAct_Multi_NonEmailable_' + @Date

/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @File, @Dest



------------------------------------------------------------------------------------------------------------------------------

 /*TGC Active Singles – Emailable*/
set @SQL =	'
			IF OBJECT_ID (''RFM..FBTGC_Active_Single_Emailable_' + @Date +''')IS NOT NULL
			DROP TABLE rfm..FBTGC_Active_Single_Emailable_' + @Date +'
			select distinct EPC.Email as Emailaddress
			into rfm..FBTGC_Active_Single_Emailable_' + @Date +'
			from DataWarehouse.Marketing.CampaignCustomerSignature CCS  
			inner join DataWarehouse.Marketing.epc_preference EPC 
			on EPC.CustomerID = CCS.CustomerID  
			where EPC.Subscribed = 1 /*Emailable*/ 
			AND CCS.NewSeg IN (select distinct newseg
							from mapping.rfmcombolookup
							where CustomerSegmentFnl = ''Active_Single'') /*Inactive Single*/'

Print @SQL
Exec  (@SQL)
set @File = 'FBTGC_Active_Single_Emailable_' + @Date

/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @File, @Dest




------------------------------------------------------------------------------------------------------------------------------

 /*TGC Active Singles – Non-emailable*/
set @SQL =	'
			IF OBJECT_ID (''RFM..FBTGC_Active_Single_NonEmailable_' + @Date +''')IS NOT NULL
			DROP TABLE rfm..FBTGC_Active_Single_NonEmailable_' + @Date +'
			select distinct EPC.Email as Emailaddress
			into rfm..FBTGC_Active_Single_NonEmailable_' + @Date +'
			from DataWarehouse.Marketing.CampaignCustomerSignature CCS  
			inner join DataWarehouse.Marketing.epc_preference EPC 
			on EPC.CustomerID = CCS.CustomerID  
			where EPC.Subscribed = 0  /*NonEmailable*/ 
			AND CCS.NewSeg IN (select distinct newseg
							from mapping.rfmcombolookup
							where CustomerSegmentFnl = ''Active_Single'') /*Inactive Single*/'

Print @SQL
Exec  (@SQL)
set @File = 'FBTGC_Active_Single_NonEmailable_' + @Date

/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @File, @Dest



 
------------------------------------------------------------------------------------------------------------------------------

 /*TGC Inctive Singles – Emailable*/
set @SQL =	'
			IF OBJECT_ID (''RFM..FBTGC_InAct_Single_Emailable_' + @Date +''')IS NOT NULL
			DROP TABLE rfm..FBTGC_InAct_Single_Emailable_' + @Date +'
			select distinct EPC.Email as Emailaddress
			into rfm..FBTGC_InAct_Single_Emailable_' + @Date +'
			from DataWarehouse.Marketing.CampaignCustomerSignature CCS  
			inner join DataWarehouse.Marketing.epc_preference EPC 
			on EPC.CustomerID = CCS.CustomerID  
			where EPC.Subscribed = 1							/*Emailable*/ 
			AND CCS.NewSeg IN (select distinct newseg
							from mapping.rfmcombolookup
							where CustomerSegmentFnl = ''Inactive_Single'') /*Inactive Single*/'

Print @SQL
Exec  (@SQL)
set @File = 'FBTGC_InAct_Single_Emailable_' + @Date

/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @File, @Dest




------------------------------------------------------------------------------------------------------------------------------

 /*TGC Inactive Singles – Non-emailable*/
set @SQL =	'
			IF OBJECT_ID (''RFM..FBTGC_InAct_Single_NonEmailable_' + @Date +''')IS NOT NULL
			DROP TABLE rfm..FBTGC_InAct_Single_NonEmailable_' + @Date +'
			select distinct EPC.Email as Emailaddress
			into rfm..FBTGC_InAct_Single_NonEmailable_' + @Date +'
			from DataWarehouse.Marketing.CampaignCustomerSignature CCS  
			inner join DataWarehouse.Marketing.epc_preference EPC 
			on EPC.CustomerID = CCS.CustomerID  
			where EPC.Subscribed = 0  /*NonEmailable*/ 
			AND CCS.NewSeg IN (select distinct newseg
							from mapping.rfmcombolookup
							where CustomerSegmentFnl = ''Inactive_Single'') /*Inactive Single*/'

Print @SQL
Exec  (@SQL)
set @File = 'FBTGC_InAct_Single_NonEmailable_' + @Date

/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @File, @Dest



------------------------------------------------------------------------------------------------------------------------------


 /*TGC Deep Inctive Singles – Emailable*/
set @SQL =	'
			IF OBJECT_ID (''RFM..FBTGC_DpInAct_Single_Emailable_' + @Date +''')IS NOT NULL
			DROP TABLE rfm..FBTGC_DpInAct_Single_Emailable_' + @Date +'
			select distinct EPC.Email as Emailaddress
			into rfm..FBTGC_DpInAct_Single_Emailable_' + @Date +'
			from DataWarehouse.Marketing.CampaignCustomerSignature CCS  
			inner join DataWarehouse.Marketing.epc_preference EPC 
			on EPC.CustomerID = CCS.CustomerID  
			where EPC.Subscribed = 1							/*Emailable*/ 
			AND CCS.NewSeg IN (select distinct newseg
							from mapping.rfmcombolookup
							where CustomerSegmentFnl = ''DeepInactive_Single'') /*Inactive Single*/'

Print @SQL
Exec  (@SQL)
set @File = 'FBTGC_DpInAct_Single_Emailable_' + @Date

/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @File, @Dest




------------------------------------------------------------------------------------------------------------------------------

 /*TGC Deep Inactive Singles – Non-emailable*/
set @SQL =	'
			IF OBJECT_ID (''RFM..FBTGC_DpInAct_Single_NonEmailable_' + @Date +''')IS NOT NULL
			DROP TABLE rfm..FBTGC_DpInAct_Single_NonEmailable_' + @Date +'
			select distinct EPC.Email as Emailaddress
			into rfm..FBTGC_DpInAct_Single_NonEmailable_' + @Date +'
			from DataWarehouse.Marketing.CampaignCustomerSignature CCS  
			inner join DataWarehouse.Marketing.epc_preference EPC 
			on EPC.CustomerID = CCS.CustomerID  
			where EPC.Subscribed = 0  /*NonEmailable*/ 
			AND CCS.NewSeg IN (select distinct newseg
							from mapping.rfmcombolookup
							where CustomerSegmentFnl = ''DeepInactive_Single'') /*Inactive Single*/'

Print @SQL
Exec  (@SQL)
set @File = 'FBTGC_DpInAct_Single_NonEmailable_' + @Date

/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @File, @Dest



------------------------------------------------------------------------------------------------------------------------------

DECLARE @p_body as nvarchar(max), @p_subject as nvarchar(max)
DECLARE @p_recipients as nvarchar(max), @p_profile_name as nvarchar(max)
SET @p_profile_name = N'DL datamart alerts'
SET @p_recipients = N'~dldatamartalerts@TEACHCO.com'
SET @p_subject = N'FaceBook TGC Weekly Report'
SET @p_body = '<b>Facebook TGC Weekly Report has been created</b>.  let others know that the report is ready here ' + @Dest
EXEC msdb.dbo.sp_send_dbmail
  @profile_name = @p_profile_name,
  @recipients = @p_recipients,
  @body = @p_body,
  @body_format = 'HTML',
  @subject = @p_subject

End 


GO
