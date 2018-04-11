SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


 
CREATE Proc [Staging].[SP_VL_Load_TGCplus_ConsumptionAll_bkp_del]   @GreaterThanTStamp Date = null      
as        
Begin        
      
--If @GreaterThanTStamp is null       
--Begin      
--set @GreaterThanTStamp = DATEADD(d,-1,staging.getmonday(GETDATE()-7) )      
--End        
--declare @GreaterThanTStamp Date = null  
select @GreaterThanTStamp = coalesce(staging.getsunday(@GreaterThanTStamp),DATEADD(d,-7,staging.getmonday(GETDATE())))


Declare @MaxConsumptionDate Datetime,@ReportDate Datetime

select @MaxConsumptionDate = isnull(MAX(Tstamp),'1900/01/01'),@ReportDate = isnull(MAX(DMLastUpdateESTDateTime),'1900/01/01') from Archive.TGCPlus_VideoEvents

select @MaxConsumptionDate,@ReportDate,@GreaterThanTStamp

--update DataWarehouse.Archive.TGCPlus_Film
--set genre = 'Science'
--where course_id in (1846,9631)


select * into #TGCPlus_VideoEvents 
from Archive.TGCPlus_VideoEvents a
where tstamp >= @GreaterThanTStamp

         
Truncate table staging.TGCPlus_ConsumptionAll_temp_bkp_del      
      
insert into staging.TGCPlus_ConsumptionAll_temp_bkp_del      
select convert(int,b.course_id) as CourseID,      
  b.seriestitle as Coursename,      
  convert(int,b.episode_number) as LectureNumber,      
  b.title as LectureTitle,      
  case when b.film_type IS null and b.course_id > 0 then 'Episode'       
  when b.film_type IS null and isnull(b.course_id,'0') = 0 then 'Trailer'      
  else b.film_type      
  end as FilmType,     
  b.genre as SubjectCategory,    
  b.runtime as CourseSeconds,    
  (b.runtime/60.0) as CourseMinutes,    
  Year(a.tstamp) as YearPlayed,      
  Month(a.tstamp) as MonthPlayed,      
  cast(staging.getmonday(a.tstamp) as Date) as WeekPlayed,      
  cast(a.tstamp as date) as DatePlayed,      
  sum(case when pa = 'PLAY' then 1 else 0 end) as NumOfPlays,      
  convert(float,(sum(case when pa = 'PING' then 1 else 0 end)  * 30.0)) as StreamedSeconds,    
  convert(float,(sum(case when pa = 'PING' then 1 else 0 end)  * 30.0)/60) as StreamedMinutes,    
  count(distinct a.uid) UniqueCustcount ,    
  convert(float,(sum(case when pa = 'PLAY' then b.runtime else 0 end))) as AvlblSeconds,      
  convert(float,(sum(case when pa = 'PLAY' then b.runtime else 0 end))/60) as AvlblMinutes,  
  @MaxConsumptionDate AS MaxConsumptionDate,  
  @ReportDate AS ReportDate    
from #TGCPlus_VideoEvents a       
      join Archive.TGCPlus_Film b on a.vid = b.uuid   
      join Archive.TGCPlus_User c on a.uid = c.uuid   
where tstamp >= @GreaterThanTStamp 
and c.email not like '%+%'
and c.email not like '%plustest%' 
group by convert(int,b.course_id),      
      b.seriestitle,      
      convert(int,b.episode_number),      
      b.title,      
      case when b.film_type IS null and b.course_id > 0 then 'Episode'       
            when b.film_type IS null and isnull(b.course_id,'0') = 0 then 'Trailer'      
            else b.film_type      
      end ,    
      b.genre,    
      b.runtime,    
      (b.runtime/60.0),    
      Year(a.tstamp),      
      Month(a.tstamp),      
      staging.getmonday(a.tstamp),      
      cast(a.tstamp as date)        
      
-- Update Number Of Plays to 1 when 0    
--update a    
--set a.NumOfPlays = 1    
--from staging.TGCPlus_ConsumptionAll_temp_bkp_del a     
--where a.NumOfPlays = 0    
            
Print 'Deleting'            
--delete a  from Marketing.TGCPlus_ConsumptionAll_bkp_del a      
--inner join staging.TGCPlus_ConsumptionAll_temp_bkp_del b      
-- on a.CourseID=b.CourseID     
-- and a.Coursename= b.Coursename    
-- and a.LectureNumber = b.LectureNumber     
-- and a.LectureTitle = b.LectureTitle   
-- and a.FilmType = b.FilmType   
-- and a.YearPlayed =  b.YearPlayed      
-- and a.MonthPlayed = b.MonthPlayed   
-- and a.WeekPlayed = b.WeekPlayed   
-- and a.DatePlayed = b.DatePlayed       
delete from Marketing.TGCPlus_ConsumptionAll_bkp_del 
where DatePlayed >= @GreaterThanTStamp
      
Print 'Inserting'        
Insert into Marketing.TGCPlus_ConsumptionAll_bkp_del      
select  *    
from staging.TGCPlus_ConsumptionAll_temp_bkp_del    
    
update Marketing.TGCPlus_ConsumptionAll_bkp_del
set	MaxConsumptionDate = @MaxConsumptionDate,  
	ReportDate = @ReportDate    

Drop table #TGCPlus_VideoEvents    
END 


GO
