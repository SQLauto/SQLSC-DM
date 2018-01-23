SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [dbo].[SP_EPC_Emailpull_OSW] @EmailID varchar(50)
as
Begin

Declare @sql varchar(500) 

select top 1 @EmailID = EmailID                           
from mapping.Email_adcode                          
where EmailCompletedFlag = 0                     
and MaxCourses = 0                        
order by EmailID,Countrycode desc                        
select @EmailID   
               
if OBJECT_ID('staging.EPC_EmailPull_PRSPCT') is not null                          
drop table  staging.EPC_EmailPull_PRSPCT                      
                  
-- All Prospect Emails                  
 select DISTINCT Emailaddress                 
 into #prospect                  
 from DataWarehouse.Marketing.Vw_EPC_Prospect_EmailPull_OSW                   
 where store_country not in ('au_en','uk_en')                  
 and website_country not in ('UK','AU','Australia')         
 --order by magento_created_date desc                  
        
                   
CREATE TABLE staging.EPC_EmailPull_PRSPCT(                  
 [CustomerID] [nvarchar](20) NULL,                  
 [LastName] [varchar](50) NULL,                  
 [FirstName] [varchar](50) NULL,                  
 [EmailAddress] [varchar](255) NOT NULL,                  
 [Unsubscribe] [varchar](1) NOT NULL,                  
 [EmailStatus] [varchar](15) NULL,                  
 [SubjectLine] [varchar](300) NULL,                  
 [CustHTML] [varchar](2000) NULL,                  
 [State] [varchar](50) NULL,                  
 [AdCode] [int] NULL,                  
 [PreferredCategory] [varchar](20) NULL,                  
 [ComboID] [varchar](30) NULL,                  
 [SendDate] [int] NULL,                  
 [BatchID] [tinyint] NULL,                  
 [ECampaignID] [varchar](30) NULL,                  
 [DeadlineDate] [varchar](50) NULL,                  
 [Subject] [varchar](50) NULL,                  
 [CatalogName] [varchar](50) NULL,                  
 [CustomerSegmentNew] [varchar](20) NULL,                  
 [UserID] [nvarchar](51) NOT NULL,                  
 [Priority] [varchar](250) NULL                  
                  
) ON [PRIMARY]                  
                  
Insert into staging.EPC_EmailPull_PRSPCT                  
 select distinct 999999999 as CustomerID,                  
 'Learner' LastName,                   
 'Lifelong' FirstName,                   
  emailaddress,                   
 'N' Unsubscribe,                   
 'VALID' EmailStatus,                   
 map.Subjectline as SubjectLine,                   
 '' CustHTML,                   
 '' State,                   
 AdCode,                   
 'Gen' PreferredCategory,                   
 '' ComboID,                   
 datepart(d,map.startdate) as SendDate,                   
 1 BatchID,                   
 'Email'+ cast(Map.Adcode as varchar(10))+'_' + convert(varchar(8), map.startdate, 112)as   ECampaignID,                   
 cast(DATENAME(WEEKDAY, map.EndDate) + ', ' + DATENAME(Month, map.EndDate) + ' ' + cast(datepart(dd,map.EndDate) as varchar(2)) as varchar(50)) as DeadlineDate,                    
 '' as Subject,                   
 'Prospect' CatalogName,                   
 'Prospect' CustomerSegmentNew,                   
 cast( '999999999' + '_' + CONVERT(varchar, Map.Adcode) + '_'+ EmailAddress as nvarchar(51) ) UserID,                   
 Map.Priority as Priority                  
  from #prospect P                   
  ,(select top 1 * from DataWarehouse.Mapping.Email_adcode where EmailId = @EmailID and SegmentGroup = 'Prospects') map                  
  where emailaddress not like '%teachco%'                  
                  
set @sql = 'select * Into Lstmgr..'+ @EmailID + '_PRSPCT from staging.EPC_EmailPull_PRSPCT'                        
exec (@sql)                   
                  
set @sql = 'Final Table Lstmgr..'+ @EmailID + '_PRSPCT from staging.EPC_EmailPull_PRSPCT'                  
drop table #prospect                  

Print @sql
                  
End                


 
GO
