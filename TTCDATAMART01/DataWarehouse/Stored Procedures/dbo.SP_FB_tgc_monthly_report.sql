SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [dbo].[SP_FB_tgc_monthly_report]  
as  
Begin  
  

  --Renamed SP from SP_FB_tgcplus_monthly_report to SP_FB_tgc_monthly_report
  
-- drop table Datawarehouse.staging.FaceBook_TGCPlus_AllCustWithEmails   
 if object_id ('staging.FaceBook_TGCPlus_AllCustWithEmails') is not null  
 Drop table staging.FaceBook_TGCPlus_AllCustWithEmails  
  
select   
  a.Email,  
  b.firstname,  
  b.lastname,  
  b.city,  
  b.state,  
  b.postalcode,  
  b.CountryCode,           
  b.CustomerSegmentFnl,  
  cast('' as varchar(50)) as CustomerSegmentFnlFB  
into Datawarehouse.staging.FaceBook_TGCPlus_AllCustWithEmails    
from DataWarehouse.Marketing.epc_preference a           
 left join DataWarehouse.Marketing.CampaignCustomerSignature b on a.CustomerID = b.CustomerID         
where b.PublicLibrary = 0    
and isnull(a.Email,'') <> ''  
  
update Datawarehouse.staging.FaceBook_TGCPlus_AllCustWithEmails  
set CustomerSegmentFnl = REPLACE(CustomerSegmentFnl,' ','')  
  
update Datawarehouse.staging.FaceBook_TGCPlus_AllCustWithEmails  
set CustomerSegmentFnlFB = case when CustomerSegmentFnl in ('Active_Multi','Active_Single',   
         'NewToFile_Single','Inactive_Multi',  
         'Inactive_Single','DeepInactive_Multi','DeepInactive_Single') then CustomerSegmentFnl  
         else 'Rest'  
        end   
          
-- drop table Datawarehouse.staging.FaceBook_TGCPlus_AllCustWithEmailsPrspcts   
if object_id ('staging.FaceBook_TGCPlus_AllCustWithEmailsPrspcts') is not null  
drop table Datawarehouse.staging.FaceBook_TGCPlus_AllCustWithEmailsPrspcts  
  
    
select   
  a.Email,  
  null as firstname,  
  null as lastname,  
  null as city,  
  null as state,  
  null as postalcode,  
  null as CountryCode,           
  null as CustomerSegmentFnl,  
  cast('Rest' as varchar(50)) as CustomerSegmentFnlFB  
into Datawarehouse.staging.FaceBook_TGCPlus_AllCustWithEmailsPrspcts  
from DataWarehouse.Marketing.epc_preference a            
where a.CustomerID is null  
and a.email not like '%.co.%'  
  
  
delete a  
from Datawarehouse.staging.FaceBook_TGCPlus_AllCustWithEmailsPrspcts a   
join Datawarehouse.staging.FaceBook_TGCPlus_AllCustWithEmails  b   
on a.Email = b.Email  
  
  
insert into Datawarehouse.staging.FaceBook_TGCPlus_AllCustWithEmails   
select *  
from Datawarehouse.staging.FaceBook_TGCPlus_AllCustWithEmailsPrspcts   
   
  
/* Truncate FbTgcplusMonthlyReport  */  
  
truncate table rfm..FbTgcplusMonthlyReport  
  
   
Declare @SQL Nvarchar(2000),@Date varchar(8),@Dest Nvarchar(200),@File Nvarchar(200),@table Nvarchar(200),@FileNamepart Nvarchar(200)  
set @Date = convert(varchar, getdate(),112)  
set @FileNamepart = case when  datepart(m,getdate()) < 10 then '_0' + Cast( datepart(m,getdate()) as varchar (2)) else '_' + Cast( datepart(m,getdate()) as varchar (2)) end + '_' + Cast( datepart(yyyy,getdate()) as varchar (4))  
set @Dest = '\\File1\Groups\Marketing\Marketing Strategy and Analytics\FaceBook\FaceBookCampaigns\FB_MonthlyFiles'+ '_' + @Date  
  
  
select @FileNamepart FileNamepart,@Dest Dest  
  
EXEC master.dbo.xp_create_subdir @Dest  
  
  
-- 1. Active Multi  
----------------------------  
  
set @table = 'FB_TGCPTrgt_ActMulti'   
set @File = 'Active_Multis' + @FileNamepart + '.txt'  
  
insert into rfm..FbTgcplusMonthlyReport (Tablename,Counts)  
select @File, Count(*) as Cnts  
from Datawarehouse.staging.FaceBook_TGCPlus_AllCustWithEmails   
where CustomerSegmentFnlFB = 'Active_Multi'  
  
  
if object_id ('rfm..FB_TGCPTrgt_ActMulti') is not null  
drop table rfm..FB_TGCPTrgt_ActMulti  
  
select distinct Email,Firstname,Lastname,city,state,postalcode,countrycode  
into rfm..FB_TGCPTrgt_ActMulti  
from Datawarehouse.staging.FaceBook_TGCPlus_AllCustWithEmails   
where CustomerSegmentFnlFB = 'Active_Multi'  
  
/*Export @File to @Dest*/  
exec staging.ExportTableToPipeText rfm, dbo, @table, @Dest,@File  
  
  
  
-- 2. Active Single  
------------------------------  
  
set @table = 'FB_TGCPTrgt_ActSngl'   
set @File = 'Active_Single' + @FileNamepart + '.txt'  
  
insert into rfm..FbTgcplusMonthlyReport   
(Tablename,Counts)  
select @File, Count(*) as Cnts  
from Datawarehouse.staging.FaceBook_TGCPlus_AllCustWithEmails   
where CustomerSegmentFnlFB = 'Active_Single'  
  
if object_id ('rfm..FB_TGCPTrgt_ActSngl') is not null  
drop table rfm..FB_TGCPTrgt_ActSngl  
  
select distinct Email,Firstname,Lastname,city,state,postalcode,countrycode  
into rfm..FB_TGCPTrgt_ActSngl  
from Datawarehouse.staging.FaceBook_TGCPlus_AllCustWithEmails   
where CustomerSegmentFnlFB = 'Active_Single'  
  
/*Export @File to @Dest*/  
exec staging.ExportTableToPipeText rfm, dbo, @table, @Dest,@File  
  
-- 3. Active Single - New to file  
--------------------------------------------------  
  
set @table = 'FB_TGCPTrgt_NTFSngl'   
set @File = 'NewToFile_Single' + @FileNamepart + '.txt'  
  
insert into rfm..FbTgcplusMonthlyReport   
(Tablename,Counts)  
select @File, Count(*) as Cnts  
from Datawarehouse.staging.FaceBook_TGCPlus_AllCustWithEmails   
where CustomerSegmentFnlFB = 'NewToFile_Single'  
  
  
if object_id ('rfm..FB_TGCPTrgt_NTFSngl') is not null  
drop table rfm..FB_TGCPTrgt_NTFSngl  
  
select distinct Email,Firstname,Lastname,city,state,postalcode,countrycode  
into rfm..FB_TGCPTrgt_NTFSngl  
from Datawarehouse.staging.FaceBook_TGCPlus_AllCustWithEmails   
where CustomerSegmentFnlFB = 'NewToFile_Single'  
   
   
/*Export @File to @Dest*/  
exec staging.ExportTableToPipeText rfm, dbo, @table, @Dest,@File  
  
  
-- 4. Inactive Multi  
----------------------------  
  
set @table = 'FB_TGCPTrgt_InactMulti'   
set @File = 'Inactive_Multi' + @FileNamepart + '.txt'  
  
insert into rfm..FbTgcplusMonthlyReport   
(Tablename,Counts)  
select @File, Count(*) as Cnts  
from Datawarehouse.staging.FaceBook_TGCPlus_AllCustWithEmails   
where CustomerSegmentFnlFB = 'Inactive_Multi'  
   
  
if object_id ('rfm..FB_TGCPTrgt_InactMulti') is not null  
drop table rfm..FB_TGCPTrgt_InactMulti  
  
select distinct Email,Firstname,Lastname,city,state,postalcode,countrycode  
into rfm..FB_TGCPTrgt_InactMulti  
from Datawarehouse.staging.FaceBook_TGCPlus_AllCustWithEmails   
where CustomerSegmentFnlFB = 'Inactive_Multi'  
  
  
/*Export @File to @Dest*/  
exec staging.ExportTableToPipeText rfm, dbo, @table, @Dest,@File   
  
-- 5. Inactive Single  
------------------------------  
  
set @table = 'FB_TGCPTrgt_InactSngl'   
set @File = 'Inactive_Single' + @FileNamepart + '.txt'  
  
insert into rfm..FbTgcplusMonthlyReport   
(Tablename,Counts)  
select @File, Count(*) as Cnts  
from Datawarehouse.staging.FaceBook_TGCPlus_AllCustWithEmails   
where CustomerSegmentFnlFB = 'Inactive_Single'  
  
if object_id ('rfm..FB_TGCPTrgt_InactSngl') is not null  
drop table rfm..FB_TGCPTrgt_InactSngl  
  
select distinct Email,Firstname,Lastname,city,state,postalcode,countrycode  
into rfm..FB_TGCPTrgt_InactSngl  
from Datawarehouse.staging.FaceBook_TGCPlus_AllCustWithEmails   
where CustomerSegmentFnlFB = 'Inactive_Single'  
  
/*Export @File to @Dest*/  
exec staging.ExportTableToPipeText rfm, dbo, @table, @Dest,@File   
  
  
-- 6. DeepInactive Multi  
----------------------------  
  
set @table = 'FB_TGCPTrgt_DpInMulti'   
set @File = 'DeepInactive_Multi' + @FileNamepart + '.txt'  
  
insert into rfm..FbTgcplusMonthlyReport   
(Tablename,Counts)  
select @File, Count(*) as Cnts  
from Datawarehouse.staging.FaceBook_TGCPlus_AllCustWithEmails   
where CustomerSegmentFnlFB = 'DeepInactive_Multi'  
  
if object_id ('rfm..FB_TGCPTrgt_DpInMulti') is not null  
drop table rfm..FB_TGCPTrgt_DpInMulti  
  
select distinct Email,Firstname,Lastname,city,state,postalcode,countrycode  
into rfm..FB_TGCPTrgt_DpInMulti  
from Datawarehouse.staging.FaceBook_TGCPlus_AllCustWithEmails   
where CustomerSegmentFnlFB = 'DeepInactive_Multi'  
  
/*Export @File to @Dest*/  
exec staging.ExportTableToPipeText rfm, dbo, @table, @Dest,@File   
   
  
-- 7. DeepInactive Single  
------------------------------  
set @table = 'FB_TGCPTrgt_DpInSngl'   
set @File = 'DeepInactive_Single' + @FileNamepart + '.txt'  
  
insert into rfm..FbTgcplusMonthlyReport   
(Tablename,Counts)  
select @File, Count(*) as Cnts  
from Datawarehouse.staging.FaceBook_TGCPlus_AllCustWithEmails   
where CustomerSegmentFnlFB = 'DeepInactive_Single'  
  
if object_id ('rfm..DeepInactive_Single') is not null  
drop table rfm..DeepInactive_Single  
  
select distinct Email,Firstname,Lastname,city,state,postalcode,countrycode  
into rfm..DeepInactive_Single  
from Datawarehouse.staging.FaceBook_TGCPlus_AllCustWithEmails   
where CustomerSegmentFnlFB = 'DeepInactive_Single'  
  
/*Export @File to @Dest*/  
exec staging.ExportTableToPipeText rfm, dbo, @table, @Dest,@File   
  
  
-- 8. REst (Inquirers, No RFM, Prospects)  
----------------------------  
  
set @table = 'FB_TGCPTrgt_Rest'   
set @File = 'Rest' + @FileNamepart + '.txt'  
  
insert into rfm..FbTgcplusMonthlyReport   
(Tablename,Counts)  
select @File, Count(*) as Cnts  
from Datawarehouse.staging.FaceBook_TGCPlus_AllCustWithEmails   
where CustomerSegmentFnlFB = 'Rest'  
  
  
if object_id ('rfm..FB_TGCPTrgt_Rest') is not null  
drop table rfm..FB_TGCPTrgt_Rest  
  
select distinct Email,Firstname,Lastname,city,state,postalcode,countrycode  
into rfm..FB_TGCPTrgt_Rest  
from Datawarehouse.staging.FaceBook_TGCPlus_AllCustWithEmails   
where CustomerSegmentFnlFB = 'Rest'   
  
/*Export @File to @Dest*/  
exec staging.ExportTableToPipeText rfm, dbo, @table, @Dest,@File    
  
  
  
set @SQL = '  
   IF OBJECT_ID (''RFM..FaceBook_TGCPlus_AllCustWithEmails_' + @Date +''')IS NOT NULL  
   DROP TABLE rfm..FaceBook_TGCPlus_AllCustWithEmails_' + @Date +'  
  
   select *   
   into rfm..FaceBook_TGCPlus_AllCustWithEmails_' + @Date +'  
   from DataWarehouse.staging.FaceBook_TGCPlus_AllCustWithEmails '  
  
Exec (@sql)  
  
  
DECLARE @p_body as nvarchar(max), @p_subject as nvarchar(max)  
DECLARE @p_recipients as nvarchar(max), @p_profile_name as nvarchar(max)  
SET @p_profile_name = N'DL datamart alerts'  
SET @p_recipients = N'~dldatamartalerts@TEACHCO.com'  
SET @p_subject = N'FaceBook Monthly Report'  
SET @p_body = '<b>Facebook Monthly Report has been created</b>.    
let others know that the report is ready here ' + @Dest + '  
  
For Report Run the below:  
Select * from rfm..FbTgcplusMonthlyReport  
  
'  
EXEC msdb.dbo.sp_send_dbmail  
  @profile_name = @p_profile_name,  
  @recipients = @p_recipients,  
  @body = @p_body,  
  @body_format = 'HTML',  
  @subject = @p_subject  
  
  
End  
  
  
GO
