SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



    
CREATE proc [dbo].[Sp_EPC_EmailPull_DailyDeals_20171120]                        
as                        
Begin                        
                        
Declare @EmailID varchar(50),@sql varchar(500),@CountryCode varchar(20),@table varchar(100)                        
                        

/* Duplicate dormant emails  */

select Customerid, Emailaddress, Row_number() over(partition by customerid order by MaxOpendate desc) Rank ,FlagDormantCustomer
into #Cust
from marketing.vw_epc_emailpull
order by 1

select c1.*,DistinctEmailsCount,EngagedDistinctEmailCount, case when DistinctEmailsCount >=1 and EngagedDistinctEmailCount = 0 then 1
                     when rank <= EngagedDistinctEmailCount then 1 else 0 end as Keep    
into #CustFinal
from #Cust c1
left join (select Customerid, sum(case when  FlagDormantCustomer = 0 then 1 else 0 end)EngagedDistinctEmailCount, Count(Emailaddress) DistinctEmailsCount
from #Cust group by Customerid ) c2
on c1.customerid = c2.customerid  


/* Duplicate dormant emails  */

--Using MaxCourses as Course id for daily deals                        
while exists (select top 1 EmailID from mapping.Email_adcode where EmailCompletedFlag = 0 and MaxCourses <> 0 order by EmailID)                        
Begin                        
                        
select top 1 @EmailID = EmailID,@CountryCode = Countrycode                         
from mapping.Email_adcode                        
where EmailCompletedFlag = 0                   
and MaxCourses <> 0                       
order by EmailID,Countrycode desc                      
select @EmailID                        
                        
select * from mapping.Email_adcode                        
where EmailID = @EmailID                        
                        
if OBJECT_ID('staging.EPC_EmailPull_DailyDeals') is not null                        
drop table  staging.EPC_EmailPull_DailyDeals                        
                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------Add US, CA and ROW (No Inqs)--------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
if @CountryCode in ('US','CA')                        
begin                        
                        
Print'Insert new records into staging.EPC_EmailPull_DailyDeals'                        
                        
select                         
ccs.CustomerID,                        
ccs.LastName,                        
ccs.FirstName,                        
ccs.EmailAddress,                        
'N' as Unsubscribe,                        
cast('VALID' as varchar(15)) as EmailStatus,                        
map.SubjectLine,                        
cast(case when map.CourseFlag = 0                        
      then ''                        
      else        'Course list'                        
end as varchar(2000)) as CustHTML,                        
cast (ccs.State as varchar(50)) as [State],                        
map.AdCode,                        
CASE when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory = 'SC' then CAST('SCI' AS varchar(20))                         
     when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory = 'FA' then CAST('VA' AS varchar(20))                         
     when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory NOT IN ('SC', 'FA') then cast(ccs.preferredcategory AS varchar(20))                        
  when isnull(ccs.PreferredCategory2,'') = '' then CAST('GEN' AS varchar(20))                         
     else cast(ccs.PreferredCategory2 as varchar(20))                        
END as PreferredCategory,                        
ccs.ComboID,                        
datepart(d,map.startdate) as SendDate,                        
CAST(null as tinyint) as BatchID,                        
CAST('' as varchar(30)) as ECampaignID, /*Concatenation of 'Email' + Adcode + '_' + Startdate*/                        
cast(DATENAME(WEEKDAY, map.EndDate) + ', ' + DATENAME(Month, map.EndDate) + ' ' + cast(datepart(dd,map.EndDate) as varchar(2)) as varchar(50)) as DeadlineDate,                        
cast ('' as varchar(50)) as Subject, /* BLANK */                        
map.segmentgroup as CatalogName,                        
ccs.CustomerSegmentNew,                        
--cast(ccs.CustomerID as varchar(15)) + '_' + CAST(Map.adcode as varchar (10)) as UserID /*Concatenation of customerid + '_' +  Adcode + '_' + CatalogName (remove space and use segment group)*/                        
cast('' as nvarchar(51)) as UserID                        
,csg.CountryCode             
,ccs.NewSeg             
,map.MaxCourses as courseId          
into staging.EPC_EmailPull_DailyDeals                        
from mapping.Email_adcode map (nolock)                   
inner join mapping.Country_segment_group csg (nolock)                         
on map.segmentgroup = csg.segmentgroup and map.CountryCode = csg.CountryCode                         
inner join  datawarehouse.Marketing.Vw_EPC_EmailPull  ccs (nolock)                        
on csg.CountryCode = case when ccs.CountryCode IN ('AU','US','GB','CA') then ccs.CountryCode else 'ROW' end and  ccs.NewSeg=csg.NewSeg   and ccs.Name= csg.Name and ccs.A12MF = csg.A12MF --ccs.comboid = csg.comboid--                         
WHERE --ccs.FlagEmail = 1 AND /*Removed due to EPC*/                  
ccs.BuyerType > 1 AND EmailAddress LIKE '%@%'                        
AND ccs.PublicLibrary = 0                        
AND ccs.CountryCode not in ('GB','AU')                        
and map.EmailID = @EmailID                        
and map.DLRFlag = 0                        
                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
-----------------------------------------------------Add NO RFMs and few Highschool exceptions----------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
                        
                        
Print'Insert new records NoRFM into staging.EPC_EmailPull_DailyDeals'                        
                        
insert into staging.EPC_EmailPull_DailyDeals                        
select                         
ccs.CustomerID,                        
ccs.LastName,                        
ccs.FirstName,                        
ccs.EmailAddress,                        
'N' as Unsubscribe,                        
cast('VALID' as varchar(15)) as EmailStatus,                        
map.SubjectLine,                        
cast(case when map.CourseFlag = 0                        
      then ''                        
      else        'Course list'                        
end as varchar(2000)) as CustHTML,                        
cast (ccs.State as varchar(50)) as [State],                        
map.AdCode,                        
CASE when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory = 'SC' then CAST('SCI' AS varchar(20))                         
     when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory = 'FA' then CAST('VA' AS varchar(20))                         
     when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory NOT IN ('SC', 'FA') then cast(ccs.preferredcategory AS varchar(20))                        
  when isnull(ccs.PreferredCategory2,'') = '' then CAST('GEN' AS varchar(20))                         
     else cast(ccs.PreferredCategory2 as varchar(20))                        
END as PreferredCategory,                        
ccs.ComboID,                        
datepart(d,map.startdate) as SendDate,                        
CAST(null as tinyint) as BatchID,                        
CAST('' as varchar(30)) as ECampaignID, /*Concatenation of 'Email' + Adcode + '_' + Startdate*/                        
cast(DATENAME(WEEKDAY, map.EndDate) + ', ' + DATENAME(Month, map.EndDate) + ' ' + cast(datepart(dd,map.EndDate) as varchar(2)) as varchar(50)) as DeadlineDate,                        
cast ('' as varchar(50)) as Subject, /* BLANK */                        
map.segmentgroup as CatalogName,                        
ccs.CustomerSegmentNew,                        
--cast(ccs.CustomerID as varchar(15)) + '_' + CAST(Map.adcode as varchar (10)) as UserID /*Concatenation of customerid + '_' +  Adcode + '_' + CatalogName (remove space and use segment group)*/                        
cast('' as nvarchar(51)) as UserID                        
,csg.CountryCode                  
,ccs.NewSeg     
,map.MaxCourses as courseId                      
from mapping.Email_adcode map (nolock)                        
inner join mapping.Country_segment_group csg (nolock)                         
on map.segmentgroup = csg.segmentgroup and map.CountryCode = csg.CountryCode                         
inner join  datawarehouse.Marketing.Vw_EPC_EmailPull  ccs (nolock)                        
on csg.CountryCode = case when ccs.CountryCode IN ('AU','US','GB','CA') then ccs.CountryCode else 'ROW' end and  ccs.comboid = csg.comboid                        
WHERE --ccs.FlagEmail = 1 AND /*Removed due to EPC*/                  
ccs.BuyerType > 1 AND EmailAddress LIKE '%@%'                        
AND ccs.PublicLibrary = 0                        
AND ccs.CountryCode not in ('GB','AU')                        
and ccs.comboid in ('NoRFM','highschool')                          
and ccs.NewSeg is null                        
and map.DLRFlag = 0                        
and map.EmailID = @EmailID                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------Add Inquirers US, CA and RO---------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
                        
select * from  datawarehouse.mapping.Email_adcode                        
where   EmailID = @EmailID and SegmentGroup = 'Inquirers'                        
                        
declare @AdcodeInq int = 0                          
select @AdcodeInq = isnull(Adcode,0) from  datawarehouse.mapping.Email_adcode                        
where  EmailID = @EmailID and SegmentGroup = 'Inquirers'                        
                        
select '@AdcodeInq', @AdcodeInq                        
                        
if @AdcodeInq is not null                    
begin                    
Print'Insert new records (Inq)into staging.EPC_EmailPull_DailyDeals'                        
                        
insert into staging.EPC_EmailPull_DailyDeals                        
select --*                         
ccs.CustomerID,                        
ccs.LastName,                        
ccs.FirstName,                        
ccs.EmailAddress,                        
'N' as Unsubscribe,                        
cast('VALID' as varchar(15)) as EmailStatus,                        
map.SubjectLine,                        
cast(case when map.CourseFlag = 0                        
      then ''                        
else        'Course list'                        
end as varchar(2000)) as CustHTML,                        
cast (ccs.State as varchar(50)) as [State],                        
@AdcodeInq as AdCode,                        
CASE when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory = 'SC' then CAST('SCI' AS varchar(20))                         
     when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory = 'FA' then CAST('VA' AS varchar(20))                         
     when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory NOT IN ('SC', 'FA') then cast(ccs.preferredcategory AS varchar(20))                        
  when isnull(ccs.PreferredCategory2,'') = '' then CAST('GEN' AS varchar(20))                         
     else cast(ccs.PreferredCategory2 as varchar(20))                        
END as PreferredCategory,                        
CASE WHEN ccs.ComboID IN ('25-10000 Mo Inq Plus', 'Inq') THEN '25-10000 Mo Inq'                        
     ELSE CCS.ComboID                        
END AS ComboID,                            
datepart(d,map.startdate) as SendDate,                        
CAST(null as tinyint) as BatchID,                        
CAST('' as varchar(30)) as ECampaignID, /*Concatenation of 'Email' + Adcode + '_' + Startdate*/                        
cast(DATENAME(WEEKDAY, map.EndDate) + ', ' + DATENAME(Month, map.EndDate) + ' ' + cast(datepart(dd,map.EndDate) as varchar(2)) as varchar(50)) as DeadlineDate,                        
cast ('' as varchar(50)) as Subject, /* BLANK */                        
map.segmentgroup as CatalogName,                        
ccs.CustomerSegmentNew,                        
--cast(ccs.CustomerID as varchar(15)) + '_' + CAST(Map.adcode as varchar (10)) as UserID /*Concatenation of customerid + '_' +  Adcode + '_' + CatalogName (remove space and use segment group)*/                        
cast('' as nvarchar(51)) as UserID                        
,csg.CountryCode                   
,ccs.NewSeg            
,map.MaxCourses as courseId              
FROM mapping.Email_adcode map (nolock)                        
inner join mapping.Country_segment_group csg (nolock)                         
on map.segmentgroup = csg.segmentgroup and map.CountryCode = csg.CountryCode                         
inner join  datawarehouse.Marketing.Vw_EPC_EmailPull  ccs (nolock)                        
on csg.CountryCode = case when ccs.CountryCode IN ('AU','US','GB','CA') then ccs.CountryCode else 'ROW' end and  ccs.comboid=csg.comboid     --and ccs.Name= csg.Name and ccs.A12MF = csg.A12MF                        
LEFT OUTER JOIN staging.EPC_EmailPull_DailyDeals EC01                         
ON CCS.CustomerID = EC01.CustomerID                        
WHERE EC01.CustomerID IS NULL AND ccs.Buyertype = 1                         
--AND ccs.FlagEmail = 1 /*Removed due to EPC*/                  
AND ccs.PublicLibrary = 0                        
AND ccs.CountryCode not in ('GB','AU')                        
AND ccs.EmailAddress LIKE '%@%'                        
and map.EmailID = @EmailID                        
and map.DLRFlag = 0                        
                        
End                    
                        
END                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
----------------------------------------------------------Add AU----------------------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
if @CountryCode = 'AU'                        
                        
Begin                        
Print'Insert new records AU into staging.EPC_EmailPull_DailyDeals'                        
                        
--insert into staging.EPC_EmailPull_DailyDeals                        
                        
select                         
ccs.CustomerID,                     
ccs.LastName,                        
ccs.FirstName,                        
ccs.EmailAddress,                        
'N' as Unsubscribe,                        
cast('VALID' as varchar(15)) as EmailStatus,                        
map.SubjectLine,                        
cast(case when map.CourseFlag = 0                        
      then ''                        
      else        'Course list'                        
end as varchar(2000)) as CustHTML,                        
cast (ccs.State as varchar(50)) as [State],                        
map.AdCode,                        
CASE when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory = 'SC' then CAST('SCI' AS varchar(20))                         
     when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory = 'FA' then CAST('VA' AS varchar(20))                       
     when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory NOT IN ('SC', 'FA') then cast(ccs.preferredcategory AS varchar(20))                        
  when isnull(ccs.PreferredCategory2,'') = '' then CAST('GEN' AS varchar(20))                         
     else cast(ccs.PreferredCategory2 as varchar(20))                        
END as PreferredCategory,                        
ccs.ComboID,                        
datepart(d,map.startdate) as SendDate,                        
CAST(null as tinyint) as BatchID,                        
CAST('' as varchar(30)) as ECampaignID, /*Concatenation of 'Email' + Adcode + '_' + Startdate*/                        
case when ccs.countrycode = 'US' or ccs.countrycode = 'CA' /*Stopdate (format??)*/                        
      then cast(DATENAME(WEEKDAY, map.EndDate) + ', ' + DATENAME(Month, map.EndDate) + ' ' + cast(datepart(dd,map.EndDate) as varchar(2)) as varchar(50))                        
      else     case when datepart(dd,map.EndDate) in (1,21,31) then cast(DATENAME(WEEKDAY, map.EndDate) + ', ' + cast(datepart(dd,map.EndDate) as varchar(2))+ 'st ' + DATENAME(Month,map.EndDate) as varchar(50))                         
      when datepart(dd,map.EndDate) in (2,22) then cast(DATENAME(WEEKDAY, map.EndDate) + ', ' + cast(datepart(dd,map.EndDate) as varchar(2))+ 'nd ' + DATENAME(Month,map.EndDate) as varchar(50))                         
      when datepart(dd,map.EndDate) in (3,23) then cast(DATENAME(WEEKDAY, map.EndDate) + ', ' + cast(datepart(dd,map.EndDate) as varchar(2))+ 'rd ' + DATENAME(Month,map.EndDate) as varchar(50))                    
      else cast(DATENAME(WEEKDAY, map.EndDate) + ', ' + cast(datepart(dd,map.EndDate) as varchar(2))+ 'th ' + DATENAME(Month,map.EndDate) as varchar(50))                         
     end                        
end as DeadlineDate,                        
cast ('' as varchar(50)) as Subject, /* BLANK */      
map.segmentgroup as CatalogName,                        
ccs.CustomerSegmentNew,                        
--cast(ccs.CustomerID as varchar(15)) + '_' + CAST(Map.adcode as varchar (10)) as UserID /*Concatenation of customerid + '_' +  Adcode + '_' + CatalogName (remove space and use segment group)*/                        
cast('' as nvarchar(51)) as UserID                        
,csg.CountryCode                  
,ccs.NewSeg           
,map.MaxCourses as courseId                
into staging.EPC_EmailPull_DailyDeals                        
from mapping.Email_adcode map (nolock)                        
inner join mapping.Country_segment_group csg (nolock)                         
on map.segmentgroup = csg.segmentgroup and map.CountryCode = csg.CountryCode                         
inner join  datawarehouse.Marketing.Vw_EPC_EmailPull  ccs (nolock)                        
on csg.CountryCode = case when ccs.CountryCode IN ('AU','US','GB','CA') then ccs.CountryCode else 'ROW' end and  ccs.NewSeg=csg.NewSeg   and ccs.Name= csg.Name and ccs.A12MF = csg.A12MF --ccs.comboid = csg.comboid--                         
WHERE 1 = 1                   
--ccs.FlagEmail = 1 /*Removed due to EPC*/                  
--AND ccs.BuyerType > 1 (Get Inq also)     
AND EmailAddress LIKE '%@%'                        
AND ccs.PublicLibrary = 0                        
AND ccs.CountryCode in ('AU')                        
and map.EmailID = @EmailID                        
and map.DLRFlag = 0                        
                        
                        
Print'Insert new records NoRFM into staging.EPC_EmailPull_DailyDeals'                        
                        
insert into staging.EPC_EmailPull_DailyDeals                        
select                         
ccs.CustomerID,                        
ccs.LastName,           
ccs.FirstName,                        
ccs.EmailAddress,                        
'N' as Unsubscribe,                        
cast('VALID' as varchar(15)) as EmailStatus,                        
map.SubjectLine,                        
cast(case when map.CourseFlag = 0                        
      then ''                        
      else        'Course list'                        
end as varchar(2000)) as CustHTML,                        
cast (ccs.State as varchar(50)) as [State],                        
map.AdCode,                        
CASE when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory = 'SC' then CAST('SCI' AS varchar(20))                         
     when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory = 'FA' then CAST('VA' AS varchar(20))                         
     when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory NOT IN ('SC', 'FA') then cast(ccs.preferredcategory AS varchar(20))                        
  when isnull(ccs.PreferredCategory2,'') = '' then CAST('GEN' AS varchar(20))                         
     else cast(ccs.PreferredCategory2 as varchar(20))                        
END as PreferredCategory,                        
ccs.ComboID,         
datepart(d,map.startdate) as SendDate,                        
CAST(null as tinyint) as BatchID,                        
CAST('' as varchar(30)) as ECampaignID, /*Concatenation of 'Email' + Adcode + '_' + Startdate*/                        
case when ccs.countrycode = 'US' or ccs.countrycode = 'CA' /*Stopdate (format??)*/                        
      then cast(DATENAME(WEEKDAY, map.EndDate) + ', ' + DATENAME(Month, map.EndDate) + ' ' + cast(datepart(dd,map.EndDate) as varchar(2)) as varchar(50))                        
      else     case when datepart(dd,map.EndDate) in (1,21,31) then cast(DATENAME(WEEKDAY, map.EndDate) + ', ' + cast(datepart(dd,map.EndDate) as varchar(2))+ 'st ' + DATENAME(Month,map.EndDate) as varchar(50))                         
      when datepart(dd,map.EndDate) in (2,22) then cast(DATENAME(WEEKDAY, map.EndDate) + ', ' + cast(datepart(dd,map.EndDate) as varchar(2))+ 'nd ' + DATENAME(Month,map.EndDate) as varchar(50))                         
      when datepart(dd,map.EndDate) in (3,23) then cast(DATENAME(WEEKDAY, map.EndDate) + ', ' + cast(datepart(dd,map.EndDate) as varchar(2))+ 'rd ' + DATENAME(Month,map.EndDate) as varchar(50))                         
      else cast(DATENAME(WEEKDAY, map.EndDate) + ', ' + cast(datepart(dd,map.EndDate) as varchar(2))+ 'th ' + DATENAME(Month,map.EndDate) as varchar(50))                         
     end                        
end as DeadlineDate,                        
cast ('' as varchar(50)) as Subject, /* BLANK */                        
map.segmentgroup as CatalogName,                        
ccs.CustomerSegmentNew,                        
--cast(ccs.CustomerID as varchar(15)) + '_' + CAST(Map.adcode as varchar (10)) as UserID /*Concatenation of customerid + '_' +  Adcode + '_' + CatalogName (remove space and use segment group)*/                        
cast('' as nvarchar(51)) as UserID                        
,csg.CountryCode                    
,ccs.NewSeg        
,map.MaxCourses as courseId                 
from mapping.Email_adcode map (nolock)                        
inner join mapping.Country_segment_group csg (nolock)                         
on map.segmentgroup = csg.segmentgroup and map.CountryCode = csg.CountryCode                         
inner join  datawarehouse.Marketing.Vw_EPC_EmailPull  ccs (nolock)                        
on csg.CountryCode = case when ccs.CountryCode IN ('AU','US','GB','CA') then ccs.CountryCode else 'ROW' end and  ccs.comboid = csg.comboid                        
WHERE 1 = 1                  
--ccs.FlagEmail = 1 /*Removed due to EPC*/                  
--AND ccs.BuyerType > 1                         
AND EmailAddress LIKE '%@%'                        
AND ccs.PublicLibrary = 0                        
AND ccs.CountryCode in ('AU')                        
and ccs.comboid in ('NoRFM','highschool')                          
and ccs.NewSeg is null                        
and map.DLRFlag = 0                
and map.EmailID = @EmailID                        
                        
END                        
                        
                        
                        
                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
----------------------------------------------------------Add GB----------------------------------------------------------------------------        
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
if @CountryCode = 'GB'                        
                        
Begin                        
                        
Print'Insert new records GB into staging.EPC_EmailPull_DailyDeals'                        
                        
select                         
ccs.CustomerID,                        
ccs.LastName,                        
ccs.FirstName,                        
ccs.EmailAddress,              
'N' as Unsubscribe,                        
cast('VALID' as varchar(15)) as EmailStatus,                        
map.SubjectLine,                        
cast(case when map.CourseFlag = 0                        
      then ''                        
      else        'Course list'                        
end as varchar(2000)) as CustHTML,                        
cast (ccs.State as varchar(50)) as [State],                        
map.AdCode,                        
CASE when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory = 'SC' then CAST('SCI' AS varchar(20))                         
     when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory = 'FA' then CAST('VA' AS varchar(20))                         
     when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory NOT IN ('SC', 'FA') then cast(ccs.preferredcategory AS varchar(20))                        
  when isnull(ccs.PreferredCategory2,'') = '' then CAST('GEN' AS varchar(20))                         
     else cast(ccs.PreferredCategory2 as varchar(20))                        
END as PreferredCategory,                        
ccs.ComboID,                        
datepart(d,map.startdate) as SendDate,                        
CAST(null as tinyint) as BatchID,        
CAST('' as varchar(30)) as ECampaignID, /*Concatenation of 'Email' + Adcode + '_' + Startdate*/                        
case when ccs.countrycode = 'US' or ccs.countrycode = 'CA' /*Stopdate (format??)*/                        
      then cast(DATENAME(WEEKDAY, map.EndDate) + ', ' + DATENAME(Month, map.EndDate) + ' ' + cast(datepart(dd,map.EndDate) as varchar(2)) as varchar(50))                        
      else     case when datepart(dd,map.EndDate) in (1,21,31) then cast(DATENAME(WEEKDAY, map.EndDate) + ', ' + cast(datepart(dd,map.EndDate) as varchar(2))+ 'st ' + DATENAME(Month,map.EndDate) as varchar(50))                         
      when datepart(dd,map.EndDate) in (2,22) then cast(DATENAME(WEEKDAY, map.EndDate) + ', ' + cast(datepart(dd,map.EndDate) as varchar(2))+ 'nd ' + DATENAME(Month,map.EndDate) as varchar(50))                         
      when datepart(dd,map.EndDate) in (3,23) then cast(DATENAME(WEEKDAY, map.EndDate) + ', ' + cast(datepart(dd,map.EndDate) as varchar(2))+ 'rd ' + DATENAME(Month,map.EndDate) as varchar(50))                         
      else cast(DATENAME(WEEKDAY, map.EndDate) + ', ' + cast(datepart(dd,map.EndDate) as varchar(2))+ 'th ' + DATENAME(Month,map.EndDate) as varchar(50))                         
     end                        
end as DeadlineDate,                        
cast ('' as varchar(50)) as Subject, /* BLANK */                        
map.segmentgroup as CatalogName,                        
ccs.CustomerSegmentNew,                        
--cast(ccs.CustomerID as varchar(15)) + '_' + CAST(Map.adcode as varchar (10)) as UserID /*Concatenation of customerid + '_' +  Adcode + '_' + CatalogName (remove space and use segment group)*/                        
cast('' as nvarchar(51)) as UserID                        
,csg.CountryCode                    
,ccs.NewSeg       
,map.MaxCourses as courseId                  
into staging.EPC_EmailPull_DailyDeals                        
from mapping.Email_adcode map (nolock)                        
inner join mapping.Country_segment_group csg (nolock)                         
on map.segmentgroup = csg.segmentgroup and map.CountryCode = csg.CountryCode                         
inner join  datawarehouse.Marketing.Vw_EPC_EmailPull  ccs (nolock)             
on csg.CountryCode = case when ccs.CountryCode IN ('AU','US','GB','CA') then ccs.CountryCode else 'ROW' end and  ccs.NewSeg=csg.NewSeg   and ccs.Name= csg.Name and ccs.A12MF = csg.A12MF --ccs.comboid = csg.comboid--                         
WHERE 1 = 1 --ccs.FlagEmail = 1 /*Removed due to EPC*/                  
--AND ccs.BuyerType > 1 (Get Inq also)                        
AND EmailAddress LIKE '%@%'                        
AND ccs.PublicLibrary = 0                        
AND ccs.CountryCode in ('GB')                        
and map.EmailID = @EmailID                        
and map.DLRFlag = 0                        
                        
                        
Print'Insert new records NoRFM into staging.EPC_EmailPull_DailyDeals'                        
                        
insert into staging.EPC_EmailPull_DailyDeals                
select                         
ccs.CustomerID,                        
ccs.LastName,                        
ccs.FirstName,       
ccs.EmailAddress,        
'N' as Unsubscribe,                        
cast('VALID' as varchar(15)) as EmailStatus,                        
map.SubjectLine,                        
cast(case when map.CourseFlag = 0                        
      then ''                        
      else        'Course list'                        
end as varchar(2000)) as CustHTML,                        
cast (ccs.State as varchar(50)) as [State],                        
map.AdCode,                        
CASE when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory = 'SC' then CAST('SCI' AS varchar(20))                         
     when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory = 'FA' then CAST('VA' AS varchar(20))                         
     when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory NOT IN ('SC', 'FA') then cast(ccs.preferredcategory AS varchar(20))                        
  when isnull(ccs.PreferredCategory2,'') = '' then CAST('GEN' AS varchar(20))                         
     else cast(ccs.PreferredCategory2 as varchar(20))                        
END as PreferredCategory,                        
ccs.ComboID,                        
datepart(d,map.startdate) as SendDate,                        
CAST(null as tinyint) as BatchID,                        
CAST('' as varchar(30)) as ECampaignID, /*Concatenation of 'Email' + Adcode + '_' + Startdate*/                        
case when ccs.countrycode = 'US' or ccs.countrycode = 'CA' /*Stopdate (format??)*/                
      then cast(DATENAME(WEEKDAY, map.EndDate) + ', ' + DATENAME(Month, map.EndDate) + ' ' + cast(datepart(dd,map.EndDate) as varchar(2)) as varchar(50))                        
  else     case when datepart(dd,map.EndDate) in (1,21,31) then cast(DATENAME(WEEKDAY, map.EndDate) + ', ' + cast(datepart(dd,map.EndDate) as varchar(2))+ 'st ' + DATENAME(Month,map.EndDate) as varchar(50))                         
      when datepart(dd,map.EndDate) in (2,22) then cast(DATENAME(WEEKDAY, map.EndDate) + ', ' + cast(datepart(dd,map.EndDate) as varchar(2))+ 'nd ' + DATENAME(Month,map.EndDate) as varchar(50))                         
      when datepart(dd,map.EndDate) in (3,23) then cast(DATENAME(WEEKDAY, map.EndDate) + ', ' + cast(datepart(dd,map.EndDate) as varchar(2))+ 'rd ' + DATENAME(Month,map.EndDate) as varchar(50))               
      else cast(DATENAME(WEEKDAY, map.EndDate) + ', ' + cast(datepart(dd,map.EndDate) as varchar(2))+ 'th ' + DATENAME(Month,map.EndDate) as varchar(50))                         
     end                        
end as DeadlineDate,                        
cast ('' as varchar(50)) as Subject, /* BLANK */                        
map.segmentgroup as CatalogName,                        
ccs.CustomerSegmentNew,                        
--cast(ccs.CustomerID as varchar(15)) + '_' + CAST(Map.adcode as varchar (10)) as UserID /*Concatenation of customerid + '_' +  Adcode + '_' + CatalogName (remove space and use segment group)*/                        
cast('' as nvarchar(51)) as UserID                        
,csg.CountryCode                   
,ccs.NewSeg          
,map.MaxCourses as courseId                
from mapping.Email_adcode map (nolock)                        
inner join mapping.Country_segment_group csg (nolock)                         
on map.segmentgroup = csg.segmentgroup and map.CountryCode = csg.CountryCode                         
inner join  datawarehouse.Marketing.Vw_EPC_EmailPull  ccs (nolock)                        
on csg.CountryCode = case when ccs.CountryCode IN ('AU','US','GB','CA') then ccs.CountryCode else 'ROW' end and  ccs.comboid = csg.comboid                        
WHERE 1 = 1 /*Removed due to EPC*/                  
--ccs.FlagEmail = 1                   
--AND ccs.BuyerType > 1                         
AND EmailAddress LIKE '%@%'                        
AND ccs.PublicLibrary = 0                        
AND ccs.CountryCode in ('GB')    
and ccs.comboid in ('NoRFM','highschool')     
and ccs.NewSeg is null                        
and map.DLRFlag = 0                        
and map.EmailID = @EmailID                        
                        
END                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
----------------------------------------------Checking for email dupes and delete-----------------------------------------------------------              
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
                        
--Checking for dupes                        
if exists (select emailaddress,COUNT(*) from staging.EPC_EmailPull_DailyDeals                   
group by emailaddress                        
having COUNT(*)>1 )                        
                        
begin                         
Print 'Deletes due to Duplicates'                        
--declare @table varchar(100), @DistinctColumn varchar(100)                        
--Delete Dupe email accounts                        
                        
                    
delete a                        
--select a.*                         
from staging.EPC_EmailPull_DailyDeals a                        
inner join                         
(                        
select emailaddress,CustomerID,Rank() over (Partition BY Emailaddress order by customerid desc) as Rank                        
from staging.EPC_EmailPull_DailyDeals                        
where emailaddress in (                        
select emailaddress  from staging.EPC_EmailPull_DailyDeals                        
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
/*                        
Print 'Deletes due to magento Customer unsubcribe Failure'                        
delete a                        
--into EPC_EmailPullDEL                        
from staging.EPC_EmailPull_DailyDeals a join                        
      lstmgr.dbo.EmailIDsNOTinMagento_Suppress b on a.customerID = b.customerID                        
where a.customerid > 0                          
                        
delete a                        
from staging.EPC_EmailPull_DailyDeals a join                        
      lstmgr.dbo.EmailIDsNOTinMagento_Suppress b on a.emailaddress = b.emailaddress                        
where a.customerid > 0                          
*/                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
----------------------------------------Deletes due to CampaignEmail_RemoveUnsubs-----------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
Print 'Deletes due to CampaignEmail_RemoveUnsubs'                        
                        
print 'ignored this'                        
exec [Staging].[CampaignEmail_RemoveUnsubs] 'EPC_EmailPull_DailyDeals'                        
                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------update customers Records based on the inquirer country------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
if @CountryCode in ('US','CA')                        
begin                        
                        
select * from  datawarehouse.mapping.Email_adcode                        
where   EmailID = @EmailID and SegmentGroup = 'Inquirers' and DLRFlag = 0                        
                        
declare @AdcodeInqCanada int =0                         
select @AdcodeInqCanada = isnull(Adcode,0) from  datawarehouse.mapping.Email_adcode                        
where   EmailID = @EmailID and SegmentGroup = 'Swamp Control' and Countrycode='CA' and DLRFlag = 0                        
select '@AdcodeInqCanada', @AdcodeInqCanada                        
if     @AdcodeInqCanada is not null                    
begin                    
update a                        
set adcode = @AdcodeInqCanada                         
--select *                         
from staging.EPC_EmailPull_DailyDeals a                        
where adcode = @AdcodeInq and CountryCode = 'CA'                        
                        
                        
declare @AdcodeInqInternational int =0                        
select @AdcodeInqInternational = isnull(Adcode,0) from  datawarehouse.mapping.Email_adcode             
where  EmailID = @EmailID and SegmentGroup = 'International' and Countrycode='ROW' and DLRFlag = 0                        
                        
select '@AdcodeInqInternational', @AdcodeInqInternational                        
                        
update a                        
set adcode = @AdcodeInqInternational                         
--select *                         
from staging.EPC_EmailPull_DailyDeals a                        
where adcode = @AdcodeInq and CountryCode not in ('US','CA')                        
End                        
END                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------update customers for PM8 pricing based on PM8 adcode--------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
if @CountryCode in ('US','CA')                        
begin                        
                        
Print 'PM8 Started'                        
                          
--update lowvalue adcode         
select * from  datawarehouse.Mapping.Email_Adcode                        
where   EmailID = @EmailID and SegmentGroup = 'PM8' and DLRFlag = 0                        
                        
declare @pm8 int =0  ,@PM8StartDate datetime                        
select @pm8 = isnull(Adcode,0), @PM8StartDate = startdate                          
from  datawarehouse.Mapping.Email_Adcode                        
where EmailID = @EmailID and SegmentGroup = 'PM8' and DLRFlag = 0                        
                        
                      
              
if @PM8StartDate is null               
begin               
select @PM8StartDate = MAX(Startdate)               
from  datawarehouse.mapping.Email_adcode_Format                    
where EmailID = @EmailID              
end                        
              
select '@pm8', @pm8,'@PM8StartDate' ,   @PM8StartDate                      
                        
                        
print 'PM 8 Update 1'                        
if  @pm8 is not null                    
begin                    
update a                        
set a.adcode = @pm8                        
--select COUNT(distinct a.customerid)                        
from staging.EPC_EmailPull_DailyDeals a                        
join                        
(select * from rfm.dbo.WPTest_Random2013                         
where HVLVGroup in ('LV')                        
and JFYEmailDLRDate>= @PM8StartDate                        
) b on A.customerid=b.CustomerID                         
where A.comboid in ('16sL0','26s30')                  
and A.Adcode in (select distinct Adcode from  datawarehouse.Mapping.Email_Adcode                        
    where EmailID = @EmailID and DLRFlag = 0 and SegmentGroup in ('Active Control','Swamp Control', 'Inquirers'))                        
                        
                        
print 'PM 8 Update 2'                         
                                    
update a                                     
set a.adcode= @pm8                        
--select COUNT(distinct a.customerid)                        
from staging.EPC_EmailPull_DailyDeals a                        
join                        
 (select * from rfm.dbo.WPTest_Random2013                         
 where HVLVGroup in ('LV')           
 and JFYEmailDLRDate>= @PM8StartDate                        
 ) b  on A.emailaddress=b.EmailAddress                        
where A.comboid in ('16sL0','26s30')                         
and A.Adcode in (select distinct Adcode from  datawarehouse.Mapping.Email_Adcode                        
    where EmailID = @EmailID and DLRFlag = 0 and SegmentGroup in ('Active Control','Swamp Control', 'Inquirers'))                        
                        
                        
print 'PM 8 results'                        
exec staging.GetAdcodeInfo_test  'staging.EPC_EmailPull_DailyDeals', datawarehouse                        
end                        
END                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------update customers for PM5 pricing based on PM5 adcode--------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
if @CountryCode in ('US','CA')                        
begin                        
Print 'PM5 Started'       
--update highvalue adcode                        
select * from  datawarehouse.mapping.Email_adcode                        
where EmailID = @EmailID and SegmentGroup = 'PM5' and DLRFlag = 0                        
                        
declare @pm5 int = 0,@PM5StartDate datetime                        
select @pm5 = isnull(Adcode,0) ,@PM5StartDate = Startdate                         
from  datawarehouse.mapping.Email_adcode                        
where EmailID = @EmailID and SegmentGroup = 'PM5' and DLRFlag = 0                        
                        
              
if @PM5StartDate is null               
begin               
select @PM5StartDate = MAX(Startdate)               
from  datawarehouse.mapping.Email_adcode_Format                    
where EmailID = @EmailID              
end                        
              
select '@pm5', @pm5,'@PM5StartDate' ,   @PM5StartDate                      
                        
print 'PM 5 Update 1'                        
   if  @pm5 is not null         
begin                    
update a                        
set a.adcode = @pm5                        
--select COUNT(distinct a.customerid)                        
from staging.EPC_EmailPull_DailyDeals a                        
join                        
(select * from rfm.dbo.WPTest_Random2013                         
where HVLVGroup in ('MV')                        
and JFYEmailDLRDate>= @PM5StartDate                        
) b on A.customerid=b.CustomerID                         
where A.comboid in ('16sL0','26s30')                         
and A.Adcode in (select distinct Adcode from  datawarehouse.mapping.Email_adcode                        
    where  EmailID = @EmailID and DLRFlag = 0 and  SegmentGroup in ('Active Control','Swamp Control', 'Inquirers'))                        
                                      
                     
print 'PM 5 Update 2'                           
                                    
update a                                     
set a.adcode= @pm5                        
--select COUNT(distinct a.customerid)                        
from staging.EPC_EmailPull_DailyDeals a                        
join                        
 (select * from rfm.dbo.WPTest_Random2013                         
 where HVLVGroup in ('MV')                         
 and JFYEmailDLRDate>= @PM5StartDate                        
 ) b  on A.emailaddress=b.EmailAddress                        
where A.comboid in ('16sL0','26s30')                         
and A.Adcode in (select distinct Adcode from   datawarehouse.mapping.Email_adcode                        
    where EmailID = @EmailID and DLRFlag = 0 and SegmentGroup in ('Active Control','Swamp Control', 'Inquirers'))                        
                        
print 'PM 5 results'                        
exec staging.GetAdcodeInfo_test  'staging.EPC_EmailPull_DailyDeals', datawarehouse                        
End                        
END                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                  
--------------------------------update customers for Deep Swamp based on customersegmentnew in ('DeepInactive')-----------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
if @CountryCode in ('US','CA')                        
begin                        
                        
/*               
declare @DeepSwamp int   
select @DeepSwamp = Adcode from   datawarehouse.Mapping.Email_Adcode                        
where segmentGroup = 'Swamp control'                        
                        
select '@DeepSwamp', @DeepSwamp                        
                        
                        
update a                        
set a.adcode=@DeepSwamp                        
--select count(*)                        
from staging.EPC_EmailPull_DailyDeals a                        
where a.customersegmentnew in ('DeepInactive')                        
and a.adcode  in (select distinct Adcode from  datawarehouse.Mapping.Email_Adcode                        
    where --EmailID = @EmailID and                         
    SegmentGroup in ('Active Control'))                        
                        
                        
                        
                        
update a                        
set a.adcode=@DeepSwamp                        
--select count(*)                        
from staging.EPC_EmailPull_DailyDeals a                        
where a.customersegmentnew in ('NewToFile_PM5','NewToFile_PM8')                        
-- and a.adcode=105004                        
and a.adcode  in (select distinct Adcode from  datawarehouse.Mapping.Email_Adcode                        
    where SegmentGroup in ('Active Control'))                        
                        
  */                          
                          
                        
declare @Swamp int = 0   , @RAMControlAdcode int = 0   ,@RAMTestAdcode int = 0                       
select @Swamp = isnull(Adcode,0) from   datawarehouse.Mapping.Email_Adcode                        
where EmailID = @EmailID and DLRFlag = 0 and segmentGroup = 'Swamp control' and countrycode= 'US'                        
select '@Swamp', @Swamp                        
                    
If @Swamp is not null                    
begin                        
update a                        
set a.adcode=@Swamp                        
--select count(*)                        
from staging.EPC_EmailPull_DailyDeals a                        
where a.customersegmentnew in ('NewToFile_PM5','NewToFile_PM8')                        
and a.adcode  in (select distinct Adcode from  datawarehouse.Mapping.Email_Adcode                        
    where EmailID = @EmailID and DLRFlag = 0 and SegmentGroup in ('Active Control') and countrycode= 'US')                        
 end                    
  
    set @RAMControlAdcode = @Swamp
	set @RAMTestAdcode = @Swamp
--CA NewToFile_PM5                        
select @Swamp = isnull(Adcode,0) from   datawarehouse.Mapping.Email_Adcode                        
where EmailID = @EmailID and DLRFlag = 0 and segmentGroup = 'Swamp control' and countrycode= 'CA'                        
select '@Swamp', @Swamp                        
                    
If @Swamp is not null                    
begin      
update a                        
set a.adcode=@Swamp                        
--select count(*)                        
from staging.EPC_EmailPull_DailyDeals a                        
where a.customersegmentnew in ('NewToFile_PM5','NewToFile_PM8')                        
and a.adcode  in (select distinct Adcode from  datawarehouse.Mapping.Email_Adcode      
    where EmailID = @EmailID and DLRFlag = 0 and SegmentGroup in ('Active Control') and countrycode= 'CA')                        
end                        
                        
                        
END                         
                       
					   

/* Canada CANSPAM Clean up Can not send them any email after 24 months*/
Delete from staging.EPC_EmailPull_DailyDeals
where CountryCode = 'CA'
and isnull(Newseg,20)>15

                     
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
-------------------------------------------------------DLR Updates based of mailing---------------------------------------------------------    
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
If exists (select COUNT(*) from mapping.Email_adcode                         
where DLRAdcode > 0 and EmailID = @EmailID                         
group by DLRAdcode)                        
                        
Begin                        
print 'Before DLR'                        
exec staging.GetAdcodeInfo_test  'staging.EPC_EmailPull_DailyDeals', datawarehouse                        
                        
Select customerid,adcode ,ComboID                        
into #DLR                         
from DataWarehouse.Archive.MailhistoryCurrentYear (nolock)                        
where AdCode in                         
(select distinct DLRAdCode from datawarehouse.mapping.Email_adcode (nolock) where DLRFlag = 1 and  EmailID = @EmailID and EmailCompletedFlag = 0 and DLRAdcode > 0 )                        
                        
                        
                        
update Email                        
Set Email.Adcode = EA.Adcode,                        
email.comboid = DLR.ComboID                        
--select count(*)--Ea.Adcode,DLR.Adcode, Email.*                         
from staging.EPC_EmailPull_DailyDeals Email                        
left join #DLR  DLR                        
on Email.customerid=DLR.customerid                        
left join datawarehouse.mapping.Email_adcode EA                        
on EA.DLRAdcode=DLR.Adcode                        
where EA.EmailID = @EmailID and DLRAdcode > 0                    
                        
                        
print 'After DLR'                        
exec staging.GetAdcodeInfo_test  'staging.EPC_EmailPull_DailyDeals', datawarehouse                        
                        
                        
drop table #DLR                        
                        
END                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
-------------------------------------------------------DLR Updates Completed----------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                     
/*Dormant Customer HoldOuts*/

declare @DormantHolder int = 0    
                  
select @DormantHolder = isnull(Adcode,0) from   datawarehouse.Mapping.Email_Adcode                        
where EmailID = @EmailID and DLRFlag = 0 and segmentGroup = 'Dormant Holdout' and countrycode= 'US'                        
select '@DormantHolder', @DormantHolder   

If @DormantHolder>0
Begin

  insert into Archive.Email_DormantCustomer_Holdout_20170816 
  select distinct CustomerID,@DormantHolder as Adcode,cast(A.startdate as date) as StartDate,1 as FlagHoldOut,ComboID,PreferredCategory,EmailAddress,getdate() as DMlastupdated
  from Datawarehouse.staging.EPC_EmailPull_DailyDeals E
  join datawarehouse.Mapping.Email_Adcode A
  on A.adcode = E.adcode and A.EmailID = @EmailID
  where E.customerid in (select distinct Customerid from Archive.Email_DormantCustomer_Holdout_20170816)                  


  Delete from Datawarehouse.staging.EPC_EmailPull_DailyDeals
  where customerid in (select distinct Customerid from Archive.Email_DormantCustomer_Holdout_20170816)   


End

--------------------------------------------------------------------------------------------------------------------------------------------     
--------------------------------------------------------------------------------------------------------------------------------------------                        
---------------------------------------------------------RAM Process Start------------------------------------------------------------------      
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                
      
Declare  @Senddate  datetime   /* Send date is used for the RAM adcode date */      
--select @RAMControlAdcode = isnull(Adcode,0),@Senddate = Startdate from   datawarehouse.Mapping.Email_adcode                 
--where EmailID = @EmailID and DLRFlag = 0 and segmentGroup = 'RAM' and countrycode= 'US'  --Ram roll out on 7/26/2016 VB                   
   

         
----Declare @RAMTestAdcode int = 0                   
--select @RAMTestAdcode = isnull(Adcode,0) from   datawarehouse.Mapping.Email_adcode                        
--where EmailID = @EmailID and DLRFlag = 0 and segmentGroup = 'RAM' and countrycode= 'US'         
                  

select  '@RAMControlAdcode', @RAMControlAdcode , '@RAMTestAdcode', @RAMTestAdcode   ,'@Senddate' ,  @Senddate      


      
If @RAMControlAdcode>0 and @RAMTestAdcode>0      
      
begin      
      
Alter table datawarehouse.staging.EPC_EmailPull_DailyDeals add ComboidPrior varchar (30)      
    
Update E     
set E.ComboidPrior = MRAM.ComboidPrior    
from datawarehouse.staging.EPC_EmailPull_DailyDeals E    
Inner join DataWarehouse.Mapping.RAM_CustomerCohort MRAM      
on E.CustomerID = MRAM.CustomerID      
where MRAM.CustomerSegmentFnlPrior <>'Active_Multi'      
    
      

      
/* update Email table with RAMControl and RAMTest Adcodes*/      
      
update E      
set E.Adcode = Case when RAM.custgroup = 'Control' then @RAMControlAdcode      
     when RAM.custgroup = 'TEST' Then @RAMTestAdcode      
    end,      
 E.Comboidprior = RAM.Comboidprior      
from datawarehouse.staging.EPC_EmailPull_DailyDeals E       
inner join (      
select customerid,custgroup,Comboidprior 
from DataWarehouse.Mapping.RAM_CustomerCohort      
)RAM      
on Ram.customerid = E.CustomerID      
      
END      
      
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
---------------------------------------------------------RAM Process End--------------------------------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------------------                    
                  
                  
----------------------------------------------------------------------------------------------------------------------------------------------------                  
--------------------------------------------------------Block for adding New EPC Emails-------------------------------------------------------------                  
----------------------------------------------------------------------------------------------------------------------------------------------------                  
                  
--If exists  (select * from DataWarehouse.Mapping.Email_adcode where SegmentGroup like '%Match' and EmailID = @EmailID  )                  
if @CountryCode in ('US','CA')                  
Begin                  
                  
--#Matched                  
select E.*      
into #Matched                  
from DataWarehouse.staging.EPC_EmailPull_DailyDeals E           
inner join DataWarehouse.Marketing.CampaignCustomerSignature ccs                  
on E.customerid = CCS.CustomerID and E.Emailaddress= CCs.EmailAddress          
where E.CountryCode = 'US'         
                  
--#EmailsNotMatched                  
select E.*                   
into #EmailsNotMatched                  
from DataWarehouse.staging.EPC_EmailPull_DailyDeals E                  
left join #Matched M                  
on m.emailaddress=e.emailaddress                  
where m.emailaddress is null     
and E.CountryCode = 'US'                      
                  
                  
--#SNI                  
select E.CustomerID,E.EmailAddress                  
into #SNI                   
from DataWarehouse.staging.EPC_EmailPull_DailyDeals E                  
inner join #EmailsNotMatched E1                  
on E.CustomerID = E1.CustomerId and E.EmailAddress = E1.Emailaddress                  
where E.CatalogName <> 'Active Control'        
and E.CountryCode = 'US'                   
                  
--Valid Emails                  
--#MatchCustomeriD                  
select a.CustomerID,A.EmailAddress                     
into #MatchCustomeriD                  
from DataWarehouse.staging.EPC_EmailPull_DailyDeals a                  
join  DataWarehouse.Marketing.CampaignCustomerSignature b                  
on a.customerid = b.customerid and a.emailaddress <> b.EmailAddress                  
where CatalogName = 'Active Control'                  
and b.EmailAddress <> ''      
and a.CountryCode = 'US'                  
                  
--Blank Emails                  
--#Nomatch                  
select a.CustomerID,A.EmailAddress                    
into #Nomatch                  
from DataWarehouse.staging.EPC_EmailPull_DailyDeals a                  
join  DataWarehouse.Marketing.CampaignCustomerSignature b                  
on a.customerid = b.customerid and a.emailaddress <> b.EmailAddress                  
where CatalogName = 'Active Control'                  
and b.EmailAddress = ''                  
and a.CountryCode = 'US'                        
                  
                  
--#SNI                  
                  
print 'Deleting extra swamp emails based on newseg changes'                  
                  
delete e                  
from staging.EPC_EmailPull_DailyDeals e                  
inner join #SNI s                  
on s.EmailAddress=e.EmailAddress and s.CustomerID=e.CustomerID                  
--inner join Marketing.Vw_EPC_EmailPull V                  
--on v.Emailaddress = e.Emailaddress                  
where e.NewSeg not in (11,12,13,14,15,20,18,19,23,24,25,28)                  
and e.CountryCode = 'US'                    
                  
print 'Deleting extra swamp emails where CountryCode<>US'                  
delete e                  
from staging.EPC_EmailPull_DailyDeals e       
inner join #SNI s                  
on s.EmailAddress=e.EmailAddress and s.CustomerID=e.CustomerID                  
where e.CountryCode<>'US'                  
                  
                  
Declare @SwampMatchCustomeriDAdcode int = 0                   
select @SwampMatchCustomeriDAdcode = isnull(Adcode,0) from   datawarehouse.Mapping.Email_adcode                        
where EmailID = @EmailID and DLRFlag = 0 and segmentGroup = 'Swamp match' and countrycode= 'US'                     
select '@SwampMatchCustomeriDAdcode', @SwampMatchCustomeriDAdcode                      
                  
/*                  
Update e Set e.Adcode = @SwampMatchCustomeriDAdcode,E.CatalogName = 'Swamp match'                  
from staging.EPC_EmailPull_DailyDeals e                  
inner join #SNI s                  
on s.EmailAddress=e.EmailAddress and s.CustomerID=e.CustomerID                  
*/                  
                  
--#MatchCustomeriD                  
/*
print 'deleting #MatchCustomeriD emails where CountryCode<>US'                  
delete e 
from staging.EPC_EmailPull_DailyDeals e                  
inner join #MatchCustomeriD s                  
on s.EmailAddress=e.EmailAddress and s.CustomerID=e.CustomerID  
where e.CountryCode<>'US'       
*/   
                  
Declare @MatchCustomeriDAdcode int = 0                   
select @MatchCustomeriDAdcode = isnull(Adcode,0) from   datawarehouse.Mapping.Email_adcode                        
where EmailID = @EmailID and DLRFlag = 0 and segmentGroup = 'EPC Active' and countrycode= 'US'                     
select '@MatchCustomeriDAdcode', @MatchCustomeriDAdcode                      
  
/*                     
Update e Set e.Adcode = @MatchCustomeriDAdcode,E.CatalogName = 'EPC Active'                  
from staging.EPC_EmailPull_DailyDeals e                  
inner join #MatchCustomeriD s                  
on s.EmailAddress=e.EmailAddress and s.CustomerID=e.CustomerID                  
*/                   
--#Nomatch                  
                  
/*   
print 'deleting #Nomatch emails where CountryCode<>US'                  
delete e                  
from staging.EPC_EmailPull_DailyDeals e                  
inner join #Nomatch s                  
on s.EmailAddress=e.EmailAddress and s.CustomerID=e.CustomerID                  
where e.CountryCode<>'US'                  
*/

/*Merging EPC Match and EPC No Match*/
/*                  
Declare @NomatchAdcode int = 0                   
select @NomatchAdcode = isnull(Adcode,0) from   datawarehouse.Mapping.Email_adcode                        
where EmailID = @EmailID and DLRFlag = 0 and segmentGroup = 'Active Nomatch' and countrycode= 'US'                     
select '@NomatchAdcode', @NomatchAdcode                      
*/

/*Merging EPC Match and EPC No Match*/
--Update e Set e.Adcode =  @NomatchAdcode,E.CatalogName = 'Active Nomatch'    
/*
Update e Set e.Adcode = @MatchCustomeriDAdcode,E.CatalogName = 'EPC Active'                  
from staging.EPC_EmailPull_DailyDeals e                  
inner join #Nomatch s                  
on s.EmailAddress=e.EmailAddress and s.CustomerID=e.CustomerID                  
*/          
                   
DROP table #Matched                  
DROP table #EmailsNotMatched                  
                  
DROP table #SNI                  
DROP table #MatchCustomeriD                  
DROP table #Nomatch                  
                  
End                  
----------------------------------------------------------------------------------------------------------------------------------------------------                  
--------------------------------------------------------Block Ends for adding New EPC Emails--------------------------------------------------------                  
----------------------------------------------------------------------------------------------------------------------------------------------------   
                        
                  
----------------------------------------------------------------------------------------------------------------------------------------------------                  
--------------------------------------------------------Block for Prospect New EPC Emails--------------------------------------------------------                  
----------------------------------------------------------------------------------------------------------------------------------------------------                  
if exists (select * from  datawarehouse.mapping.Email_adcode  where   EmailID = @EmailID and SegmentGroup = 'Prospects' )                      
                
begin                
                
                
if OBJECT_ID('staging.EPC_EmailPull_DailyDeals_PRSPCT') is not null                        
drop table  staging.EPC_EmailPull_DailyDeals_PRSPCT                    
                
-- All Prospect Emails                
 select DISTINCT Emailaddress               
 into #prospect                
 from DataWarehouse.Marketing.Vw_EPC_Prospect_EmailPull                 
 where store_country not in ('au_en','uk_en')                
 and website_country not in ('UK','AU','Australia')       
 --order by magento_created_date desc                
      
                 
   CREATE TABLE staging.EPC_EmailPull_DailyDeals_PRSPCT(                
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
 [Priority] [varchar](250) NULL,
 [CourseId] int                
                
) ON [PRIMARY]                
                
Insert into staging.EPC_EmailPull_DailyDeals_PRSPCT                
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
 Map.Priority as Priority ,
 map.maxcourses as CourseId               
  from #prospect P                 
  ,(select top 1 * from DataWarehouse.Mapping.Email_adcode where EmailId = @EmailID and SegmentGroup = 'Prospects') map                
  where emailaddress not like '%teachco%'                
                
set @sql = 'select * Into Lstmgr..'+ @EmailID + '_PRSPCT from staging.EPC_EmailPull_DailyDeals_PRSPCT'                      
exec (@sql)                 
                
                
drop table #prospect                
                
End                
                  
----------------------------------------------------------------------------------------------------------------------------------------------------                  
--------------------------------------------------------Block ends for Prospect New EPC Emails--------------------------------------------------------                  
----------------------------------------------------------------------------------------------------------------------------------------------------                  
                             
                  


print 'Before keep'                    
exec staging.GetAdcodeInfo_test  'staging.EPC_EmailPull_DailyDeals', datawarehouse    
                  
delete E from staging.EPC_EmailPull_DailyDeals E
join #CustFinal f
on f.emailaddress = e.emailaddress
where F.keep = 0

print 'After keep'                        
exec staging.GetAdcodeInfo_test  'staging.EPC_EmailPull_DailyDeals', datawarehouse    		                  
                  
                  
                  
                     
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------           
-------------------------------Splitter to split counts based of the percentage of records in mapping---------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
if exists (select COUNT(*) from mapping.Email_adcode                         
where primary_adcode is not null and EmailID = @EmailID                         
group by primary_adcode having COUNT(*)>1 )                         
Begin                        
                        
print 'Before Splitter'                        
                        
exec staging.GetAdcodeInfo_test  'staging.EPC_EmailPull_DailyDeals', datawarehouse                        
                        
                        
                  
alter table staging.EPC_EmailPull_DailyDeals add EmailCnt int                  
                  
update a                  
set a.EmailCnt = b.EmailCnt           --1       /* EPC Test emails split counts issue 8/1/2017*/
from staging.EPC_EmailPull_DailyDeals a                  
left join                   
(select Customerid,COUNT(*) as EmailCnt                  
from staging.EPC_EmailPull_DailyDeals                  
group by Customerid) b                  
on a.customerid = b.customerid                  
                  
                  
                        
--#primaryadcode                        
select primary_adcode,0 as processed  into #primaryadcode                         
from mapping.Email_adcode                         
where primary_adcode is not null and EmailID = @EmailID                         
group by primary_adcode having COUNT(*)>1                          
                        
  while exists (select top 1 * from #primaryadcode where processed=0 order by primary_adcode)                        
   Begin                        
                        
   declare @primary_adcode varchar(10)                        
                        
   select top 1 @primary_adcode=primary_adcode from #primaryadcode where processed=0 order by primary_adcode                        
                        
   select '@primary_adcode',@primary_adcode                        
                        
                        
   --#adcode                        
   select adcode,split_percentage,primary_Adcode into #adcode                       
   from mapping.Email_adcode where primary_Adcode=@primary_adcode and EmailID = @EmailID                        
                        
                        
   --#splitter                        
   Create table #splitter (adcode varchar(10),primary_adcode varchar(10),comboid varchar(20),preferredcategory varchar(30), split_percentage int,EmailCnt int,Cnt int, processed bit default(0))                        
   Insert into #splitter (adcode,comboid,preferredcategory,EmailCnt,cnt,primary_adcode,split_percentage )                        
 select adcode,comboid,preferredcategory,EmailCnt,cnt,primary_Adcode,split_percentage from #adcode,                        
   ( select coalesce(comboid,'yyy') as comboid,coalesce(preferredcategory,'xxx') as preferredcategory ,EmailCnt,COUNT(distinct customerid) Cnt                  
            From                  
            (                  
               select Customerid,coalesce(comboid,'yyy') as comboid,coalesce(preferredcategory,'xxx') as preferredcategory, EmailCnt                        
               From staging.EPC_EmailPull_DailyDeals                        
               Where adcode = @primary_adcode                     
               group by Customerid,coalesce(comboid,'yyy'),coalesce(preferredcategory,'xxx')   ,EmailCnt                     
            )  a                  
 Group by coalesce(comboid,'yyy'),coalesce(preferredcategory,'xxx') ,EmailCnt                  
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
                        
                        
   declare @adcode varchar(10), @PrimaryAdcode varchar(10),@EmailCnt varchar(15),@Cnt varchar(15),@comboid varchar(20),@preferredcategory varchar(20)                        
                        
 while exists (select top 1 * from #splitter where processed=0 order by adcode)                        
      Begin                        
                        
      select top 1 @adcode = adcode ,@PrimaryAdcode=primary_adcode, @Emailcnt = Emailcnt, @cnt = cnt,@comboid=comboid,@preferredcategory=preferredcategory                         
      from #splitter                         
      where processed=0                         
      order by adcode,comboid,preferredcategory ,Emailcnt                       
                        
      select  @adcode as adcode , @PrimaryAdcode as PrimaryAdcode,@Emailcnt as Emailcnt, @Cnt as cnt,@comboid as comboid,@preferredcategory as preferredcategory                        
                              
      Print 'updating records for above segments'                        
      exec ('update staging.EPC_EmailPull_DailyDeals                         
          set adcode = '+ @adcode +                        
        ' where adcode = '+ @PrimaryAdcode +' and customerID in (select top ' + @Cnt + '  customerID   from staging.EPC_EmailPull_DailyDeals where adcode = '+ @PrimaryAdcode +                   
        ' and comboid= '''+ @comboid + ''' and EmailCnt= '''+ @Emailcnt + ''' and  preferredcategory  = ''' + @preferredcategory + ''' order by NEWID() )')                        
                        
      update #splitter                        
      set processed=1       
     where adcode=@adcode and comboid=@comboid and preferredcategory = @preferredcategory  and Emailcnt  = @Emailcnt                  
                        
      END                        
                        
   drop table #adcode                        
   drop table #splitter                        
                        
                        
   update #primaryadcode                        
   set processed=1                        
   where primary_adcode = @primary_adcode              
                        
   END                        
drop table #primaryadcode                        
alter table staging.EPC_EmailPull_DailyDeals drop column EmailCnt                        
                        
                        
                        
print 'After Splitter'                        
exec staging.GetAdcodeInfo_test  'staging.EPC_EmailPull_DailyDeals', datawarehouse        

Declare @EPC_TEST_Adcode int = 0                   
select @EPC_TEST_Adcode = isnull(Adcode,0) from  datawarehouse.Mapping.Email_adcode                        
where EmailID = @EmailID and DLRFlag = 0 and segmentGroup = 'EPC TEST' and countrycode= 'US'                     
select '@EPC_TEST_Adcode', @EPC_TEST_Adcode                      


Update staging.EPC_EmailPull_DailyDeals
set Adcode = @EPC_TEST_Adcode,CatalogName = 'EPC Test'                
Where Adcode = @MatchCustomeriDAdcode
and CustomerID in ( select distinct CustomerID from staging.EPC_EmailPull_DailyDeals where Adcode = @adcode)

    
print 'After EPC Test changes'                        
exec staging.GetAdcodeInfo_test  'staging.EPC_EmailPull_DailyDeals', datawarehouse   
                        
End               
                        
Else                 
                        
begin               
print 'No Splits'                        
End                        
                       
                        
Print 'Delete New Customers whos segments are pending from Picking work bench'                        
                        
if (datepart(dw,getdate()) <=  2) --Sunday/Monday                           
Begin                        
                        
Print 'Sunday and Monday deletes'                        
                        
delete EP                        
from datawarehouse.staging.EPC_EmailPull_DailyDeals EP                        
inner join DataWarehouse.Marketing.Vw_EPC_EmailPull ccs (nolock)                        
on EP.customerid = ccs.CustomerID                        
where ccs.CustomerSince>= DATEADD(DAY, -3, DATEADD(WEEK, DATEDIFF(WEEK, 0, getdate()), 0))                        
                        
End                        
                        
                        
else                        
            Begin                        
                        
Print 'Except the Sunday and Monday go back 1 day'                        
                        
delete EP                        
from datawarehouse.staging.EPC_EmailPull_DailyDeals EP                        
inner join DataWarehouse.Marketing.Vw_EPC_EmailPull ccs (nolock)                        
on EP.customerid = ccs.CustomerID                        
where ccs.CustomerSince> = cast( (getdate()-1) as date)                        
                        
End                        
                        
                        
--Delete Customers who have emails which are in US                        
if @CountryCode  in ('AU')                        
begin                        
Delete AU                        
from datawarehouse.staging.EPC_EmailPull_DailyDeals  AU                        
left join DataWarehouse.Marketing.Vw_EPC_EmailPull ccs (nolock)                        
on au.emailaddress=ccs.EmailAddress                        
where ccs.CountryCode<>'AU'                        
                        
END                        
             
if @CountryCode  in ('GB')                        
Begin 
                        
delete GB                         
from datawarehouse.staging.EPC_EmailPull_DailyDeals GB                        
left join DataWarehouse.Marketing.Vw_EPC_EmailPull ccs (nolock)                        
on gb.emailaddress=ccs.EmailAddress                        
where ccs.CountryCode<>'GB'                        
                        
End                        
                        
--update issues with preferedcat spaces                        
Update staging.EPC_EmailPull_DailyDeals                        
Set preferredcategory =replace(preferredcategory,' ','')                        
where PreferredCategory like '% %'                        
      
      
                      
--------------------------------------------------------------------------------------------------------------------------------------------         
--------------------------------------------------------------------------------------------------------------------------------------------        
---------------------------------------------------Price Test Match for catalog 2/27/2017---------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------        
If @CountryCode in ('US','CA','ROW')   

BEGIN

declare @MovedtoSwamp int = 0                       
select @MovedtoSwamp = isnull(Adcode,0) from   datawarehouse.Mapping.Email_Adcode              
where EmailID = @EmailID and DLRFlag = 0 and segmentGroup = 'Swamp control' and countrycode= 'US'                        
select '@MovedtoSwamp', @MovedtoSwamp 

/*10-12mo Active Multis from 12m – Those with CustomerID end with 3-9 (70% of 10-12mo) have been moved to Reactivation 
(NewSeg in (8,9,10) and Recency in (10,11,12) and right(CustomerID,1) in (3,4,5,6,7,8,9))
 */

Update a set a.adcode = @MovedtoSwamp 
--SELECT * 
FROM staging.EPC_EmailPull_DailyDeals a
JOIN Staging.vwCustomerRecency cr on a.CustomerID = cr.CustomerID
WHERE (NewSeg in (8,9,10) AND Recency in (10,11,12) AND right(a.CustomerID,1) in (3,4,5,6,7,8,9))
AND CountryCode = 'US'

declare @MovedtoDeepSwamp int = 0                       
select @MovedtoDeepSwamp = isnull(Adcode,0) from   datawarehouse.Mapping.Email_Adcode                        
where EmailID = @EmailID and DLRFlag = 0 and segmentGroup = 'Deep Swamp' and countrycode= 'US'                        
select '@MovedtoDeepSwamp', @MovedtoDeepSwamp 

/*12sL – they have been moved to Deep Swamp*/

Update a set a.adcode = @MovedtoDeepSwamp 
--SELECT * 
FROM staging.EPC_EmailPull_DailyDeals a
WHERE a.NewSeg = 6
AND a.CountryCode = 'US'

END


--------------------------------------------------------------------------------------------------------------------------------------------        
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                      
                  
alter table staging.EPC_EmailPull_DailyDeals add [Priority] [varchar](250) NULL                             
                        
--Update subjectline/adcode information.                        
update a                        
set a.CatalogName = case when map.SegmentGroup = ('Active Control') and map.CountryCode in('US','GB','AU') then 'Active_Control'                        
       when map.SegmentGroup = ('Active Test') and map.Countrycode = 'US'    then 'Active_Test'                        
       when map.SegmentGroup = ('Active Control') and map.CountryCode = 'CA'    then 'Active_Canada'           
       when map.SegmentGroup = ('International') and map.CountryCode= 'ROW'    then 'Active_International'                        
       when map.SegmentGroup = ('Swamp Control') and map.Countrycode = 'US'    then 'Swamp_Control'                        
       when map.SegmentGroup = ('Swamp Control') and map.CountryCode = 'CA'    then 'Swamp_Canada'        
       when map.SegmentGroup = ('Swamp Test') and map.CountryCode = 'US'    then 'Swamp_Test'                        
       when map.SegmentGroup = ('Deep Test') and map.CountryCode = 'US'    then 'DeepSwamp_Test'     
       when map.SegmentGroup = ('Deep Swamp')            then 'Deep_Swamp'                               
       when map.SegmentGroup = ('PM5')             then 'Swamp_CEPM5'                         
       when map.SegmentGroup = ('PM8')             then 'Swamp_CEPM8'                            
       when map.SegmentGroup = ('Inquirers')            then 'Swamp_Control'                         
    when map.SegmentGroup = ('Active match')   then 'Active_CustomerIDMatch'                   
    when map.SegmentGroup = ('Active Nomatch')  then 'Active_NoMatch'                  
   when map.SegmentGroup = ('EPC Active')   then 'Active_EPC'            
    when map.SegmentGroup = ('EPC Test')   then 'Test_EPC'                   
    when map.SegmentGroup = ('Swamp Match')   then 'Swamp_Match'          
    when map.SegmentGroup = ('RAM Control')   then 'RAM_Control'          
    when map.SegmentGroup = ('RAM TEST')   then 'RAM_Test'          
    when map.SegmentGroup = ('RAM')   then 'RAM'  
    else 'Active_Control' end  ,                                  
a.BatchID = isnull(sz.TimeGroup, 6),                        
a.ECampaignID = 'Email'+ cast(a.Adcode as varchar(10))+'_' + convert(varchar(8), map.startdate, 112),                         
a.Subjectline = map.Subjectline,                  
a.Priority = map.Priority                        
from staging.EPC_EmailPull_DailyDeals a                        
left join mapping.Email_adcode map                        
on a.Adcode=map.primary_adcode --Adcode vik 2017/09/07 changed so we can add adcodes and seperate them by primary_adcode to split segments                        
left join Mapping.StateZone sz (nolock)                   
on sz.[State] = a.[State]                       
where map.EmailID = @EmailID                        
                  

print 'Before Daily Deals deletes Emails droppped where pref does not match and CustomerSegmentNew =  DeepInactive'
exec staging.GetAdcodeInfo_test  'staging.EPC_EmailPull_DailyDeals', datawarehouse   

if @CountryCode in ('US','CA')        
begin 
--/*Daily Deals deletes Emails droppped where pref does not match*/
print 'Daily Deals deletes  where pref does not match'
Delete E from staging.EPC_EmailPull_DailyDeals E
Join DataWarehouse.Mapping.DMCourse C
on E.courseId = C.CourseID
where (E.CustomerSegmentNew = 'DeepInactive')
and E.PreferredCategory <> C.SubjectCategory2
end  

--/*Daily Deals deletes where Customer has already purchased*/
print 'Daily Deals deletes where Customer has already purchased the Course'
Delete E from staging.EPC_EmailPull_DailyDeals E
Join DataWarehouse.Marketing.CompleteCoursePurchase C
on E.courseId = C.CourseID
and E.CustomerID = C.CustomerID



print 'Before Delete adcodes that are not in mapping and which were moved to default 0'                        
exec staging.GetAdcodeInfo_test  'staging.EPC_EmailPull_DailyDeals', datawarehouse    
                  
/* Delete adcodes that are not in mapping and moved to default 0*/                  
Delete from staging.EPC_EmailPull_DailyDeals                  
where Adcode = 0                  

		  
				  
				                          
--Update userid information.                        
update a                        
set a.userid = cast( a.CustomerID + '_' + CONVERT(varchar, a.Adcode) + '_'+ EmailAddress as nvarchar(51) ) --a.CustomerID + '_' + CONVERT(varchar, a.Adcode) + '_'+  CatalogName                        
from staging.EPC_EmailPull_DailyDeals a                        
                        
alter table staging.EPC_EmailPull_DailyDeals alter column [UserID] [nvarchar](51) NOT NULL                       
                        
/*********************Frequency Test customers ending in 3, 5 and customer since < 1/1/2017*************************************/
if exists (select top 1 1 from  datawarehouse.Mapping.Email_adcode Where EmailID = @EmailID and segmentGroup = 'FrequencyHoldOut' and countrycode= 'US'  )

Begin

 declare @FrequencyHoldOut int , @startdate date
 select top 1 @FrequencyHoldOut= adcode ,@startdate = startdate from  datawarehouse.Mapping.Email_adcode Where EmailID = @EmailID and segmentGroup = 'FrequencyHoldOut' and countrycode= 'US'

 print '@FrequencyHoldOut'
 print @FrequencyHoldOut 

 print '@startdate'
 print @startdate 

  insert into Datawarehouse.archive.EmailHistory2017FrequencyTestHoldouts  
  (CustomerID,Adcode,StartDate,FlagHoldOut,ComboID,PreferredCategory,EmailAddress)

  select E.CustomerID,@FrequencyHoldOut Adcode,@startdate as StartDate, 1 as FlagHoldOut,E.ComboID,E.PreferredCategory,E.EmailAddress
  from staging.EPC_EmailPull_DailyDeals E
  join DataWarehouse.Marketing.Vw_EPC_EmailPull ccs (nolock)                        
  on E.EmailAddress = ccs.EmailAddress                        
  where ccs.CustomerSince<'1/1/2017'  /* CustomerSince since date less than 1/1/2017 */
  and right(E.Customerid,1) in (3,5) /* Customerid's ending in 3,5 */

  Delete E    
  from staging.EPC_EmailPull_DailyDeals E
  join DataWarehouse.Marketing.Vw_EPC_EmailPull ccs (nolock)                        
  on E.EmailAddress = ccs.EmailAddress                        
  where ccs.CustomerSince<'1/1/2017'  /* CustomerSince since date less than 1/1/2017 */
  and right(E.Customerid,1) in (3,5) /* Customerid's ending in 3,5 */

End
                        
--Create Email pull table with email name                        
--set @sql = 'select * into staging.EPC_'+ @EmailID +   ' from staging.EPC_EmailPull_DailyDeals'      /*Removed EPC_ on 20151019 for future email pulls*/                  
set @sql = 'select * into staging.'+ @EmailID +   ' from staging.EPC_EmailPull_DailyDeals'                        
exec (@sql)                        
              
set @table = @EmailID            
                        
--Create Email Table in lstmgr                        
                        
Exec [Staging].[CampaignEmail_SplitTable_new] @TableName = @table ,@EmailName = 'NEW'                        
                        

/*Load into Mapping Table*/

insert into mapping.Email_DailyDealsCleanup
select top 1 EmailID,maxCourses	as CourseId,Startdate 
from mapping.Email_adcode
where emailid = @Emailid and maxCourses<>0
and Countrycode not in ('CA','ROW')

                        
update  mapping.Email_adcode                        
set  EmailCompletedFlag = 1                         
where EmailID = @EmailID                        
                        
print 'Email Completed Final Counts'                        
exec staging.GetAdcodeInfo_test  'staging.EPC_EmailPull_DailyDeals', datawarehouse     
                        
END                        
                        
if OBJECT_ID('staging.EPC_EmailPull_DailyDeals') is not null                        
drop table  staging.EPC_EmailPull_DailyDeals                        
                        
End                        
                        
                        
    
                  
                  
                  
                  
                  
                  
                  




				   

GO
