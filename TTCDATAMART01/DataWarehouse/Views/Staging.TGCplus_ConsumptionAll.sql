SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 

CREATE view  [Staging].[TGCplus_ConsumptionAll]

as 
select CourseID,      
	b.seriestitle as Coursename,      
	episode_number as LectureNumber,      
  b.title as LectureTitle,      
 FilmType,     
  b.genre as SubjectCategory,    
  b.runtime as CourseSeconds,    
  (b.runtime/60.0) as CourseMinutes,    
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
-- where  tstamp >= DATEADD(d,-7,staging.getmonday(GETDATE()))
group by
a.courseid,
b.seriestitle ,   
episode_number ,
  b.title  ,
 FilmType,     
  b.genre  , 
  b.runtime, 
  (b.runtime/60.0),
  Year(a.tstamp) ,   
  Month(a.tstamp),      
 staging.getmonday(a.tstamp) ,   
  cast(a.tstamp as date)   
  
 


















 /*

 courseid ,    
      b.seriestitle,      
     episode_number,      
      b.title,      
      filmtype,
      b.genre,    
      b.runtime,    
      (b.runtime/60.0),    
      Year(a.tstamp),      
      Month(a.tstamp),      
      staging.getmonday(a.tstamp),      
      cast(a.tstamp as date)       
GO

*/
GO
