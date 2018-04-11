SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [dbo].[SP_CreateBiWeekly_BestSellersCnvrtlgMailFile]    
As    
    
begin    
    
-- Convertalog data for LCM2_no2    
-- Pull Date: 12/16 - acquistion weeks 1/26 and 1/19 -    
-- To change...    
-- drop date: 20150223    
--Date based of running schedule next monday    
    
declare @date varchar(8),@year varchar(8), @ExecSQL nvarchar(max)    
select @date=cast(cast(convert(char(8), dateadd(week, datediff(week, 0, getdate()), 7), 112) as int)  as varchar(8))    
 --select @date    
    
set @year = datepart(yyyy,@date)    
    
select  a.*, DATEDIFF(week, a.AcquisitionWeek, getdate()) WeekSince, b.CatalogCode, b.CatalogName,    
 b.MD_Country, b.MD_Year, b.ChannelID as MD_ChannelID, b.MD_Channel,    
 b.MD_PromotionTypeID, b.MD_PromotionType, b.MD_CampaignID, b.MD_CampaignName,    
 b.StartDate, dateadd(d,3,Staging.GetMonday(b.StopDate)) as StopDate /*Expiration date changed due to date mismatch expiring on thursday of the week*/    
into #Adcodes    
from DataWarehouse.Mapping.WelcomeEmailAdcodeGrid a join    
 DataWarehouse.Mapping.vwAdcodesAll b on a.Adcode = b.AdCode    
where EmailType = 'BestSeller'    
and DATEDIFF(week, acquisitionweek, getdate()) in (5,6)    
    

	delete from #Adcodes
	where HVLVGroup = 'HV'
    
    
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Temp_CnvtBestSeller]') AND type in (N'U'))    
DROP TABLE Temp_CnvtBestSeller    
    
    
SELECT CCS.CustomerID, CCS.BuyerType, CCS.NewSeg, CCS.Name,     
 CCS.a12mf, CCS.ComboID, CCS.Concatenated Concantonated,    
 CCS.CustomerSegment, CCS.Frequency, CCS.FMPullDate, cast(c.startdate AS date) StartDate,     
 cast(c.StopDate AS date) StopDate,    
 CCS.Prefix, CCS.FirstName, CCS.MiddleName MiddleInitial, CCS.LastName, CCS.Suffix,     
 CCS.CompanyName as Company,     
 ccs.Address1 + ' '  + ccs.Address2 as Address1,    
    ccs.Address3 as Address2, CCS.City, CCS.State, CCS.PostalCode,     
 c.Adcode, CCS.AH, CCS.EC, CCS.FA, CCS.HS, CCS.LIT, CCS.MH, CCS.PH, CCS.RL, CCS.SC,     
 CCS.FlagMail, CCS.PreferredCategory, CCS.PreferredCategory2, CCS.PublicLibrary,    
 CCS.FlagValidRegionUS FlagValidRegion, 0 as FlagWelcomeBack,    
 b.CustGroup, b.HVLVGroup, b.AcquisitionWeek,    
 convert(varchar(30),c.MD_CampaignName) + case when c.HVLVGroup = 'HV' then '_PM4'    
       when c.HVLVGroup = 'MV' then '_PM5'    
       when c.HVLVGroup = 'LV' then '_PM8'    
        else ''    
     end as VersionName    
INTO Temp_CnvtBestSeller    
FROM  Datawarehouse.Marketing.campaigncustomersignature CCS     
 join (select * from rfm..WPTest_Random2013    
  where DATEDIFF(week, acquisitionweek, getdate()) in (5,6)     
  and CustGroup in('Test', 'Control'))b on CCS.customerid = b.CustomerID /* Changed to include both Control and test on 2/25/2015 pull date*/   
 join #Adcodes c on b.AcquisitionWeek = c.AcquisitionWeek    
     and b.CustGroup = c.CustGroup    
     and b.HVLVGroup = c.HVLVGroup      
WHERE CCS.FlagMail = 1     
AND CCS.PublicLibrary = 0     
AND CCS.FlagValidRegionUS = 1    
AND ISNULL(CCS.Frequency,'F1') = 'F1'    
    
    
  
/* PM8 moved to PM5 due to count issues one time*/  
  
declare @pm5 int, @pm8 int  
  
select top 1 @pm5 = adcode from Temp_CnvtBestSeller  
where HVLVGroup ='MV'  
  
select top 1 @pm8 = adcode from Temp_CnvtBestSeller  
where HVLVGroup ='LV'  
  
select @pm5'@pm5',@pm8'@pm8'  
  
--if exists (select count(*) from Temp_CnvtBestSeller where HVLVGroup ='LV' having count(*) between 1 and 200)   
if not exists  (select count(*) from Temp_CnvtBestSeller where HVLVGroup ='LV' having count(*) > 200)   
begin  
 Update Temp_CnvtBestSeller  
 set HVLVGroup ='MV',   
  VersionName ='Best Seller Convertalog_PM5',   
  adcode =@pm5  
 where AdCode = @pm8  
end  
  
  select AdCode,AcquisitionWeek,HVLVGroup,count(*) from Temp_CnvtBestSeller  
  group by AdCode,AcquisitionWeek,HVLVGroup  
  order by 2,3  
  
    
create index IX_Temp_CnvtBestSeller on Temp_CnvtBestSeller (customerid)    
    
    
-- Create mail file for Quad    
    
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Temp_CnvtBestSeller_Quad]') AND type in (N'U'))    
drop TABLE Temp_CnvtBestSeller_Quad    
    
    
SELECT Convert(varchar(150),    
 Ltrim(rtrim(Prefix + ' ' + FirstName + ' ' + LastName + ' ' + Suffix))) FullName1,    
 Company as Company1,     
 Address1 as Altrntddr1,    
 Address2 AltrntAddr2,     
 convert(varchar(250),'') DLVRYDDRSS,     
 City,     
 State,     
 PostalCode as Zip4,     
 AdCode as ConvertalogAdcode,     
 CustomerID,      
 upper(datename(WEEKDAY,StopDate)) + ' ' + upper(left(DATENAME(MONTH,stopdate),3)) + ' ' + convert(varchar,DAY(stopdate)) + ', ' + CONVERT(varchar, YEAR(StopDate)) as Expire,    
 VersionName    
INTO Temp_CnvtBestSeller_Quad    
from Temp_CnvtBestSeller     
where AdCode > 0    
    
    
    
    
-----------------------------------------------------Adding seed list------------------------------------------------------------------------    
--select * from Datawarehouse.Mapping.SeedNames_Convertalog    
    
INSERT INTO Temp_CnvtBestSeller_Quad    
select a.FullName1, '', a.Altrntddr1, '', '', a.City, a.State, a.Zip4,    
 b.ConvertalogAdcode, 99999999 as CustomerID,    
 b.Expire, b.VersionName    
from Datawarehouse.Mapping.SeedNames_Convertalog a,    
 (select distinct convertalogadcode, expire, VersionName    
 from Temp_CnvtBestSeller_Quad)b    
     
    
    
update  Temp_CnvtBestSeller_Quad    
set Altrntddr1 = replace(replace(ISNULL(Altrntddr1,''),char(13),''),char(10),''),    
 AltrntAddr2 = replace(replace(ISNULL(AltrntAddr2,''),char(13),''),char(10),''),    
 company1 = replace(replace(ISNULL(company1,''),char(13),''),char(10),'')    
     
    
update  Temp_CnvtBestSeller_Quad    
set Altrntddr1 = replace(Altrntddr1,'|',''),    
 AltrntAddr2 = replace(AltrntAddr2,'|',''),    
 company1 = replace(company1,'|','')    
     
    
--select * from Temp_CnvtBestSeller_Quad    
--select * from Temp_CnvtBestSeller_Quad    
--where fullname1 like '%-%'    
    
update Temp_CnvtBestSeller_Quad    
set fullname1 =REPLACE(fullname1,'----','')    
    
    
    
Print 'Final QC #1'    
    
SELECT CAST(a.AcquisitionWeek as date) AcquisitionWeek,     
 a.Adcode,     
 cast(b.adcodeName as varchar(80)) as adcodeName,     
 b.CustGroup,     
 cast(b.HVLVGroup as varchar(8)) as HVLVGroup,    
 cast(c.Startdate as DATE) as MailDate,     
 cast(a.StopDate as DATE) as ExpireDate,     
 count(distinct a.customerid) CustCount    
from  Temp_CnvtBestSeller a left join    
 datawarehouse.mapping.vwadcodesall c on a.Adcode = c.adcode join    
 #adcodes b on a.Adcode = b.adcode    
    and a.acquisitionWeek = b.acquisitionweek    
where customerid < 99999999    
group by CAST(a.AcquisitionWeek as date), a.Adcode, b.adcodeName, b.CustGroup, b.HVLVGroup,    
 cast(c.Startdate as DATE),     
 cast(a.StopDate as DATE)    
order by 1,2    
    
    
    
-- Final QC #2    
Print 'Final QC #2'    
    
SELECT A.VersionName, a.Adcode as ConvertalogAdcode, cast(b.adcodeName as varchar(80)) as adcodeName,      
 cast(c.Startdate as DATE) as MailDate,     
 cast(c.StopDate as DATE) as ExpireDate,     
 count(distinct a.customerid)    
from  Temp_CnvtBestSeller a left join    
 datawarehouse.mapping.vwadcodesall c on a.Adcode = c.adcode join    
 (select distinct adcode, AdcodeName from #adcodes)b on a.Adcode = b.adcode    
where customerid < 99999999 and a.AdCode > 0    
group by A.VersionName, a.Adcode, b.adcodeName,     
 cast(c.Startdate as DATE),     
 cast(c.StopDate as DATE)    
order by 2    
    
-- Final QC #3    
Print 'Final QC #3'    
select convert(datetime,Convert(varchar,b.CustomerSince,101)) CustomerSince,     
 Count(distinct a.customerid) CustCount    
from Temp_CnvtBestSeller a join    
 Datawarehouse.Marketing.campaigncustomersignature b on a.customerid = b.customerid    
--where a.adcode in (43649, 43758)    
group by convert(datetime,Convert(varchar,b.CustomerSince,101))    
having COUNT(distinct a.customerid) > 10    
order by 1 desc,2    
/*    
-- Final QC #4    
Print 'Final QC #4'    
select convert(datetime,Convert(varchar,b.CustomerSince,101)) CustomerSince,     
 a.FlagWelcomeBack,    
 Count(a.customerid) CustCount    
from Temp_CnvtBestSeller a join    
 Datawarehouse.Marketing.campaigncustomersignature b on a.customerid = b.customerid    
--where a.adcode in (43649, 43758)    
group by convert(datetime,Convert(varchar,b.CustomerSince,101)), a.FlagWelcomeBack    
--having COUNT(distinct a.customerid) > 10    
order by 1 desc,2    
*/    
    
-- For 'QC for Test' tab    
Print 'QC for Test tab'    
SELECT b.AcquisitionWeek, b.CustGroup, b.HVLVGroup, a.adcode, c.adcodeName, count(a.customerid) CustCount    
from  Temp_CnvtBestSeller a join    
 datawarehouse.mapping.vwadcodesall c on a.Adcode = c.adcode join    
 (select *    
 from rfm..WPTest_Random2013)b on A.customerID = b.CustomerID    
        and a.AcquisitionWeek = b.AcquisitionWeek    
group by b.AcquisitionWeek, b.CustGroup, b.HVLVGroup, a.adcode, c.adcodeName    
order by 1,2,3,4    
    
    
set @ExecSQL = 'select * into rfm.dbo.Mail_US_Convertalog_BestSeller_' + @date + '  from Temp_CnvtBestSeller'    
exec sp_executesql @ExecSQL    
--select  @ExecSQL    
    
set @ExecSQL = 'select * into rfm.dbo.Mail_US_Convertalog_BestSeller_' + @date + '_Quad from Temp_CnvtBestSeller_Quad'    
exec sp_executesql @ExecSQL    
--select  @ExecSQL    
    
    
    
set @ExecSQL = 'exec staging.ExportTableToPipeText rfm, dbo, Mail_US_Convertalog_BestSeller_' + @date   
    + '_Quad, ''\\File1\Groups\Marketing\MailFiles\'  
    + @year + '\US\Convertalog'', ''Convertalog_BestSeller_'+ @date + '_Quad.TXT'''    
  
Print @ExecSQL  
exec sp_executesql @ExecSQL    
--select  @ExecSQL     
    
--set @ExecSQL = 'exec staging.ExportTableToPipeText rfm, dbo, Mail_US_Convertalog_BestSeller_' + @date + '_Quad, ''\\TTCDATAMART01\ETLDax\Reports'', ''Convertalog_BestSeller_'+ @date + '_Quad.TXT'''    
--exec sp_executesql @ExecSQL    
    
-- Transfer data to appropriate directory    
--use DataWarehouse    
--exec staging.ExportTableToPipeText rfm, dbo, Mail_US_Convertalog_BestSeller_20150209_Quad, '\\File1\Groups\Marketing\MailFiles\2015\US\Convertalog', 'Convertalog_BestSeller_20150209_Quad.TXT'    
    
/*    
set @ExecSQL = 'exec staging.ExportTableToPipeText rfm, dbo, Mail_US_Convertalog_BestSeller_' + @date + '_Quad, ''\\File1\Groups\Automate\FTP\QuadGraphics\'', ''Convertalog_BestSeller_'+ @date + '_Quad.TXT'''    
exec sp_executesql @ExecSQL    
*/    
--exec staging.ExportTableToPipeText rfm, dbo, Mail_US_Convertalog_BestSeller_20150209_Quad, '\\File1\Groups\Automate\FTP\QuadGraphics\', 'Convertalog_BestSeller_20150209_Quad.TXT'    
    
print 'Email Below to group Vikram, Preethi, Julia, Chris R, Brad Brown, Kim P'    
    
    
set @ExecSQL = 'print ''Zip Name: Convertalog_BestSeller_' + @date +'_Quad.zip''    
print ''''    
print ''File Name: Convertalog_BestSeller_' + @date +'_Quad.TXT'''    
    
exec sp_executesql @ExecSQL    
    
    
set @ExecSQL = 'select count(*) Total_record_cnt from rfm.dbo.Mail_US_Convertalog_BestSeller_' + @date + '_Quad '    
exec sp_executesql @ExecSQL    
    
    
-- Final QC #2    
Print 'Final QC #2'    
    
SELECT A.VersionName, a.ConvertalogAdcode, cast(b.adcodeName as varchar(80)) as adcodeName,      
 cast(c.Startdate as DATE) as MailDate,     
 cast(c.StopDate as DATE) as ExpireDate,     
 count(distinct a.customerid)    
from  Temp_CnvtBestSeller_Quad a left join    
 datawarehouse.mapping.vwadcodesall c on a.ConvertalogAdcode = c.adcode join    
 (select distinct adcode, AdcodeName from #adcodes)b on a.ConvertalogAdcode = b.adcode    
where customerid < 99999999    
group by A.VersionName, a.ConvertalogAdcode, b.adcodeName,     
 cast(c.Startdate as DATE),     
 cast(c.StopDate as DATE)    
order by 2    
                
--- ADD Convertalog data to convertalog history table    
/*     
select *    
-- delete     
from Datawarehouse.Archive.MailingHistory_Convertalog    
where startdate = '12/29/2014'    
*/    
    
--select * from  Datawarehouse.Archive.MailingHistory_Convertalog    
--where StartDate = '2/9/2015'    
    
--------------------------------------------------insert into History--------------------------------------------------------------------------------    
print 'Inserting into History'    
    
insert into Datawarehouse.Archive.MailingHistory_Convertalog    
select customerid, adcode, StartDate, NewSeg, Name, A12mf,     
 Concantonated, 0 as FlagHoldout, ComboID, '' as SubjRank, PreferredCategory2    
from Temp_CnvtBestSeller    
    
    
--------------------------------------------------insert into History--------------------------------------------------------------------------------    
    
--(20658 row(s) affected)    
    
--delete from Datawarehouse.Archive.MailingHistory_Convertalog    
--where StartDate = '12/29/2014'    
    
----- ADD Convertalog data to convertalog history table    
--insert into Datawarehouse.Archive.MailingHistory_Convertalog    
--select a.CustomerID, b.ConvertalogAdcode, '12/29/2014', NewSeg, Name, A12mf,     
-- Concantonated,     
-- case when b.ConvertalogAdcode = 78759 then 1 else 0 end as FlagHoldout,     
-- ComboID, '', PreferredCategory2    
--from rfm..Temp_CnvtBestSeller a join    
-- rfm..Temp_CnvtBestSeller_Quad b on a.CustomerID = b.customerid    
----(52988 row(s) affected)    
    
--select top 100 * from datawarehouse.archive.MailingHistory_Convertalog    
----- ADD Convertalog data to convertalog history table    
--insert into Datawarehouse.Archive.MailingHistory_Convertalog    
--select customerid, adcode, '12/29/2014', NewSeg, Name, A12mf,     
-- Concantonated,     
-- case when adcode = 78759 then 1 else 0 end as FlagHoldout,     
-- ComboID, '', PreferredCategory2    
--from rfm..Temp_CnvtBestSeller    
----(52988 row(s) affected)    
    
    
 drop table #Adcodes    
    
    
END    
    
    
    
    
    
    
    
    
    
    
  
GO
