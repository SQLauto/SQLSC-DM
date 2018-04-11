SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE view  [Staging].[TGCplus_ConsumptionByPlatform]  
as 
select   
  Platform,  
  useragent as BrowserVersion,  
  datawarehouse.Staging.RemoveDigits(a.useragent) as Browser,  
  b.genre as SubjectCategory,      
  c.Country as CountryName,   
	 CountryCode,   
  Year(a.tstamp) as YearPlayed,        
  Month(a.tstamp) as MonthPlayed,        
  cast(staging.getmonday(a.tstamp) as date) as WeekPlayed,        
  cast(a.tstamp as date) as DatePlayed,        
	sum(plays)  as NumOfPlays,        
  convert(float,(sum(a.pings)  * 30.0)) as StreamedSeconds,      
  convert(float,(sum(a.pings) * 30.0)/60) as StreamedMinutes,      
  count(distinct a.UUID) UniqueCustcount ,      
  convert(float,(sum(case when plays > 0 then a.lectureRunTime else 0 end))) as AvlblSeconds,        
  convert(float,(sum(case when  plays > 0 then a.lectureRunTime else 0 end))/60) as AvlblMinutes,   
 isnull(MAX(Tstamp),'1900/01/01') as MaxConsumptionDate,
   getdate()  AS ReportDate,  
   FilmType
from Marketing.TGCplus_VideoEvents_Smry a
      join Archive.TGCPlus_Film b on a.vid = b.uuid   
left join DataWarehouse.Mapping.TGCPlusCountry c on a.countrycode=c.Alpha2Code
where year(tstamp) = 2018
group by
 Platform,  
  useragent ,  
  datawarehouse.Staging.RemoveDigits(a.useragent) ,
  COUNTRYCODE,
   c.Country ,
 FilmType,     
  b.genre , 
  Year(a.tstamp) ,   
  Month(a.tstamp),      
 cast(staging.getmonday(a.tstamp) as date),   
  cast(a.tstamp as date) 

 














GO
