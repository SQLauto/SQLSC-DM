SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  
  
  
CREATE proc [dbo].[Sp_EmailPull_DLR_old]  
as  
Begin  
  
Declare @EmailID varchar(50)  
  
select top 1 @EmailID = EmailID from mapping.Email_adcode  
where EmailCompletedFlag = 0   
select @EmailID  
  
select * from mapping.Email_adcode  
where EmailID = @EmailID  
  
  
if OBJECT_ID('staging.EmailPullDLR') is not null  
drop table  staging.EmailPullDLR  
  
--------------------------------------------------------------------------------------------------------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
--------------------------------------------------------Add US, CA and ROW (No Inqs)--------------------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
Print'Insert new records into staging.EmailPullDLR'  
  
select   
ccs.CustomerID,  
ccs.LastName,  
ccs.FirstName,  
ccs.EmailAddress,  
'N' as Unsubscribe,  
'VALID' as EmailStatus,  
map.SubjectLine,  
case when map.CourseFlag = 0  
      then ''  
      else        'Course list'  
end as CustHTML,  
ccs.State,  
map.AdCode,  
CASE when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory = 'SC' then 'SCI'  
     when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory = 'FA' then 'VA'  
     when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory NOT IN ('SC', 'FA') then ccs.preferredcategory  
  when isnull(ccs.PreferredCategory2,'') = '' then 'GEN'  
     else ccs.PreferredCategory2   
END as PreferredCategory,  
ccs.ComboID,  
datepart(d,map.startdate) as SendDate,  
--BatchID  
'Email' + map.adcode + '_' + convert(varchar(8), map.startdate, 112) as ECampaignID, /*Concatenation of 'Email' + Adcode + '_' + Startdate*/  
case when ccs.countrycode = 'US' or ccs.countrycode = 'CA' /*Stopdate (format??)*/  
      then DATENAME(WEEKDAY, map.EndDate) + ', ' + DATENAME(Month, map.EndDate) + ' ' + cast(datepart(dd,map.EndDate) as varchar(2))  
      else DATENAME(WEEKDAY, map.EndDate) + ', ' + DATENAME(Month, map.EndDate) + ' ' + cast(datepart(dd,map.EndDate) as varchar(2)) /*change to required format*/  
end as DeadlineDate,  
'' as Subject, /* BLANK */  
ccs.CustomerSegmentNew,  
cast(ccs.CustomerID as varchar(15)) + '_' + CAST(Map.adcode as varchar (10)) as UserID /*Concatenation of customerid + '_' +  Adcode + '_' + Catalogname (remove space and use segment group)*/  
,csg.CountryCode  
into staging.EmailPullDLR  
from mapping.Email_adcode map (nolock)  
inner join mapping.Country_segment_group csg (nolock)   
on map.segmentgroup = csg.segmentgroup and map.CountryCode = csg.CountryCode   
inner join  datawarehouse.Marketing.CampaignCustomerSignature  ccs (nolock)  
on csg.CountryCode = case when ccs.CountryCode IN ('AU','US','GB','CA') then ccs.CountryCode else 'ROW' end and  ccs.NewSeg=csg.NewSeg   and ccs.Name= csg.Name and ccs.A12MF = csg.A12MF --ccs.comboid = csg.comboid--   
WHERE ccs.FlagEmail = 1 AND ccs.BuyerType > 1 AND EmailAddress LIKE '%@%'  
AND ccs.PublicLibrary = 0  
AND ccs.CountryCode not in ('GB','AU')  
and map.EmailID = @EmailID  
and map.DLRFlag = 0  
  
--------------------------------------------------------------------------------------------------------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
-----------------------------------------------------Add NO RFMs and few Highschool exceptions----------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
  
  
Print'Insert new records NoRFM into staging.EmailPullDLR'  
  
insert into staging.EmailPullDLR  
select   
ccs.CustomerID,  
ccs.LastName,  
ccs.FirstName,  
ccs.EmailAddress,  
'N' as Unsubscribe,  
'VALID' as EmailStatus,  
map.SubjectLine,  
case when map.CourseFlag = 0  
      then ''  
      else        'Course list'  
end as CustHTML,  
ccs.State,  
map.AdCode,  
CASE when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory = 'SC' then 'SCI'  
     when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory = 'FA' then 'VA'  
     when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory NOT IN ('SC', 'FA') then ccs.preferredcategory  
  when isnull(ccs.PreferredCategory2,'') = '' then 'GEN'  
     else ccs.PreferredCategory2   
END as PreferredCategory,  
ccs.ComboID,  
datepart(d,map.startdate) as SendDate,  
--BatchID  
'Email' + map.adcode + '_' + convert(varchar(8), map.startdate, 112) as ECampaignID, /*Concatenation of 'Email' + Adcode + '_' + Startdate*/  
case when ccs.countrycode = 'US' or ccs.countrycode = 'CA' /*Stopdate (format??)*/  
      then DATENAME(WEEKDAY, map.EndDate) + ', ' + DATENAME(Month, map.EndDate) + ' ' + cast(datepart(dd,map.EndDate) as varchar(2))  
      else DATENAME(WEEKDAY, map.EndDate) + ', ' + DATENAME(Month, map.EndDate) + ' ' + cast(datepart(dd,map.EndDate) as varchar(2)) /*change to required format*/  
end as DeadlineDate,  
'' as Subject, /* BLANK */  
ccs.CustomerSegmentNew,  
cast(ccs.CustomerID as varchar(15)) + '_' + CAST(Map.adcode as varchar (10)) as UserID /*Concatenation of customerid + '_' +  Adcode + '_' + Catalogname (remove space and use segment group)*/  
,csg.CountryCode  
from mapping.Email_adcode map (nolock)  
inner join mapping.Country_segment_group csg (nolock)   
on map.segmentgroup = csg.segmentgroup and map.CountryCode = csg.CountryCode   
inner join  datawarehouse.Marketing.CampaignCustomerSignature  ccs (nolock)  
on csg.CountryCode = case when ccs.CountryCode IN ('AU','US','GB','CA') then ccs.CountryCode else 'ROW' end and  ccs.comboid = csg.comboid  
WHERE ccs.FlagEmail = 1 AND ccs.BuyerType > 1 AND EmailAddress LIKE '%@%'  
AND ccs.PublicLibrary = 0  
AND ccs.CountryCode not in ('GB','AU')  
and ccs.comboid in ('NoRFM','highschool')    
and ccs.NewSeg is null  
and map.DLRFlag = 0  
  
--------------------------------------------------------------------------------------------------------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
--------------------------------------------------------Add Inquirers US, CA and RO---------------------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
  
select * from  datawarehouse.mapping.Email_adcode  
where   EmailID = @EmailID and SegmentGroup = 'Inquirers'  
  
declare @AdcodeInq int  
select @AdcodeInq = Adcode from  datawarehouse.mapping.Email_adcode  
where  EmailID = @EmailID and SegmentGroup = 'Inquirers'  
  
select '@AdcodeInq', @AdcodeInq  
  
  
Print'Insert new records (Inq)into staging.EmailPullDLR'  
  
insert into staging.EmailPullDLR  
select --*   
ccs.CustomerID,  
ccs.LastName,  
ccs.FirstName,  
ccs.EmailAddress,  
'N' as Unsubscribe,  
'VALID' as EmailStatus,  
map.SubjectLine,  
case when map.CourseFlag = 0  
      then ''  
      else        'Course list'  
end as CustHTML,  
ccs.State,  
@AdcodeInq as AdCode,  
CASE when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory = 'SC' then 'SCI'  
     when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory = 'FA' then 'VA'  
     when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory NOT IN ('SC', 'FA') then ccs.preferredcategory  
  when isnull(ccs.PreferredCategory2,'') = '' then 'GEN'  
     else ccs.PreferredCategory2   
END as PreferredCategory,  
CASE WHEN ccs.ComboID IN ('25-10000 Mo Inq Plus', 'Inq') THEN '25-10000 Mo Inq'  
     ELSE CCS.ComboID  
END AS ComboID,       
datepart(d,map.startdate) as SendDate,  
'Email' + map.adcode + '_' + convert(varchar(8), map.startdate, 112) as ECampaignID, /*Concatenation of 'Email' + Adcode + '_' + Startdate*/  
case when ccs.countrycode = 'US' or ccs.countrycode = 'CA' /*Stopdate (format??)*/  
      then DATENAME(WEEKDAY, map.EndDate) + ', ' + DATENAME(Month, map.EndDate) + ' ' + cast(datepart(dd,map.EndDate) as varchar(2))  
      else DATENAME(WEEKDAY, map.EndDate) + ', ' + DATENAME(Month, map.EndDate) + ' ' + cast(datepart(dd,map.EndDate) as varchar(2)) /*change to required format*/  
end as DeadlineDate,  
'' as Subject, /* BLANK */  
ccs.CustomerSegmentNew,  
cast(ccs.CustomerID as varchar(15)) + '_' + CAST(Map.adcode as varchar (10)) as UserID /*Concatenation of customerid + '_' +  Adcode + '_' + Catalogname (remove space and use segment group)*/  
,csg.CountryCode  
FROM mapping.Email_adcode map (nolock)  
inner join mapping.Country_segment_group csg (nolock)   
on map.segmentgroup = csg.segmentgroup and map.CountryCode = csg.CountryCode   
inner join  datawarehouse.Marketing.CampaignCustomerSignature  ccs (nolock)  
on csg.CountryCode = case when ccs.CountryCode IN ('AU','US','GB','CA') then ccs.CountryCode else 'ROW' end and  ccs.comboid=csg.comboid     --and ccs.Name= csg.Name and ccs.A12MF = csg.A12MF  
LEFT OUTER JOIN staging.EmailPullDLR EC01   
ON CCS.CustomerID = EC01.CustomerID  
WHERE EC01.CustomerID IS NULL AND ccs.Buyertype = 1   
AND ccs.FlagEmail = 1 AND ccs.PublicLibrary = 0  
AND ccs.CountryCode not in ('GB','AU')  
AND ccs.EmailAddress LIKE '%@%'  
and map.EmailID = @EmailID  
and map.DLRFlag = 0  
--------------------------------------------------------------------------------------------------------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
----------------------------------------------Checking for email dupes and delete-----------------------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
  
--Checking for dupes  
if exists (select emailaddress,COUNT(*) from staging.EmailPullDLR  
group by emailaddress  
having COUNT(*)>1 )  
  
begin   
Print 'Deletes due to Duplicates'  
--declare @table varchar(100), @DistinctColumn varchar(100)  
--Delete Dupe email accounts  
  
  
delete a  
--select a.*   
from staging.EmailPullDLR a  
inner join   
(  
select emailaddress,CustomerID,Rank() over (Partition BY Emailaddress order by customerid desc) as Rank  
from staging.EmailPullDLR  
where emailaddress in (  
select emailaddress  from staging.EmailPullDLR  
group by emailaddress  
having COUNT(*)>1  
)  
) b on a.CustomerID=b.CustomerID  
where RANK>1  
  
End  
--------------------------------------------------------------------------------------------------------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
------------------------------------Deletes due to magento Customer unsubcribe Failure------------------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
  
Print 'Deletes due to magento Customer unsubcribe Failure'  
delete a  
--into EmailPullDLRDEL  
from staging.EmailPullDLR a join  
      lstmgr.dbo.EmailIDsNOTinMagento_Suppress b on a.customerID = b.customerID  
where a.customerid > 0    
  
delete a  
from staging.EmailPullDLR a join  
      lstmgr.dbo.EmailIDsNOTinMagento_Suppress b on a.emailaddress = b.emailaddress  
where a.customerid > 0    
  
--------------------------------------------------------------------------------------------------------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
----------------------------------------Deletes due to CampaignEmail_RemoveUnsubs-----------------------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
Print 'Deletes due to CampaignEmail_RemoveUnsubs'  
  
print 'ignored this'  
exec [Staging].[CampaignEmail_RemoveUnsubs] 'EmailPullDLR'  
  
--------------------------------------------------------------------------------------------------------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
--------------------------------------------update customers Records based on the inquirer country------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
  
select * from  datawarehouse.mapping.Email_adcode  
where   EmailID = @EmailID and SegmentGroup = 'Inquirers'  
  
declare @AdcodeInqCanada int  
select @AdcodeInqCanada = Adcode from  datawarehouse.mapping.Email_adcode  
where   EmailID = @EmailID and SegmentGroup = 'Swamp Control' and Countrycode='CA'  
select '@AdcodeInqCanada', @AdcodeInqCanada  
  
update a  
set adcode = @AdcodeInqCanada   
--select *   
from staging.EmailPullDLR a  
where adcode = @AdcodeInq and CountryCode = 'CA'  
  
  
declare @AdcodeInqInternational int  
select @AdcodeInqInternational = Adcode from  datawarehouse.mapping.Email_adcode  
where  EmailID = @EmailID and SegmentGroup = 'International' and Countrycode='ROW'  
  
select '@AdcodeInqInternational', @AdcodeInqInternational  
  
update a  
set adcode = @AdcodeInqInternational   
--select *   
from staging.EmailPullDLR a  
where adcode = @AdcodeInq and CountryCode not in ('US','CA')  
  
--------------------------------------------------------------------------------------------------------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
--------------------------------------------update customers for PM8 pricing based on PM8 adcode--------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
    
--update lowvalue adcode  
select * from  datawarehouse.Mapping.Email_Adcode  
where   EmailID = @EmailID and SegmentGroup = 'PM8'  
  
declare @pm8 int  
select @pm8 = Adcode from  datawarehouse.Mapping.Email_Adcode  
where EmailID = @EmailID and SegmentGroup = 'PM8'  
  
select '@pm8', @pm8  
  
print 'PM 8 Update 1'  
  
update a  
set a.adcode = @pm8  
--select COUNT(distinct a.customerid)  
from Staging.EmailPullDLR a  
join  
(select * from rfm.dbo.WPTest_Random2013   
where HVLVGroup in ('LV')  
and JFYEmailDLRDate>= (select startdate from datawarehouse.mapping.Email_adcode  
      where EmailID = @EmailID and SegmentGroup = 'PM8')  
) b on A.customerid=b.CustomerID   
where A.comboid in ('16sL0','26s30')   
and A.Adcode in (select distinct Adcode from  datawarehouse.Mapping.Email_Adcode  
    where EmailID = @EmailID and SegmentGroup in ('Active Control','Swamp Control', 'Inquirers'))  
  
  
print 'PM 8 Update 2'   
              
update a               
set a.adcode= @pm8  
--select COUNT(distinct a.customerid)  
from Staging.EmailPullDLR a  
join  
 (select * from rfm.dbo.WPTest_Random2013   
 where HVLVGroup in ('LV')   
 and JFYEmailDLRDate>= (select startdate from datawarehouse.mapping.Email_adcode  
      where EmailID = @EmailID and SegmentGroup = 'PM8')  
 ) b  on A.emailaddress=b.EmailAddress  
where A.comboid in ('16sL0','26s30')   
and A.Adcode in (select distinct Adcode from  datawarehouse.Mapping.Email_Adcode  
    where EmailID = @EmailID and SegmentGroup in ('Active Control','Swamp Control', 'Inquirers'))  
  
  
print 'PM 8 results'  
exec staging.GetAdcodeInfo_test  'staging.EmailPullDLR', datawarehouse  
--------------------------------------------------------------------------------------------------------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
--------------------------------------------update customers for PM5 pricing based on PM5 adcode--------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
  
--update highvalue adcode  
select * from  datawarehouse.mapping.Email_adcode  
where EmailID = @EmailID and SegmentGroup = 'PM5'  
  
declare @pm5 int  
select @pm5 = Adcode from  datawarehouse.mapping.Email_adcode  
where EmailID = @EmailID and SegmentGroup = 'PM5'  
  
select '@pm5', @pm5  
  
  
print 'PM 5 Update 1'  
  
update a  
set a.adcode = @pm5  
--select COUNT(distinct a.customerid)  
from staging.EmailPullDLR a  
join  
(select * from rfm.dbo.WPTest_Random2013   
where HVLVGroup in ('MV')  
and JFYEmailDLRDate>= (select startdate from datawarehouse.mapping.Email_adcode  
      where  EmailID = @EmailID and  SegmentGroup = 'PM5')  
) b on A.customerid=b.CustomerID   
where A.comboid in ('16sL0','26s30')   
and A.Adcode in (select distinct Adcode from  datawarehouse.mapping.Email_adcode  
    where  EmailID = @EmailID and  SegmentGroup in ('Active Control','Swamp Control', 'Inquirers'))  
                
  
print 'PM 5 Update 2'     
              
update a               
set a.adcode= @pm5  
--select COUNT(distinct a.customerid)  
from Staging.EmailPullDLR a  
join  
 (select * from rfm.dbo.WPTest_Random2013   
 where HVLVGroup in ('MV')   
 and JFYEmailDLRDate>= (select startdate from datawarehouse.mapping.Email_adcode  
      where EmailID = @EmailID and SegmentGroup = 'PM5')  
 ) b  on A.emailaddress=b.EmailAddress  
where A.comboid in ('16sL0','26s30')   
and A.Adcode in (select distinct Adcode from   datawarehouse.mapping.Email_adcode  
    where EmailID = @EmailID and SegmentGroup in ('Active Control','Swamp Control', 'Inquirers'))  
  
print 'PM 5 results'  
exec staging.GetAdcodeInfo_test  'staging.EmailPullDLR', datawarehouse  
  
  
--------------------------------------------------------------------------------------------------------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
--------------------------------update customers for Deep Swamp based on customersegmentnew in ('DeepInactive')-----------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
  
/*  
declare @DeepSwamp int  
select @DeepSwamp = Adcode from   datawarehouse.Mapping.Email_Adcode  
where segmentGroup = 'Swamp control'  
  
select '@DeepSwamp', @DeepSwamp  
  
  
update a  
set a.adcode=@DeepSwamp  
--select count(*)  
from staging.EmailPullDLR a  
where a.customersegmentnew in ('DeepInactive')  
and a.adcode  in (select distinct Adcode from  datawarehouse.Mapping.Email_Adcode  
    where --EmailID = @EmailID and   
    SegmentGroup in ('Active Control'))  
  
  
  
  
update a  
set a.adcode=@DeepSwamp  
--select count(*)  
from staging.EmailPullDLR a  
where a.customersegmentnew in ('NewToFile_PM5','NewToFile_PM8')  
-- and a.adcode=105004  
and a.adcode  in (select distinct Adcode from  datawarehouse.Mapping.Email_Adcode  
    where SegmentGroup in ('Active Control'))  
  
  */    
    
  
declare @Swamp int  
select @Swamp = Adcode from   datawarehouse.Mapping.Email_Adcode  
where EmailID = @EmailID and segmentGroup = 'Swamp control' and countrycode= 'US'  
select '@Swamp', @Swamp  
  
update a  
set a.adcode=@Swamp  
--select count(*)  
from staging.EmailPullDLR a  
where a.customersegmentnew in ('NewToFile_PM5','NewToFile_PM8')  
and a.adcode  in (select distinct Adcode from  datawarehouse.Mapping.Email_Adcode  
    where EmailID = @EmailID and SegmentGroup in ('Active Control') and countrycode= 'US')  
  
--CA NewToFile_PM5  
select @Swamp = Adcode from   datawarehouse.Mapping.Email_Adcode  
where EmailID = @EmailID and segmentGroup = 'Swamp control' and countrycode= 'CA'  
select '@Swamp', @Swamp  
  
update a  
set a.adcode=@Swamp  
--select count(*)  
from staging.EmailPullDLR a  
where a.customersegmentnew in ('NewToFile_PM5','NewToFile_PM8')  
and a.adcode  in (select distinct Adcode from  datawarehouse.Mapping.Email_Adcode  
    where EmailID = @EmailID and SegmentGroup in ('Active Control') and countrycode= 'CA')  
  
  
  
--------------------------------------------------------------------------------------------------------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
-------------------------------------------------------DLR Updates based of mailing---------------------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
  
  
  
Select customerid,adcode   
into #DLR   
from DataWarehouse.Archive.MailhistoryCurrentYear (nolock)  
where AdCode in   
(select distinct DLRAdCode from datawarehouse.mapping.Email_adcode (nolock) where DLRFlag = 1)  
  
  
update Email  
Set Email.Adcode = EA.Adcode  
--select count(*)--Ea.Adcode,DLR.Adcode, Email.*   
from staging.EmailPullDLR Email  
left join #DLR  DLR  
on Email.customerid=DLR.customerid  
left join datawarehouse.mapping.Email_adcode EA  
on EA.DLRAdcode=DLR.Adcode  
where EA.DLRAdcode is not null  
  
  
   
--------------------------------------------------------------------------------------------------------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
-------------------------------Splitter to split counts based of the percentage of records in mapping---------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------  
  
/*  
print 'Before Splitter'  
  
exec staging.GetAdcodeInfo_test  'staging.EmailPullDLR', datawarehouse  
  
--#primaryadcode  
select primary_adcode,0 as processed  into #primaryadcode   
from mapping.Email_adcode   
group by primary_adcode having COUNT(*)>1    
  
  while exists (select top 1 * from #primaryadcode where processed=0 order by primary_adcode)  
   Begin  
  
   declare @primary_adcode varchar(10)  
  
   select top 1 @primary_adcode=primary_adcode from #primaryadcode where processed=0 order by primary_adcode  
  
   select '@primary_adcode',@primary_adcode  
  
  
   --#adcode  
   select adcode,split_percentage,primary_Adcode into #adcode   
   from mapping.Email_adcode where primary_Adcode=@primary_adcode  
  
  
   --#splitter  
   Create table #splitter (adcode varchar(10),primary_adcode varchar(10),comboid varchar(20),preferredcategory varchar(30), split_percentage int,Cnt int, processed bit default(0))  
   Insert into #splitter (adcode,comboid,preferredcategory,cnt,primary_adcode,split_percentage )  
   select adcode,comboid,preferredcategory,cnt,primary_Adcode,split_percentage from #adcode,  
   (  
   select coalesce(comboid,'yyy') as comboid,coalesce(preferredcategory,'xxx') as preferredcategory,COUNT(*) as cnt  
   From staging.EmailPullDLR  
   Where adcode = @primary_adcode    
   group by comboid,preferredcategory  
   having COUNT(*)>1  
   )a  
     
   print 'updating #splitter processed=1 for primaryadcode'  
   update #splitter  
   set processed = 1  
   where adcode=@primary_adcode  
     
   print 'updating #splitter Cnts for other adcode based of SplitPct'  
   update #splitter  
   set Cnt = cast( (split_percentage * cnt )/100 as int)  
   where adcode<>@primary_adcode  
  
  
   declare @adcode varchar(10), @PrimaryAdcode varchar(10),@Cnt varchar(15),@comboid varchar(20),@preferredcategory varchar(20)  
  
     while exists (select top 1 * from #splitter where processed=0 order by adcode)  
      Begin  
  
      select top 1 @adcode = adcode ,@PrimaryAdcode=primary_adcode, @cnt = cnt,@comboid=comboid,@preferredcategory=preferredcategory   
      from #splitter   
      where processed=0   
      order by adcode,comboid,preferredcategory  
  
      select  @adcode as adcode , @PrimaryAdcode as PrimaryAdcode, @Cnt as cnt,@comboid as comboid,@preferredcategory as preferredcategory  
        
      Print 'updating records for above segments'  
      exec ('update staging.EmailPullDLR   
          set adcode = '+ @adcode +  
        ' where adcode = '+ @PrimaryAdcode +' and customerID in (select top ' + @Cnt + '  customerID   from staging.EmailPullDLR where adcode = '+ @PrimaryAdcode + ' and comboid= '''+ @comboid + ''' and  preferredcategory  = ''' + @preferredcategory + '''
 order by NEWID() )')  
  
      update #splitter  
      set processed=1  
      where adcode=@adcode and comboid=@comboid and preferredcategory = @preferredcategory  
  
      END  
  
   drop table #adcode  
   drop table #splitter  
  
  
   update #primaryadcode  
   set processed=1  
   where primary_adcode = @primary_adcode  
  
   END  
drop table #primaryadcode  
  
  
print 'After Splitter'  
exec staging.GetAdcodeInfo_test  'staging.EmailPullDLR', datawarehouse  
  
  
*/  
  
End  
  
  
  
  
  
GO
