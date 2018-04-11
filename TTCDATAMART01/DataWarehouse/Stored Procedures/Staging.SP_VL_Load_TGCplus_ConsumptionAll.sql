SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






 
CREATE Proc [Staging].[SP_VL_Load_TGCplus_ConsumptionAll]   @GreaterThanTStamp Date = null      
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
from marketing.TGCplus_VideoEvents_Smry
where tstamp >= @GreaterThanTStamp

         
truncate table staging.TGCPlus_ConsumptionAll_temp

      
insert into staging.TGCPlus_ConsumptionAll_temp    
select CourseID,      
	b.seriestitle as Coursename,      
	episode_number as LectureNumber,      
  b.title as LectureTitle,      
 FilmType,     
  b.genre as SubjectCategory,    
  b.runtime as CourseSeconds,    
  (b.runtime/60.0) as CourseMinutes, 
 a.FlagAudio,
 a.FlagOffline,
 a.Speed,
 a.Player,
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
where  tstamp >= @GreaterThanTStamp  
group by
a.courseid,
b.seriestitle ,   
episode_number ,
  b.title  ,
 FilmType,     
  b.genre  , 
  b.runtime, 
  (b.runtime/60.0),
 a.Player,
	 a.FlagAudio,
	 a.FlagOffline,
	 a.Speed,
	 a.PaidFlag,
  Year(a.tstamp) ,   
  Month(a.tstamp),      
 staging.getmonday(a.tstamp) ,   
  cast(a.tstamp as date)   



      
-- Update Number Of Plays to 1 when 0    
--update a    
--set a.NumOfPlays = 1    
--from staging.TGCPlus_ConsumptionAll_temp a     
--where a.NumOfPlays = 0    
            
Print 'Deleting'            
--delete a  from Marketing.TGCPlus_ConsumptionAll a      
--inner join staging.TGCPlus_ConsumptionAll_temp b      
-- on a.CourseID=b.CourseID     
-- and a.Coursename= b.Coursename    
-- and a.LectureNumber = b.LectureNumber     
-- and a.LectureTitle = b.LectureTitle   
-- and a.FilmType = b.FilmType   
-- and a.YearPlayed =  b.YearPlayed      
-- and a.MonthPlayed = b.MonthPlayed   
-- and a.WeekPlayed = b.WeekPlayed   
-- and a.DatePlayed = b.DatePlayed       


delete from Marketing.TGCPlus_ConsumptionAll
where DatePlayed >= @GreaterThanTStamp
      
Print 'Inserting'        
Insert into Marketing.TGCPlus_ConsumptionAll     
select  *  
from staging.TGCPlus_ConsumptionAll_temp    
    
update Marketing.TGCPlus_ConsumptionAll   
set	MaxConsumptionDate = @MaxConsumptionDate,  
	ReportDate = @ReportDate    

Drop table #TGCPlus_VideoEvents    
END 






GO
