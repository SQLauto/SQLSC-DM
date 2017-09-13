SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE proc [dbo].[Sp_EPC_EmailPull_DailyDeals_20170907]        
as        
Begin        
        
Declare @EmailID varchar(50),@sql varchar(500),@CountryCode varchar(20),@table varchar(100)        


--Using MaxCourses as Course id for daily deals
   
while exists (select top 1 EmailID from mapping.Email_adcode where EmailCompletedFlag = 0 and MaxCourses <> 0  order by EmailID)        
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
,map.Priority  
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
,map.Priority     
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
,Map.MaxCourses as Courseid  
,map.Priority  
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
,map.Priority               
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
,map.Priority                   
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
,map.Priority                   
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
,map.Priority               
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
--------------------------------update customers for Deep Swamp based on customersegmentnew in ('DeepInactive')-----------------------------        
--------------------------------------------------------------------------------------------------------------------------------------------        
--------------------------------------------------------------------------------------------------------------------------------------------        
if @CountryCode in ('US','CA')        
begin          
        
declare @Swamp int = 0       
select @Swamp = isnull(Adcode,0) from   datawarehouse.Mapping.Email_Adcode        
where EmailID = @EmailID and DLRFlag = 0 and segmentGroup = 'Swamp control' and countrycode= 'US'        
select '@Swamp', @Swamp        
    
If @Swamp is not null    
begin        
update a        
set a.adcode=@Swamp
,Catalogname = 'Swamp control'        
--select count(*)        
from staging.EPC_EmailPull_DailyDeals a        
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
,Catalogname = 'Swamp control'       
--select count(*)        
from staging.EPC_EmailPull_DailyDeals a        
where a.customersegmentnew in ('NewToFile_PM5','NewToFile_PM8')        
and a.adcode  in (select distinct Adcode from  datawarehouse.Mapping.Email_Adcode        
    where EmailID = @EmailID and DLRFlag = 0 and SegmentGroup in ('Active Control') and countrycode= 'CA')        
end        
        
        
END         



  
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
  
--#EmailsNotMatched  
select E.*   
into #EmailsNotMatched  
from DataWarehouse.staging.EPC_EmailPull_DailyDeals E  
left join #Matched M  
on m.emailaddress=e.emailaddress  
where m.emailaddress is null  
  
  
--#SNI  
select E.CustomerID,E.EmailAddress  
into #SNI   
from DataWarehouse.staging.EPC_EmailPull_DailyDeals E  
inner join #EmailsNotMatched E1  
on E.CustomerID = E1.CustomerId and E.EmailAddress = E1.Emailaddress  
where E.CatalogName <> 'Active Control'  
  
--Valid Emails  
--#MatchCustomeriD  
select a.CustomerID,A.EmailAddress     
into #MatchCustomeriD  
from DataWarehouse.staging.EPC_EmailPull_DailyDeals a  
join  DataWarehouse.Marketing.CampaignCustomerSignature b  
on a.customerid = b.customerid and a.emailaddress <> b.EmailAddress  
where CatalogName = 'Active Control'  
and b.EmailAddress <> ''  
  
--Blank Emails  
--#Nomatch  
select a.CustomerID,A.EmailAddress    
into #Nomatch  
from DataWarehouse.staging.EPC_EmailPull_DailyDeals a  
join  DataWarehouse.Marketing.CampaignCustomerSignature b  
on a.customerid = b.customerid and a.emailaddress <> b.EmailAddress  
where CatalogName = 'Active Control'  
and b.EmailAddress = ''  
  
  
  
--#SNI  
  
print 'Deleting extra swamp emails based on newseg changes'  
  
delete e  
from staging.EPC_EmailPull_DailyDeals e  
inner join #SNI s  
on s.EmailAddress=e.EmailAddress and s.CustomerID=e.CustomerID  
--inner join Marketing.Vw_EPC_EmailPull V  
--on v.Emailaddress = e.Emailaddress  
where e.NewSeg not in (11,12,13,14,15,20,18,19,23,24,25,28)  
  
  
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
  
  
Update e Set e.Adcode = @SwampMatchCustomeriDAdcode,E.CatalogName = 'Swamp match'
from staging.EPC_EmailPull_DailyDeals e  
inner join #SNI s  
on s.EmailAddress=e.EmailAddress and s.CustomerID=e.CustomerID  
  
  
--#MatchCustomeriD  
print 'deleting #MatchCustomeriD emails where CountryCode<>US'  
delete e  
from staging.EPC_EmailPull_DailyDeals e  
inner join #MatchCustomeriD s  
on s.EmailAddress=e.EmailAddress and s.CustomerID=e.CustomerID  
where e.CountryCode<>'US'  
  
  
Declare @MatchCustomeriDAdcode int = 0   
select @MatchCustomeriDAdcode = isnull(Adcode,0) from   datawarehouse.Mapping.Email_adcode        
where EmailID = @EmailID and DLRFlag = 0 and segmentGroup = 'EPC Active' and countrycode= 'US'     
select '@MatchCustomeriDAdcode', @MatchCustomeriDAdcode      
  
Update e Set e.Adcode = @MatchCustomeriDAdcode,E.CatalogName = 'EPC Active' 
from staging.EPC_EmailPull_DailyDeals e  
inner join #MatchCustomeriD s  
on s.EmailAddress=e.EmailAddress and s.CustomerID=e.CustomerID  
  
--#Nomatch  
  
print 'deleting #Nomatch emails where CountryCode<>US'  
delete e  
from staging.EPC_EmailPull_DailyDeals e  
inner join #Nomatch s  
on s.EmailAddress=e.EmailAddress and s.CustomerID=e.CustomerID  
where e.CountryCode<>'US'  

/*Merging EPC Match and EPC No Match*/
/*    
Declare @NomatchAdcode int = 0   
select @NomatchAdcode = isnull(Adcode,0) from   datawarehouse.Mapping.Email_adcode        
where EmailID = @EmailID and DLRFlag = 0 and segmentGroup = 'EPCExtra' and countrycode= 'US'     
select '@NomatchAdcode', @NomatchAdcode      
*/

/*Merging EPC Match and EPC No Match*/
--Update e Set e.Adcode =  @NomatchAdcode,E.CatalogName = 'Active Nomatch'    
Update e Set e.Adcode = @MatchCustomeriDAdcode,E.CatalogName = 'EPC Active' 
from staging.EPC_EmailPull_DailyDeals e  
inner join #Nomatch s  
on s.EmailAddress=e.EmailAddress and s.CustomerID=e.CustomerID  
  
   
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
 select *
 into #prospect
 from DataWarehouse.Marketing.Vw_EPC_Prospect_EmailPull 
 where store_country not in ('au_en','uk_en')
 and website_country not in ('UK','AU','Australia')
 order by magento_created_date desc
 
 
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
	Map.Priority as Priority, 
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
--------------------------------------------------------------------------------------------------------------------------------------------     
--------------------------------------------------------------------------------------------------------------------------------------------                        
---------------------------------------------------------RAM Process Start------------------------------------------------------------------      
-------------------------------------------------------------------------------------------------------------------------------------------- 
--------------------------------------------------------------------------------------------------------------------------------------------                
/*      
Declare @RAMControlAdcode int = 0   ,@Senddate  datetime   /* Send date is used for the RAM adcode date */      
select @RAMControlAdcode = isnull(Adcode,0),@Senddate = Startdate from   datawarehouse.Mapping.Email_adcode                        
where EmailID = @EmailID and DLRFlag = 0 and segmentGroup = 'RAM' and countrycode= 'US'  --Ram roll out on 7/26/2016 VB                       
      
      
Declare @RAMTestAdcode int = 0                   
select @RAMTestAdcode = isnull(Adcode,0) from   datawarehouse.Mapping.Email_adcode                        
where EmailID = @EmailID and DLRFlag = 0 and segmentGroup = 'RAM' and countrycode= 'US'     

if @RAMTestAdcode = 0 
set @RAMTestAdcode = @RAMControlAdcode
                  
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
    
      
/*Remove Expired RAM Customers*/      
--VB Removing Ram archiving process 1/4/2017
/* 
Update RAM      
set Ram.FlagRemoved=1,       
 DateRemoved = getdate(),      
 RAM.AdcodeRemoved= Case when RAM.custgroup = 'Control' then @RAMControlAdcode      
     when RAM.custgroup = 'TEST' Then @RAMTestAdcode      
    end      
from datawarehouse.staging.EPC_EmailPull_DailyDeals E      
inner join DataWarehouse.Archive.RAM_CustomerCohort RAM      
on E.CustomerID = RAM.CustomerID      
inner join DataWarehouse.Mapping.RAM_CustomerCohort MRAM      
on E.CustomerID = MRAM.CustomerID      
where MRAM.CustomerSegmentFnlPrior in ('Active_Multi') /* Expired RAM Customer based on Current status*/      
and MRAM.newseg in (3,4,5,8,9,10)       
and FlagRemoved=0 /* And not yet expired */      
*/      
      
/* update Email table with RAMControl and RAMTest Adcodes*/      
      
update E      
set E.Adcode = Case when RAM.custgroup = 'Control' then @RAMControlAdcode      
     when RAM.custgroup = 'TEST' Then @RAMTestAdcode      
    end,      
 E.Comboidprior = RAM.Comboidprior ,
 E.CatalogName = 'RAM'     
from datawarehouse.staging.EPC_EmailPull_DailyDeals E       
inner join (      
select customerid,custgroup,Comboidprior from DataWarehouse.Mapping.RAM_CustomerCohort      
--VB Removing Ram archiving process 1/4/2017
/* 
select distinct dm.customerid,dm.custgroup,M.Comboid as Comboidprior from DataWarehouse.Archive.RAM_CustomerCohort  DM    
left join Mapping.RFMComboLookup M      
on DM.NewsegPrior=M.Newseg and DM.NamePrior=M.Name and isnull(DM.A12mfPrior,0)=M.A12mf --and DM.ConcatenatedPrior = M.Concatenated    
where FlagRemoved=0      
union      
select MRAM.customerid,MRAM.custgroup,Comboidprior from DataWarehouse.Mapping.RAM_CustomerCohort MRAM      
left join DataWarehouse.Archive.RAM_CustomerCohort RAM      
on Ram.customerid = MRAM.customerid      
where MRAM.CustomerSegmentFnlPrior <>'Active_Multi'      
and RAM.customerid is null      
*/
)RAM      
on Ram.customerid = E.CustomerID      
      
      
/* update Email table with RAMControl and RAMTest Adcodes*/      
      
--VB Removing Ram archiving process 1/4/2017
/*       
 insert into DataWarehouse.Archive.RAM_CustomerCohort      
      
 select distinct E.CustomerID, getdate() as InsertDate, MRAM.CustGroup, MRAM.NewSeg, MRAM.Name, MRAM.a12mf, MRAM.Frequency, MRAM.ComboID,MRAM.Recency,       
 MRAM.CustomerSegmentFnl, MRAM.CustomerSegmentFnlPrior, MRAM.NewsegPrior, MRAM.NamePrior, MRAM.A12mfPrior, MRAM.FrequencyPrior,      
 Case when MRAM.custgroup = 'Control' then 'Active' when MRAM.custgroup = 'TEST' Then 'Inactive' end Pricing,       
 E.Adcode IntlAdcode, @Senddate as IntlStartDate,0 as FlagRemoved,'Email' IntlContact,null as DateRemoved,null as AdcodeRemoved       
 from datawarehouse.staging.EPC_EmailPull_DailyDeals E      
 inner join DataWarehouse.Mapping.RAM_CustomerCohort MRAM      
 on E.CustomerID = MRAM.CustomerID      
 left join DataWarehouse.Archive.RAM_CustomerCohort RAM      
 on RAM.CustomerID = MRAM.CustomerID      
 where RAM.CustomerID  is null       
 and MRAM.CustomerSegmentFnlPrior <>'Active_Multi'      
*/

       
 END     
 */ 
      
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------                        
---------------------------------------------------------RAM Process End--------------------------------------------------------------------      
--------------------------------------------------------------------------------------------------------------------------------------------                        
--------------------------------------------------------------------------------------------------------------------------------------------            
        
        
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
        
           
        
--update issues with preferedcat spaces        
Update staging.EPC_EmailPull_DailyDeals        
Set preferredcategory =replace(preferredcategory,' ','')        
where PreferredCategory like '% %'        
  
  
--alter table staging.EPC_EmailPull_DailyDeals add [Priority] [varchar](250) NULL             
        
--Update subjectline/adcode information.        
update a        
set a.CatalogName = case when map.SegmentGroup = ('Active Control') and map.CountryCode in('US','GB','AU') then 'Active_Control'        
       when map.SegmentGroup = ('Active Test') and map.Countrycode = 'US'    then 'Active_Test'        
       when map.SegmentGroup = ('Active Control') and map.CountryCode = 'CA'    then 'Active_Canada'    
       when map.SegmentGroup = ('International') and map.CountryCode= 'ROW'    then 'Active_International'        
       when map.SegmentGroup = ('Swamp Control') and map.Countrycode = 'US'    then 'Swamp_Control'        
       when map.SegmentGroup = ('Swamp Control') and map.CountryCode = 'CA'    then 'Active_Canada'        
       when map.SegmentGroup = ('Deep Swamp')            then 'Deep_Swamp'               
       when map.SegmentGroup = ('PM5')             then 'Swamp_CEPM5'         
       when map.SegmentGroup = ('PM8')             then 'Swamp_CEPM8'            
       when map.SegmentGroup = ('Inquirers')            then 'Swamp_Control'         
    --when map.SegmentGroup = ('Active match')   then 'Active_CustomerIDMatch'   
    --when map.SegmentGroup = ('Active Nomatch')  then 'Active_NoMatch'  
    --when map.SegmentGroup = ('Swamp Match')   then 'Swamp_Match'              
    --when map.SegmentGroup = ('EPCExtra')   then 'EPC_Extra'
    --else 'Active_Control' end  ,    
    --when map.SegmentGroup = ('Active match')   then 'Active_CustomerIDMatch'                   
    --when map.SegmentGroup = ('Active Nomatch')  then 'Active_NoMatch'                  
    when map.SegmentGroup = ('EPC Active')   then 'Active_EPC'            
    when map.SegmentGroup = ('EPC Test')   then 'Active_EPC'                   
    when map.SegmentGroup = ('Swamp Match')   then 'Active_EPC'          
    --when map.SegmentGroup = ('RAM Control')   then 'RAM_Control'          
    --when map.SegmentGroup = ('RAM TEST')   then 'RAM_Test'          
    when map.SegmentGroup = ('RAM')   then 'RAM' 
    else 'Active_Control' end  , 	              
a.BatchID = isnull(sz.TimeGroup, 6),        
a.ECampaignID = 'Email'+ cast(a.Adcode as varchar(10))+'_' + convert(varchar(8), map.startdate, 112),         
a.Subjectline = map.Subjectline,  
a.Priority = map.Priority        
from staging.EPC_EmailPull_DailyDeals a        
left join mapping.Email_adcode map        
on a.Adcode=map.Adcode 
and a.CatalogName = map.SegmentGroup       
left join Mapping.StateZone sz (nolock)         
on sz.[State] = a.[State]        
where map.EmailID = @EmailID        

/*  Updating CatalogName = 'Ram_Control' */
--update E
--set CatalogName = 'RAM_Control'
-- from staging.EPC_EmailPull_DailyDeals E
-- join DataWarehouse.Mapping.RAM_CustomerCohort MRAM      
--on E.CustomerID = MRAM.CustomerID    
--where MRAM.CustomerSegmentFnlPrior <>'Active_Multi'  


if @CountryCode in ('US','CA')        
begin 
--/*Daily Deals deletes Emails droppped where pref does not match*/
print 'Daily Deals deletes  where pref does not match'
Delete E from staging.EPC_EmailPull_DailyDeals E
Join DataWarehouse.Mapping.DMCourse C
on E.courseId = C.CourseID
where (E.CatalogName = 'Swamp match' or E.CustomerSegmentNew = 'DeepInactive')
and E.PreferredCategory <> C.SubjectCategory2
end  
   

--/*Daily Deals deletes where Customer has already purchased*/
print 'Daily Deals deletes where Customer has already purchased the Course'
Delete E from staging.EPC_EmailPull_DailyDeals E
Join DataWarehouse.Marketing.CompleteCoursePurchase C
on E.courseId = C.CourseID
and E.CustomerID = C.CustomerID



/* Delete adcodes that are not in mapping and moved to default 0*/  
Delete from staging.EPC_EmailPull_DailyDeals  
where Adcode = 0  
        
--Update userid information.        
update a        
set a.userid = cast( a.CustomerID + '_' + CONVERT(varchar, a.Adcode) + '_'+ EmailAddress as nvarchar(51) ) --a.CustomerID + '_' + CONVERT(varchar, a.Adcode) + '_'+  CatalogName        
from staging.EPC_EmailPull_DailyDeals a        
        
alter table staging.EPC_EmailPull_DailyDeals alter column [UserID] [nvarchar](51) NOT NULL       
        
--alter table staging.EPC_EmailPull_DailyDeals drop column countrycode        
        
--Create Email pull table with email name        
--set @sql = 'select * into staging.EPC_'+ @EmailID +   ' from staging.EPC_EmailPull_DailyDeals'     /*Removed EPC_ on 20151019 for future email pulls*/  
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
        
        
END        
        
if OBJECT_ID('staging.EPC_EmailPull_DailyDeals') is not null        
drop table  staging.EPC_EmailPull_DailyDeals        
        
End        
        
        
  
  
GO
