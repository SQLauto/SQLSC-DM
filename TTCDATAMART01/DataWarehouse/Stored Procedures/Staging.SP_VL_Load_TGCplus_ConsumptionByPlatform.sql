SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [Staging].[SP_VL_Load_TGCplus_ConsumptionByPlatform]   @GreaterThanTStamp Date = null        
as          
Begin          
        
If @GreaterThanTStamp is null         
Begin        
set @GreaterThanTStamp = DATEADD(d,-1,staging.getmonday(GETDATE()-7) )        
End          
           
Truncate table staging.TGCPlus_ConsumptionByPlatform_temp        
  
Declare @MaxConsumptionDate Datetime,@ReportDate Datetime  
  
select @MaxConsumptionDate = isnull(MAX(Tstamp),'1900/01/01'),@ReportDate = isnull(MAX(DMLastUpdateESTDateTime),'1900/01/01') from Archive.TGCPlus_VideoEvents  
  
select @MaxConsumptionDate,@ReportDate  


select * into #TGCPlus_VideoEvents 
from Archive.TGCPlus_VideoEvents a
where tstamp >= @GreaterThanTStamp

        
insert into staging.TGCPlus_ConsumptionByPlatform_temp        
select   
  a.pfm as Platform,  
  a.useragent as BrowserVersion,  
  datawarehouse.Staging.RemoveDigits(a.useragent) as Browser,  
  b.genre as SubjectCategory,      
  a.countryname as CountryName,   
  a.countryisocode as CountryCode,   
  Year(a.tstamp) as YearPlayed,        
  Month(a.tstamp) as MonthPlayed,        
  cast(staging.getmonday(a.tstamp) as date) as WeekPlayed,        
  cast(a.tstamp as date) as DatePlayed,        
  sum(case when pa = 'PLAY' then 1 else 0 end) as NumOfPlays,        
  convert(float,(sum(case when pa = 'PING' then 1 else 0 end)  * 30.0)) as StreamedSeconds,      
  convert(float,(sum(case when pa = 'PING' then 1 else 0 end)  * 30.0)/60) as StreamedMinutes,      
  count(distinct a.uid) UniqueCustcount ,      
  convert(float,(sum(case when pa = 'PLAY' then b.runtime else 0 end))) as AvlblSeconds,        
  convert(float,(sum(case when pa = 'PLAY' then b.runtime else 0 end))/60) as AvlblMinutes,    
  @MaxConsumptionDate AS MaxConsumptionDate,    
  @ReportDate AS ReportDate,  
   case when b.film_type IS null and b.course_id > 0 then 'Episode'         
   when b.film_type IS null and isnull(b.course_id,'0') = 0 then 'Trailer'        
   else b.film_type        
  end as FilmType   
from #TGCPlus_VideoEvents a         
      join Archive.TGCPlus_Film b on a.vid = b.uuid        
      join Archive.TGCPlus_User c on a.uid = c.uuid   
where tstamp >= @GreaterThanTStamp  
and c.email not like '%+%'
and c.email not like '%plustest%'       
group by   
      a.pfm,  
      a.useragent,  
 datawarehouse.Staging.RemoveDigits(a.useragent),  
      b.genre,      
      a.countryname,   
   a.countryisocode,    
      Year(a.tstamp),        
      Month(a.tstamp),        
	  cast(staging.getmonday(a.tstamp) as date),        
      cast(a.tstamp as date),  
       case when b.film_type IS null and b.course_id > 0 then 'Episode'         
    when b.film_type IS null and isnull(b.course_id,'0') = 0 then 'Trailer'        
    else b.film_type        
   end     
        
  
--Print 'Deleting'              
delete Marketing.TGCPlus_ConsumptionByPlatform         
where DatePlayed >= @GreaterThanTStamp     
        
Print 'Inserting'          
Insert into Marketing.TGCPlus_ConsumptionByPlatform        
select  *      
from staging.TGCPlus_ConsumptionByPlatform_temp      
      
      
update Marketing.TGCPlus_ConsumptionByPlatform  
set MaxConsumptionDate = @MaxConsumptionDate,    
 ReportDate = @ReportDate      

drop table #TGCPlus_VideoEvents          

END   
GO
