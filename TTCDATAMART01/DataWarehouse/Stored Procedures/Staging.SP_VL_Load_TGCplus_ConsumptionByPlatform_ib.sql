SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE Proc [Staging].[SP_VL_Load_TGCplus_ConsumptionByPlatform_ib]   @GreaterThanTStamp Date = null        
as          
Begin          
        
If @GreaterThanTStamp is null         
Begin        
set @GreaterThanTStamp = DATEADD(d,-1,staging.getmonday(GETDATE()-7) )        
End          
           
Truncate table staging.TGCplus_ConsumptionByPlatform_ib_temp        
  
Declare @MaxConsumptionDate Datetime,@ReportDate Datetime  
  
select @MaxConsumptionDate = isnull(MAX(Tstamp),'1900/01/01'),@ReportDate = isnull(MAX(DMLastUpdateESTDateTime),'1900/01/01') from Archive.TGCPlus_VideoEvents  
  
select @MaxConsumptionDate,@ReportDate  


select * into #TGCPlus_VideoEvents 
from  marketing.TGCplus_VideoEvents_Smry a
where tstamp >= @GreaterThanTStamp

        
insert into staging.TGCplus_ConsumptionByPlatform_ib_temp        
  select   
  Platform,  
  useragent as BrowserVersion,  
  datawarehouse.Staging.RemoveDigits(a.useragent) as Browser,  
  b.genre as SubjectCategory,      
  c.Country as CountryName,   
	 CountryCode, 
	 a.FilmType, 
	 a.Player,
	 a.FlagAudio,
	 a.FlagOffline,
	 a.Speed,
	 a.PaidFlag, 
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
   getdate()  AS ReportDate  
 
from Marketing.TGCplus_VideoEvents_Smry a
      join Archive.TGCPlus_Film b on a.vid = b.uuid   
left join DataWarehouse.Mapping.TGCPlusCountry c on a.countrycode=c.Alpha2Code
where   tstamp >= @GreaterThanTStamp  
group by
 Platform,  
  useragent ,  
  datawarehouse.Staging.RemoveDigits(a.useragent) ,
  COUNTRYCODE,
   c.Country ,
 FilmType,     
  b.genre , 
   a.Player,
	 a.FlagAudio,
	 a.FlagOffline,
	 a.Speed,
	 a.PaidFlag,
  Year(a.tstamp) ,   
  Month(a.tstamp),      
 cast(staging.getmonday(a.tstamp) as date),   
  cast(a.tstamp as date) 


        
  
--Print 'Deleting'              
delete Marketing.TGCplus_ConsumptionByPlatform_ib         
where DatePlayed >= @GreaterThanTStamp     
        
Print 'Inserting'          
Insert into Marketing.TGCplus_ConsumptionByPlatform_ib        
select  *      
from staging.TGCplus_ConsumptionByPlatform_ib_temp      
      
      
update Marketing.TGCplus_ConsumptionByPlatform_ib  
set MaxConsumptionDate = @MaxConsumptionDate,    
 ReportDate = @ReportDate      

drop table #TGCPlus_VideoEvents          

END   




GO
