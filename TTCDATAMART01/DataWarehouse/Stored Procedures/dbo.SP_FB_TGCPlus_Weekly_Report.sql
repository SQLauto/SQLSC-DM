SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
          
CREATE Proc [dbo].[SP_FB_TGCPlus_Weekly_Report]          
as          
Begin          
          
/* TGCPlus Emails Exclusion list for Facebook FB */          
          
Declare @SQL Nvarchar(2000),@Date varchar(8),@Dest Nvarchar(200),@File Nvarchar(200)          
          
set @Date = convert(varchar, getdate(),112)          
          
          
/* Create Directoty */          
set @Dest = '\\File1\Groups\Marketing\Marketing Strategy and Analytics\Subscription\SnagFilms\FaceBookCampaigns\FBFiles_'+ @Date          
EXEC master.dbo.xp_create_subdir @Dest          
          
          
          
/*Subscribers who have not Cancelled*/          
set @SQL = '          
   IF OBJECT_ID (''RFM..FB_TGCP_Subscribers_' + @Date +''')IS NOT NULL          
   DROP TABLE rfm..FB_TGCP_Subscribers_' + @Date +'          
   select distinct rtrim(ltrim(C.EmailAddress)) as EmailAddress, o.FirstName,o.LastName,o.City,o.State,o.ZIP          
   into rfm..FB_TGCP_Subscribers_' + @Date +'          
   from DataWarehouse.Marketing.TGCPlus_CustomerSignature  c          
   left join datawarehouse.mapping.tgcplus_customeroverlay o           
   on o.customerid = c.customerid          
   Where TransactionType <> ''Cancelled'''          
Print @SQL          
Exec  (@SQL)          
set @File = 'FB_TGCP_Subscribers_' + @Date          
          
/*Export @File to @Dest*/          
exec staging.ExportTableToPipeText rfm, dbo, @File, @Dest          
          
/* So that we exclude test accounts and any other emails that we dont consider for TGCplus_Customersignature in last 30 days*/          
set @SQL = '          
   IF OBJECT_ID (''RFM..FB_TGCP_Subscribers_last30days_' + @Date +''')IS NOT NULL          
   DROP TABLE rfm..FB_TGCP_Subscribers_last30days_' + @Date +'          
   select distinct rtrim(ltrim(U.email)) as EmailAddress, o.FirstName,o.LastName,o.City,o.State,o.ZIP          
   into rfm..FB_TGCP_Subscribers_last30days_' + @Date +'          
   from DataWarehouse.Archive.TGCPlus_user U          
   left join DataWarehouse.Marketing.TGCPlus_CustomerSignature tcs          
   on tcs.EmailAddress = u.Email           
   left join datawarehouse.mapping.tgcplus_customeroverlay o           
   on o.customerid = tcs.customerid          
   Where TransactionType <> ''Cancelled''        
   and U.email not like ''%+%''          
   and U.email not like ''%plustest%''          
   and datediff(d,entitled_dt,getdate())<=30           
   '          
          
Print @SQL          
Exec  (@SQL)          
set @File = 'FB_TGCP_Subscribers_last30days_' + @Date            
      
/*Export @File to @Dest*/          
exec staging.ExportTableToPipeText rfm, dbo, @File, @Dest              
          
/*Subscribers who have Cancelled more than 30 days ago*/          
set @SQL = '          
   IF OBJECT_ID (''RFM..FB_TGCP_UnSubscribes_Morethan30days_' + @Date +''')IS NOT NULL          
   DROP TABLE rfm..FB_TGCP_UnSubscribes_Morethan30days_' + @Date +'          
   select distinct rtrim(ltrim(C.EmailAddress)) as EmailAddress, o.FirstName,o.LastName,o.City,o.State,o.ZIP          
   into rfm..FB_TGCP_UnSubscribes_Morethan30days_' + @Date +'          
   from DataWarehouse.Marketing.TGCPlus_CustomerSignature  c          
   left join datawarehouse.mapping.tgcplus_customeroverlay o           
   on o.customerid = c.customerid          
   Where TransactionType = ''Cancelled''          
   and datediff(d,subdate,getdate())>30          
   '          
Print @SQL          
Exec  (@SQL)          
set @File = 'FB_TGCP_UnSubscribes_Morethan30days_' + @Date          
          
/*Export @File to @Dest*/          
exec staging.ExportTableToPipeText rfm, dbo, @File, @Dest          
          
          
          
/*Subscribers who have Cancelled less than or equal to 30 days */          
set @SQL = '          
   IF OBJECT_ID (''RFM..FB_TGCP_UnSubscribes_last30days_' + @Date +''')IS NOT NULL          
   DROP TABLE rfm..FB_TGCP_UnSubscribes_last30days_' + @Date +'          
   select distinct rtrim(ltrim(C.EmailAddress)) as EmailAddress, o.FirstName,o.LastName,o.City,o.State,o.ZIP          
   into rfm..FB_TGCP_UnSubscribes_last30days_' + @Date +'          
   from DataWarehouse.Marketing.TGCPlus_CustomerSignature  c          
   left join datawarehouse.mapping.tgcplus_customeroverlay o           
   on o.customerid = c.customerid          
   Where TransactionType = ''Cancelled''          
   and datediff(d,subdate,getdate())<=30          
   '          
Print @SQL          
Exec  (@SQL)          
set @File = 'FB_TGCP_UnSubscribes_last30days_' + @Date          
          
/*Export @File to @Dest*/          
exec staging.ExportTableToPipeText rfm, dbo, @File, @Dest          
          
          
          
/* So that we exclude test accounts and any other emails that we dont consider for TGCplus_Customersignature in last 30 days*/          
set @SQL = '          
   IF OBJECT_ID (''RFM..FB_TGCP_Registrations_last30days_' + @Date +''')IS NOT NULL          
   DROP TABLE rfm..FB_TGCP_Registrations_last30days_' + @Date +'          
   select distinct rtrim(ltrim(U.email)) as EmailAddress, o.FirstName,o.LastName,o.City,o.State,o.ZIP          
   into rfm..FB_TGCP_Registrations_last30days_' + @Date +'          
   from DataWarehouse.Archive.TGCPlus_user U          
   left join DataWarehouse.Marketing.TGCPlus_CustomerSignature tcs          
   on tcs.EmailAddress = u.Email           
   left join datawarehouse.mapping.tgcplus_customeroverlay o           
   on o.customerid = tcs.customerid          
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
set @SQL = '          
   IF OBJECT_ID (''RFM..FB_TGCP_Registrations_Morethan30days_' + @Date +''')IS NOT NULL          
   DROP TABLE rfm..FB_TGCP_Registrations_Morethan30days_' + @Date +'          
   select distinct rtrim(ltrim(U.email)) as EmailAddress, o.FirstName,o.LastName,o.City,o.State,o.ZIP          
   into rfm..FB_TGCP_Registrations_Morethan30days_' + @Date +'          
   from DataWarehouse.Archive.TGCPlus_user U          
   left join DataWarehouse.Marketing.TGCPlus_CustomerSignature tcs          
   on tcs.EmailAddress = u.Email           
   left join datawarehouse.mapping.tgcplus_customeroverlay o           
   on o.customerid = tcs.customerid          
   Where TCS.EmailAddress is null          
   and U.entitled_dt is null           
   and U.email not like ''%+%''          
   and U.email not like ''%plustest%''          
   and datediff(d,joined,getdate())>30 '          
          
Print @SQL          
Exec  (@SQL)          
set @File = 'FB_TGCP_Registrations_Morethan30days_' + @Date          
          
/*Export @File to @Dest*/          
exec staging.ExportTableToPipeText rfm, dbo, @File, @Dest          
          
          
--14 days

/* So that we exclude test accounts and any other emails that we dont consider for TGCplus_Customersignature in last 14 days*/          
set @SQL = '          
   IF OBJECT_ID (''RFM..FB_TGCP_Registrations_last14days_' + @Date +''')IS NOT NULL          
   DROP TABLE rfm..FB_TGCP_Registrations_last14days_' + @Date +'          
   select distinct rtrim(ltrim(U.email)) as EmailAddress, o.FirstName,o.LastName,o.City,o.State,o.ZIP          
   into rfm..FB_TGCP_Registrations_last14days_' + @Date +'          
   from DataWarehouse.Archive.TGCPlus_user U          
   left join DataWarehouse.Marketing.TGCPlus_CustomerSignature tcs          
   on tcs.EmailAddress = u.Email           
   left join datawarehouse.mapping.tgcplus_customeroverlay o           
   on o.customerid = tcs.customerid          
   Where TCS.EmailAddress is null          
   and U.entitled_dt is null           
   and U.email not like ''%+%''          
   and U.email not like ''%plustest%''          
   and datediff(d,joined,getdate())<=14           
   '          
          
Print @SQL          
Exec  (@SQL)          
set @File = 'FB_TGCP_Registrations_last14days_' + @Date          
          
/*Export @File to @Dest*/          
exec staging.ExportTableToPipeText rfm, dbo, @File, @Dest             
          
          
          
/*Monthly paid customers*/          
set @SQL = '          
   IF OBJECT_ID (''RFM..FB_TGCP_MonthlyPaidSubscribers_' + @Date +''')IS NOT NULL          
   DROP TABLE rfm..FB_TGCP_MonthlyPaidSubscribers_' + @Date +'          
   select distinct rtrim(ltrim(c.EmailAddress)) as EmailAddress, o.FirstName,o.LastName,o.City,o.State,o.ZIP          
   into rfm..FB_TGCP_MonthlyPaidSubscribers_' + @Date +'          
   from DataWarehouse.Marketing.TGCPlus_CustomerSignature c          
   left join datawarehouse.mapping.tgcplus_customeroverlay o           
   on o.customerid = c.customerid          
   Where TransactionType <> ''Cancelled''          
   and PaidFlag = 1 and SubType = ''MONTH'' '          
             
Print @SQL          
Exec  (@SQL)      
set @File = 'FB_TGCP_MonthlyPaidSubscribers_' + @Date          
          
/*Export @File to @Dest*/          
exec staging.ExportTableToPipeText rfm, dbo, @File, @Dest          
          
          
          
          
          
/*Monthly paid customers*/          
set @SQL = '          
   IF OBJECT_ID (''RFM..FB_TGCP_YearlyPaidSubscribers_' + @Date +''')IS NOT NULL          
   DROP TABLE rfm..FB_TGCP_YearlyPaidSubscribers_' + @Date +'          
   select distinct rtrim(ltrim(c.EmailAddress)) as EmailAddress, o.FirstName,o.LastName,o.City,o.State,o.ZIP          
   into rfm..FB_TGCP_YearlyPaidSubscribers_' + @Date +'          
   from DataWarehouse.Marketing.TGCPlus_CustomerSignature c          
   left join datawarehouse.mapping.tgcplus_customeroverlay o           
   on o.customerid = c.customerid          
   Where TransactionType <> ''Cancelled''          
   and PaidFlag = 1 and SubType = ''YEAR'' '          
             
Print @SQL          
Exec  (@SQL)          
set @File = 'FB_TGCP_YearlyPaidSubscribers_' + @Date          
          
/*Export @File to @Dest*/          
exec staging.ExportTableToPipeText rfm, dbo, @File, @Dest          
    
    
    
    
    
/* FB Win Backs */    
    
--These are the categories Dave needs:    
-- US Free Trial Cancel High Risk - ~25k    
-- Adam historical, Vikram current    
-- US Free Trial Cancel Low Risk - ~25k    
-- Adam historical, Vikram current    
-- Rest of World Free Trial Cancel - ~30k    
-- Vikram    
-- Logic needs to exclude customers where country = ‘Unknown’ and firstdevicecategory in (‘mobile’, ‘tablet’) as we consider those US based customers.    
-- Paid Cancel Monthly - ~64k    
-- Vikram, please include 3 and 6 month customers in here    
-- Paid Cancel Annual - ~7k    
-- Vikram    
    
--Historical table: testsummary.dbo.AV_TGCPLUS_Free_Trial_Historical_Model_Output    
--Current table: testsummary.dbo.AV_TGCPLUS_Free_Trial_Model_Output    
    
    
   IF OBJECT_ID ('RFM..FB_TGCP_WinBacks')IS NOT NULL          
   DROP TABLE rfm..FB_TGCP_WinBacks          
   select distinct C.CustomerID,rtrim(ltrim(C.EmailAddress)) as EmailAddress,     
     o.FirstName,o.LastName,o.City,o.State,o.ZIP,CountryCode,    
     cast(0 as int)Paid,cast(null as varchar(10)) Risk ,Cast(null as varchar(100))UpdateCategory,cast(0 as int) Processed  
  ,case when datediff(m,SubDate,getdate())<6 then 1 else 0 end as last6monthCancels         
   into rfm..FB_TGCP_WinBacks          
   from DataWarehouse.Marketing.TGCPlus_CustomerSignature  c          
   left join datawarehouse.mapping.tgcplus_customeroverlay o           
   on o.customerid = c.customerid          
   Where TransactionType = 'Cancelled'    
    
    
   --Historical table update Paid Flag, Risk and Update Table Category.    
   update a     
   set a.Paid = 0,    
    a.Risk = Case when Decile in (1,2,3,4,5)  then 'High Risk' else 'Low Risk' End,    
    a.UpdateCategory = 'AV_TGCPLUS_Free_Trial_Historical_Model_Output'    
   from rfm..FB_TGCP_WinBacks a    
   join testsummary.dbo.AV_TGCPLUS_Free_Trial_Historical_Model_Output M    
   on M.CustomerID = a.CustomerID;    
    
   --Current table has daily level data, we need to only update based on latest Date_Scored,update Paid Flag, Risk and Update Table Category.     
 With CTE_AV_TGCPLUS_Free_Trial_Model_Output as     
 (Select *, Row_number() over(partition by Customerid order by Date_Scored desc) RNK from testsummary.dbo.AV_TGCPLUS_Free_Trial_Model_Output )      
   update W    
   set W.Paid = 0,    
    W.Risk = Case when Decile in (1,2,3,4,5)  then 'High Risk' else 'Low Risk' End,    
    W.UpdateCategory = 'AV_TGCPLUS_Free_Trial_Model_Output'    
   from rfm..FB_TGCP_WinBacks W    
   join CTE_AV_TGCPLUS_Free_Trial_Model_Output M    
   on M.CustomerID = W.CustomerID    
   where RNK = 1;    
    
   --Paid Monthly or Annual (Will overright any previous updates if they are currently paid).    
   update W     
   set W.Paid = 1,    
    W.UpdateCategory = Case when SubType ='MONTH' then 'Paid Month Cancel'     
        when SubType ='YEAR' then 'Paid Year Cancel'     
        end    
   from rfm..FB_TGCP_WinBacks W    
   join DataWarehouse.Marketing.TGCPlus_CustomerSignature c     
   on c.CustomerID = W.CustomerID    
   where C.LTDPaidAmt > 0    
    
   --Delete CPA affiliates who have not paid    
   Delete W from rfm..FB_TGCP_WinBacks W    
   join DataWarehouse.Marketing.TGCPlus_CustomerSignature c     
   on c.CustomerID = W.CustomerID    
   where W.Paid = 0 and c.IntlMD_Channel in ('CPA Affiliate')    
   and UpdateCategory is NULL    
    
    
   --Update Remaing US when country ='Unknown' and FirstDeviceCategory in ('mobile','tablet') only exception for ROW    
   update W    
   set W.Paid = case when C.PaidType = 'Free Trial Cancel' then 0     
      when C.PaidType = 'Paid Month Cancel' then 1 end,    
    W.UpdateCategory = C.PaidType    
   from DataWarehouse.Archive.tgcplus_churnmodeldata C    
   join rfm..FB_TGCP_WinBacks W on C.customerid = W.CustomerID    
   where UpdateCategory is NULL --and isnull(CountryCode,'US') <> 'US'    
   and C.country ='Unknown' and FirstDeviceCategory in ('mobile','tablet')    
    
    
   --Update ROW paid flag    
   update W    
   set W.Paid = 0,    
    W.UpdateCategory = 'ROW'    
   from DataWarehouse.Archive.tgcplus_churnmodeldata C    
   join rfm..FB_TGCP_WinBacks W on C.customerid = W.CustomerID    
   where UpdateCategory is NULL and isnull(CountryCode,'US') <> 'US'    
    
    
   --Update from Chrun Table Directly for missing customers and put them .    
   Update W    
   set W.Paid = 0,    
    W.UpdateCategory = 'ROW'    
   -- select *    
   from DataWarehouse.Archive.tgcplus_churnmodeldata C    
   join rfm..FB_TGCP_WinBacks W on C.customerid = W.CustomerID    
   where W.UpdateCategory is NULL and country ='Unknown'    
       
    
   ----Catch All remaing     
 update W    
 set W.Paid = 0,    
   W.UpdateCategory = 'ROW'    
 from rfm..FB_TGCP_WinBacks W    
 where UpdateCategory is NULL  or (UpdateCategory ='Free Trial Cancel' and risk is null)    
    
    
   select UpdateCategory,risk,Paid,last6monthCancels, count(*)    
   from rfm..FB_TGCP_WinBacks    
   group by UpdateCategory,risk,Paid,last6monthCancels    
   order by 1    
    
--FB_TGCP_WinBacks_FreeTrial_HighRisk  
    
   IF OBJECT_ID ('RFM..FB_TGCP_WinBacks_FreeTrial_HighRisk_last6monthCancels')IS NOT NULL          
   DROP TABLE rfm..FB_TGCP_WinBacks_FreeTrial_HighRisk_last6monthCancels          
   select distinct rtrim(ltrim(EmailAddress)) as EmailAddress, FirstName,LastName,City,State,ZIP     
   into rfm..FB_TGCP_WinBacks_FreeTrial_HighRisk_last6monthCancels          
   from rfm..FB_TGCP_WinBacks      
   Where UpdateCategory like '%Free%' and risk ='High Risk'  and last6monthCancels = 1  
/*Export FB_TGCP_WinBacks_FreeTrial_HighRisk to @Dest*/          
exec staging.ExportTableToPipeText rfm, dbo, 'FB_TGCP_WinBacks_FreeTrial_HighRisk_last6monthCancels', @Dest       
    
   IF OBJECT_ID ('RFM..FB_TGCP_WinBacks_FreeTrial_HighRisk')IS NOT NULL          
   DROP TABLE rfm..FB_TGCP_WinBacks_FreeTrial_HighRisk          
   select distinct rtrim(ltrim(EmailAddress)) as EmailAddress, FirstName,LastName,City,State,ZIP     
   into rfm..FB_TGCP_WinBacks_FreeTrial_HighRisk          
   from rfm..FB_TGCP_WinBacks      
   Where UpdateCategory like '%Free%' and risk ='High Risk'  and last6monthCancels = 0  
/*Export FB_TGCP_WinBacks_FreeTrial_HighRisk to @Dest*/          
exec staging.ExportTableToPipeText rfm, dbo, 'FB_TGCP_WinBacks_FreeTrial_HighRisk', @Dest     
  
  
--FB_TGCP_WinBacks_FreeTrial_LowRisk  
  
   IF OBJECT_ID ('RFM..FB_TGCP_WinBacks_FreeTrial_LowRisk_last6monthCancels')IS NOT NULL          
   DROP TABLE rfm..FB_TGCP_WinBacks_FreeTrial_LowRisk_last6monthCancels          
   select distinct rtrim(ltrim(EmailAddress)) as EmailAddress, FirstName,LastName,City,State,ZIP     
   into rfm..FB_TGCP_WinBacks_FreeTrial_LowRisk_last6monthCancels          
   from rfm..FB_TGCP_WinBacks      
   Where UpdateCategory like '%Free%' and risk ='Low Risk'   and last6monthCancels = 1  
/*Export FB_TGCP_WinBacks_FreeTrial_LowRisk to @Dest*/          
exec staging.ExportTableToPipeText rfm, dbo, 'FB_TGCP_WinBacks_FreeTrial_LowRisk_last6monthCancels', @Dest       
    
   IF OBJECT_ID ('RFM..FB_TGCP_WinBacks_FreeTrial_LowRisk')IS NOT NULL          
   DROP TABLE rfm..FB_TGCP_WinBacks_FreeTrial_LowRisk          
   select distinct rtrim(ltrim(EmailAddress)) as EmailAddress, FirstName,LastName,City,State,ZIP     
   into rfm..FB_TGCP_WinBacks_FreeTrial_LowRisk          
   from rfm..FB_TGCP_WinBacks      
   Where UpdateCategory like '%Free%' and risk ='Low Risk'   and last6monthCancels = 0  
/*Export FB_TGCP_WinBacks_FreeTrial_LowRisk to @Dest*/          
exec staging.ExportTableToPipeText rfm, dbo, 'FB_TGCP_WinBacks_FreeTrial_LowRisk', @Dest   
  
  
--FB_TGCP_WinBacks_PaidMonthlyCancels  
  
   IF OBJECT_ID ('RFM..FB_TGCP_WinBacks_PaidMonthlyCancels_last6monthCancels')IS NOT NULL          
   DROP TABLE rfm..FB_TGCP_WinBacks_PaidMonthlyCancels_last6monthCancels          
   select distinct rtrim(ltrim(EmailAddress)) as EmailAddress, FirstName,LastName,City,State,ZIP     
   into rfm..FB_TGCP_WinBacks_PaidMonthlyCancels_last6monthCancels          
   from rfm..FB_TGCP_WinBacks      
   Where UpdateCategory = 'Paid Month Cancel'  and last6monthCancels = 1  
/*Export FB_TGCP_WinBacks_PaidMonthlyCancels to @Dest*/          
exec staging.ExportTableToPipeText rfm, dbo, 'FB_TGCP_WinBacks_PaidMonthlyCancels_last6monthCancels', @Dest   
  
   IF OBJECT_ID ('RFM..FB_TGCP_WinBacks_PaidMonthlyCancels')IS NOT NULL          
   DROP TABLE rfm..FB_TGCP_WinBacks_PaidMonthlyCancels          
   select distinct rtrim(ltrim(EmailAddress)) as EmailAddress, FirstName,LastName,City,State,ZIP     
   into rfm..FB_TGCP_WinBacks_PaidMonthlyCancels          
   from rfm..FB_TGCP_WinBacks      
   Where UpdateCategory = 'Paid Month Cancel'  and last6monthCancels = 0  
/*Export FB_TGCP_WinBacks_PaidMonthlyCancels to @Dest*/          
exec staging.ExportTableToPipeText rfm, dbo, 'FB_TGCP_WinBacks_PaidMonthlyCancels', @Dest       
  
  
--FB_TGCP_WinBacks_PaidYearlyCancels  
  
   IF OBJECT_ID ('RFM..FB_TGCP_WinBacks_PaidYearlyCancels_last6monthCancels')IS NOT NULL          
   DROP TABLE rfm..FB_TGCP_WinBacks_PaidYearlyCancels_last6monthCancels          
   select distinct rtrim(ltrim(EmailAddress)) as EmailAddress, FirstName,LastName,City,State,ZIP     
   into rfm..FB_TGCP_WinBacks_PaidYearlyCancels_last6monthCancels          
   from rfm..FB_TGCP_WinBacks      
   Where UpdateCategory = 'Paid Year Cancel'   and last6monthCancels = 1  
/*Export FB_TGCP_WinBacks_PaidYearlyCancels to @Dest*/          
exec staging.ExportTableToPipeText rfm, dbo, 'FB_TGCP_WinBacks_PaidYearlyCancels_last6monthCancels', @Dest      
    
   IF OBJECT_ID ('RFM..FB_TGCP_WinBacks_PaidYearlyCancels')IS NOT NULL          
   DROP TABLE rfm..FB_TGCP_WinBacks_PaidYearlyCancels          
   select distinct rtrim(ltrim(EmailAddress)) as EmailAddress, FirstName,LastName,City,State,ZIP     
   into rfm..FB_TGCP_WinBacks_PaidYearlyCancels          
   from rfm..FB_TGCP_WinBacks      
   Where UpdateCategory = 'Paid Year Cancel'   and last6monthCancels = 0  
/*Export FB_TGCP_WinBacks_PaidYearlyCancels to @Dest*/          
exec staging.ExportTableToPipeText rfm, dbo, 'FB_TGCP_WinBacks_PaidYearlyCancels', @Dest       
    
  
--FB_TGCP_WinBacks_ROWCancels  
  
   IF OBJECT_ID ('RFM..FB_TGCP_WinBacks_ROWCancels_last6monthCancels')IS NOT NULL          
   DROP TABLE rfm..FB_TGCP_WinBacks_ROWCancels_last6monthCancels          
   select distinct rtrim(ltrim(EmailAddress)) as EmailAddress, FirstName,LastName,City,State,ZIP,CountryCode     
   into rfm..FB_TGCP_WinBacks_ROWCancels_last6monthCancels          
   from rfm..FB_TGCP_WinBacks      
   Where UpdateCategory = 'ROW'  and last6monthCancels = 1  
/*Export FB_TGCP_WinBacks_ROWCancels to @Dest*/          
exec staging.ExportTableToPipeText rfm, dbo, 'FB_TGCP_WinBacks_ROWCancels_last6monthCancels', @Dest   
  
   IF OBJECT_ID ('RFM..FB_TGCP_WinBacks_ROWCancels')IS NOT NULL          
   DROP TABLE rfm..FB_TGCP_WinBacks_ROWCancels          
   select distinct rtrim(ltrim(EmailAddress)) as EmailAddress, FirstName,LastName,City,State,ZIP,CountryCode     
   into rfm..FB_TGCP_WinBacks_ROWCancels          
   from rfm..FB_TGCP_WinBacks      
   Where UpdateCategory = 'ROW'  and last6monthCancels = 0  
/*Export FB_TGCP_WinBacks_ROWCancels to @Dest*/          
exec staging.ExportTableToPipeText rfm, dbo, 'FB_TGCP_WinBacks_ROWCancels', @Dest              
          
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
