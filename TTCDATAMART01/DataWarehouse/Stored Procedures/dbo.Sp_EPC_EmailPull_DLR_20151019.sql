SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
  
  
  
  
CREATE proc [dbo].[Sp_EPC_EmailPull_DLR_20151019]        
as        
Begin        
        
Declare @EmailID varchar(50),@sql varchar(500),@CountryCode varchar(20),@table varchar(100)        
        
        
while exists (select top 1 EmailID from mapping.Email_adcode where EmailCompletedFlag = 0  order by EmailID)        
Begin        
        
select top 1 @EmailID = EmailID,@CountryCode = Countrycode         
from mapping.Email_adcode        
where EmailCompletedFlag = 0         
order by EmailID,Countrycode desc      
select @EmailID        
        
select * from mapping.Email_adcode        
where EmailID = @EmailID        
        
if OBJECT_ID('staging.EPC_EmailPull') is not null        
drop table  staging.EPC_EmailPull        
        
--------------------------------------------------------------------------------------------------------------------------------------------        
--------------------------------------------------------------------------------------------------------------------------------------------        
--------------------------------------------------------Add US, CA and ROW (No Inqs)--------------------------------------------------------        
--------------------------------------------------------------------------------------------------------------------------------------------        
--------------------------------------------------------------------------------------------------------------------------------------------        
if @CountryCode in ('US','CA')        
begin        
        
Print'Insert new records into staging.EPC_EmailPull'        
        
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
into staging.EPC_EmailPull        
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
        
        
Print'Insert new records NoRFM into staging.EPC_EmailPull'        
        
insert into staging.EPC_EmailPull        
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
Print'Insert new records (Inq)into staging.EPC_EmailPull'        
        
insert into staging.EPC_EmailPull        
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
FROM mapping.Email_adcode map (nolock)        
inner join mapping.Country_segment_group csg (nolock)         
on map.segmentgroup = csg.segmentgroup and map.CountryCode = csg.CountryCode         
inner join  datawarehouse.Marketing.Vw_EPC_EmailPull  ccs (nolock)        
on csg.CountryCode = case when ccs.CountryCode IN ('AU','US','GB','CA') then ccs.CountryCode else 'ROW' end and  ccs.comboid=csg.comboid     --and ccs.Name= csg.Name and ccs.A12MF = csg.A12MF        
LEFT OUTER JOIN staging.EPC_EmailPull EC01         
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
Print'Insert new records AU into staging.EPC_EmailPull'        
        
--insert into staging.EPC_EmailPull        
        
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
into staging.EPC_EmailPull        
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
        
        
Print'Insert new records NoRFM into staging.EPC_EmailPull'        
        
insert into staging.EPC_EmailPull        
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
        
Print'Insert new records GB into staging.EPC_EmailPull'        
        
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
into staging.EPC_EmailPull        
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
        
        
Print'Insert new records NoRFM into staging.EPC_EmailPull'        
        
insert into staging.EPC_EmailPull        
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
if exists (select emailaddress,COUNT(*) from staging.EPC_EmailPull        
group by emailaddress        
having COUNT(*)>1 )        
        
begin         
Print 'Deletes due to Duplicates'        
--declare @table varchar(100), @DistinctColumn varchar(100)        
--Delete Dupe email accounts        
        
        
delete a        
--select a.*         
from staging.EPC_EmailPull a        
inner join         
(        
select emailaddress,CustomerID,Rank() over (Partition BY Emailaddress order by customerid desc) as Rank        
from staging.EPC_EmailPull        
where emailaddress in (        
select emailaddress  from staging.EPC_EmailPull        
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
from staging.EPC_EmailPull a join        
      lstmgr.dbo.EmailIDsNOTinMagento_Suppress b on a.customerID = b.customerID        
where a.customerid > 0          
        
delete a        
from staging.EPC_EmailPull a join        
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
exec [Staging].[CampaignEmail_RemoveUnsubs] 'EPC_EmailPull'        
        
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
from staging.EPC_EmailPull a        
where adcode = @AdcodeInq and CountryCode = 'CA'        
        
        
declare @AdcodeInqInternational int =0        
select @AdcodeInqInternational = isnull(Adcode,0) from  datawarehouse.mapping.Email_adcode        
where  EmailID = @EmailID and SegmentGroup = 'International' and Countrycode='ROW' and DLRFlag = 0        
        
select '@AdcodeInqInternational', @AdcodeInqInternational        
        
update a        
set adcode = @AdcodeInqInternational         
--select *         
from staging.EPC_EmailPull a        
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
        
select '@pm8', @pm8        
        
        
print 'PM 8 Update 1'        
if  @pm8 is not null    
begin    
update a        
set a.adcode = @pm8        
--select COUNT(distinct a.customerid)        
from Staging.EPC_EmailPull a        
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
from Staging.EPC_EmailPull a        
join        
 (select * from rfm.dbo.WPTest_Random2013         
 where HVLVGroup in ('LV')         
 and JFYEmailDLRDate>= @PM8StartDate        
 ) b  on A.emailaddress=b.EmailAddress        
where A.comboid in ('16sL0','26s30')         
and A.Adcode in (select distinct Adcode from  datawarehouse.Mapping.Email_Adcode        
    where EmailID = @EmailID and DLRFlag = 0 and SegmentGroup in ('Active Control','Swamp Control', 'Inquirers'))        
        
        
print 'PM 8 results'        
exec staging.GetAdcodeInfo_test  'staging.EPC_EmailPull', datawarehouse        
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
        
select '@pm5', @pm5        
        
        
print 'PM 5 Update 1'        
   if  @pm5 is not null    
begin    
update a        
set a.adcode = @pm5        
--select COUNT(distinct a.customerid)        
from staging.EPC_EmailPull a        
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
from Staging.EPC_EmailPull a        
join        
 (select * from rfm.dbo.WPTest_Random2013         
 where HVLVGroup in ('MV')         
 and JFYEmailDLRDate>= @PM5StartDate        
 ) b  on A.emailaddress=b.EmailAddress        
where A.comboid in ('16sL0','26s30')         
and A.Adcode in (select distinct Adcode from   datawarehouse.mapping.Email_adcode        
    where EmailID = @EmailID and DLRFlag = 0 and SegmentGroup in ('Active Control','Swamp Control', 'Inquirers'))        
        
print 'PM 5 results'        
exec staging.GetAdcodeInfo_test  'staging.EPC_EmailPull', datawarehouse        
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
from staging.EPC_EmailPull a        
where a.customersegmentnew in ('DeepInactive')        
and a.adcode  in (select distinct Adcode from  datawarehouse.Mapping.Email_Adcode        
    where --EmailID = @EmailID and         
    SegmentGroup in ('Active Control'))        
        
        
        
        
update a        
set a.adcode=@DeepSwamp        
--select count(*)        
from staging.EPC_EmailPull a        
where a.customersegmentnew in ('NewToFile_PM5','NewToFile_PM8')        
-- and a.adcode=105004        
and a.adcode  in (select distinct Adcode from  datawarehouse.Mapping.Email_Adcode        
    where SegmentGroup in ('Active Control'))        
        
  */          
          
        
declare @Swamp int = 0       
select @Swamp = isnull(Adcode,0) from   datawarehouse.Mapping.Email_Adcode        
where EmailID = @EmailID and DLRFlag = 0 and segmentGroup = 'Swamp control' and countrycode= 'US'        
select '@Swamp', @Swamp        
    
If @Swamp is not null    
begin        
update a        
set a.adcode=@Swamp        
--select count(*)        
from staging.EPC_EmailPull a        
where a.customersegmentnew in ('NewToFile_PM5','NewToFile_PM8')        
and a.adcode  in (select distinct Adcode from  datawarehouse.Mapping.Email_Adcode        
    where EmailID = @EmailID and DLRFlag = 0 and SegmentGroup in ('Active Control') and countrycode= 'US')        
 end       
--CA NewToFile_PM5        
select @Swamp = isnull(Adcode,0) from   datawarehouse.Mapping.Email_Adcode        
where EmailID = @EmailID and DLRFlag = 0 and segmentGroup = 'Swamp control' and countrycode= 'CA'        
select '@Swamp', @Swamp        
    
If @Swamp is not null    
begin         
update a        
set a.adcode=@Swamp        
--select count(*)        
from staging.EPC_EmailPull a        
where a.customersegmentnew in ('NewToFile_PM5','NewToFile_PM8')        
and a.adcode  in (select distinct Adcode from  datawarehouse.Mapping.Email_Adcode        
    where EmailID = @EmailID and DLRFlag = 0 and SegmentGroup in ('Active Control') and countrycode= 'CA')        
end        
        
        
END         
        
        
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
exec staging.GetAdcodeInfo_test  'staging.EPC_EmailPull', datawarehouse        
        
Select customerid,adcode ,ComboID        
into #DLR         
from DataWarehouse.Archive.MailhistoryCurrentYear (nolock)        
where AdCode in         
(select distinct DLRAdCode from datawarehouse.mapping.Email_adcode (nolock) where DLRFlag = 1 and  EmailID = @EmailID and EmailCompletedFlag = 0 and DLRAdcode > 0 )        
        
        
        
update Email        
Set Email.Adcode = EA.Adcode,        
email.comboid = DLR.ComboID        
--select count(*)--Ea.Adcode,DLR.Adcode, Email.*         
from staging.EPC_EmailPull Email        
left join #DLR  DLR        
on Email.customerid=DLR.customerid        
left join datawarehouse.mapping.Email_adcode EA        
on EA.DLRAdcode=DLR.Adcode        
where EA.EmailID = @EmailID and DLRAdcode > 0    
        
        
print 'After DLR'        
exec staging.GetAdcodeInfo_test  'staging.EPC_EmailPull', datawarehouse        
        
        
drop table #DLR        
        
END        
--------------------------------------------------------------------------------------------------------------------------------------------        
--------------------------------------------------------------------------------------------------------------------------------------------        
-------------------------------------------------------DLR Updates Completed----------------------------------------------------------------        
--------------------------------------------------------------------------------------------------------------------------------------------        
--------------------------------------------------------------------------------------------------------------------------------------------        
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
        
exec staging.GetAdcodeInfo_test  'staging.EPC_EmailPull', datawarehouse        
        
        
  
alter table staging.EPC_EmailPull add EmailCnt int  
  
update a  
set a.EmailCnt = b.EmailCnt  
from staging.EPC_EmailPull a  
left join   
(select Customerid,COUNT(*) as EmailCnt  
from staging.EPC_EmailPull  
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
   ( select coalesce(comboid,'yyy') as comboid,coalesce(preferredcategory,'xxx') as preferredcategory ,EmailCnt,COUNT(*) Cnt  
            From  
            (  
               select Customerid,coalesce(comboid,'yyy') as comboid,coalesce(preferredcategory,'xxx') as preferredcategory,COUNT(*) as EmailCnt        
               From staging.EPC_EmailPull        
               Where adcode in ( 119366,119622)         
               group by Customerid,coalesce(comboid,'yyy'),coalesce(preferredcategory,'xxx')        
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
      exec ('update staging.EPC_EmailPull         
          set adcode = '+ @adcode +        
        ' where adcode = '+ @PrimaryAdcode +' and customerID in (select top ' + @Cnt + '  customerID   from staging.EPC_EmailPull where adcode = '+ @PrimaryAdcode +   
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
alter table staging.EPC_EmailPull drop column EmailCnt        
        
        
        
print 'After Splitter'        
exec staging.GetAdcodeInfo_test  'staging.EPC_EmailPull', datawarehouse        
        
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
from datawarehouse.staging.EPC_EmailPull EP        
inner join DataWarehouse.Marketing.Vw_EPC_EmailPull ccs (nolock)        
on EP.customerid = ccs.CustomerID        
where ccs.CustomerSince>= DATEADD(DAY, -3, DATEADD(WEEK, DATEDIFF(WEEK, 0, getdate()), 0))        
        
End        
        
        
else        
        
Begin        
        
Print 'Except the Sunday and Monday go back 1 day'        
        
delete EP        
from datawarehouse.staging.EPC_EmailPull EP        
inner join DataWarehouse.Marketing.Vw_EPC_EmailPull ccs (nolock)        
on EP.customerid = ccs.CustomerID        
where ccs.CustomerSince> = cast( (getdate()-1) as date)        
        
End        
        
        
--Delete Customers who have emails which are in US        
if @CountryCode  in ('AU')        
begin        
Delete AU        
from datawarehouse.staging.EPC_EmailPull  AU        
left join DataWarehouse.Marketing.Vw_EPC_EmailPull ccs (nolock)        
on au.emailaddress=ccs.EmailAddress        
where ccs.CountryCode<>'AU'        
        
END        
        
if @CountryCode  in ('GB')        
Begin        
        
delete GB         
from datawarehouse.staging.EPC_EmailPull GB        
left join DataWarehouse.Marketing.Vw_EPC_EmailPull ccs (nolock)        
on gb.emailaddress=ccs.EmailAddress        
where ccs.CountryCode<>'GB'        
        
End        
        
        
        
--update issues with preferedcat spaces        
Update staging.EPC_EmailPull        
Set preferredcategory =replace(preferredcategory,' ','')        
where PreferredCategory like '% %'        
  
  
alter table staging.EPC_EmailPull add [Priority] [varchar](250) NULL             
        
--Update subjectline/adcode information.        
update a        
set a.CatalogName = case when map.SegmentGroup = ('Active Control') and map.CountryCode in('US','GB','AU') then 'Active_Control'        
       when map.SegmentGroup = ('Active Test') and map.Countrycode = 'US'    then 'Active_Test'        
       when map.SegmentGroup = ('Active Control') and map.CountryCode = 'CA'    then 'Active_Canada'        
       when map.SegmentGroup = ('International') and map.CountryCode= 'ROW'    then 'Active_International'        
       when map.SegmentGroup = ('Swamp Control') and map.Countrycode = 'US'    then 'Swamp_Control'        
       when map.SegmentGroup = ('Swamp Control') and map.CountryCode = 'CA'    then 'Swamp_Canada'        
       when map.SegmentGroup = ('Deep Swamp')            then 'Deep_Swamp'               
       when map.SegmentGroup = ('PM5')             then 'Swamp_CEPM5'         
       when map.SegmentGroup = ('PM8')             then 'Swamp_CEPM8'            
       when map.SegmentGroup = ('Inquirers')            then 'Swamp_Control'         
       else 'Active_Control' end  ,                  
a.BatchID = isnull(sz.TimeGroup, 6),        
a.ECampaignID = 'Email'+ cast(a.Adcode as varchar(10))+'_' + convert(varchar(8), map.startdate, 112),         
a.Subjectline = map.Subjectline,  
a.Priority = map.Priority        
from staging.EPC_EmailPull a        
left join mapping.Email_adcode map        
on a.Adcode=map.Adcode        
left join Mapping.StateZone sz (nolock)         
on sz.[State] = a.[State]        
where map.EmailID = @EmailID        
  
  
/* Delete adcodes that are not in mapping and moved to default 0*/  
Delete from staging.EPC_EmailPull  
where Adcode = 0  
        
--Update userid information.        
update a        
set a.userid = cast( a.CustomerID + '_' + CONVERT(varchar, a.Adcode) + '_'+ EmailAddress as nvarchar(51) ) --a.CustomerID + '_' + CONVERT(varchar, a.Adcode) + '_'+  CatalogName        
from staging.EPC_EmailPull a        
        
alter table staging.EPC_EmailPull alter column [UserID] [nvarchar](51) NOT NULL       
        
alter table staging.EPC_EmailPull drop column countrycode        
        
--Create Email pull table with email name        
set @sql = 'select * into staging.EPC_'+ @EmailID +   ' from staging.EPC_EmailPull'        
exec (@sql)        
        
set @table = @EmailID         
        
--Create Email Table in lstmgr        
        
--Exec [Staging].[CampaignEmail_SplitTable_new] @TableName = @table ,@EmailName = 'NEW'        
        
        
update  mapping.Email_adcode        
set  EmailCompletedFlag = 1         
where EmailID = @EmailID        
        
        
END        
        
if OBJECT_ID('staging.EPC_EmailPull') is not null        
drop table  staging.EPC_EmailPull        
        
End        
        
        
  
  
  
  
  
  
  
  
  
GO
