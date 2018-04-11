SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



 
  
CREATE PROC [Staging].[SP_Load_Omni_TGC_LTDLectureConsmption]  
AS  
  
BEGIN  
  
  
 /***************** Create working table *************************/  

 If object_id ('staging.Omni_TGC_LTDLectureConsumption') is not null  
 drop table staging.Omni_TGC_LTDLectureConsumption  

   select Customerid, CourseID,LectureNumber,max(Lecture_duration/60.)Lecture_durationMins 
  ,Max(Case when (Watched95pct>0 or MediaCompletes >0) then 1 else 0 end) MediaCompleteFlag
  ,Case when max(MediaCompletes) >0 then max(Lecture_duration/60.) *1.
		when max(Watched95pct) >0 then max(Lecture_duration/60.)*.95
		when max(Watched75pct) >0 then max(Lecture_duration/60.)*.75
		when max(Watched50pct) >0 then max(Lecture_duration/60.)*.50
		when max(Watched25pct) >0 then max(Lecture_duration/60.)*.25
		end MaxVPosMins
  ,case when sum(MediaTimePlayed) > max(Lecture_duration/60.) then max(Lecture_duration/60.) else sum(MediaTimePlayed) end as StreamedMinsCapped  
  ,case when sum(MediaTimePlayed) > max(Lecture_duration/60.) then max(Lecture_duration/60.) else sum(MediaTimePlayed) end as FINALStreamedMins  
  ,sum(MediaTimePlayed) TotalStreamedMins
  ,MAX(Actiondate) as LastLectureActivity  
  ,Min(Actiondate) as FirstLectureActivity  
  ,convert(int,0) as FlagCompletedLecture  
  ,convert(float,0) as LectureCompletedPrcnt
  Into staging.Omni_TGC_LTDLectureConsumption
  from DataWarehouse.Archive.Omni_TGC_Streaming
  where Customerid is not null and CourseID is not null
  and CourseID < 1000000  
  group by Customerid, CourseID,LectureNumber

--Updates based on completetion 
 update staging.Omni_TGC_LTDLectureConsumption
 set FINALStreamedMins = MaxVPosMins  
 where StreamedMinsCapped - MaxVPosMins > 1  
  

 -- if they watched more than 90% of the course, then flag as completed.  
 update staging.Omni_TGC_LTDLectureConsumption  
 set FlagCompletedLecture = case when isnull(FINALStreamedMins,0)*1./nullif(Lecture_durationMins,0) >= .90  then 1 else 0 end,  
  LectureCompletedPrcnt  = isnull(isnull(FINALStreamedMins,0)*1./nullif(Lecture_durationMins,0),0)  


  If object_id ('Marketing.Omni_TGC_LTDLectureConsumption') is not null   
 drop table Marketing.Omni_TGC_LTDLectureConsumption  
  
 select *,getdate() as DMLastUpdated  
 into Marketing.Omni_TGC_LTDLectureConsumption  
 from  staging.Omni_TGC_LTDLectureConsumption  

  
 -- Aggregate at course level  
 If object_id ('staging.Omni_TGC_LTDCourseConsumption') is not null  
 drop table staging.Omni_TGC_LTDCourseConsumption  
   
     
    
 select Course_id,lecture_number, max(duration)duration
 Into #DMCourse
 from (
 select distinct Course_id,lecture_number,audio_brightcove_id as brightcove_id, audio_duration as duration, 'Audio' as Format   
      from   imports.magento.lectures L    
      left join Imports.magento.catalog_product_entity E     
      on L.product_id = E.entity_id    
      where default_course_number is NULL and audio_brightcove_id is not NULL    
      union  All   
      select distinct Course_id,lecture_number,video_brightcove_id as brightcove_id, Video_duration as duration, 'Video' as Format    
      from   imports.magento.lectures L    
      left join Imports.magento.catalog_product_entity E     
      on L.product_id = E.entity_id    
      where default_course_number is NULL and video_brightcove_id is not null   
	  ) a
	 group by Course_id ,lecture_number
 
   


 select a.Customerid  
  ,a.Courseid  
  ,b.Counts as NumOfLectures  
  ,b.CourseRunTime  
  ,b.CourseRunTimeMins  
  ,sum(a.FlagCompletedLecture) NumOfLecturesCompleted  
  ,sum(a.FINALStreamedMins) FINALStreamedMins  
  ,max(a.LastLectureActivity) as LastCourseActivity  
  ,min(a.FirstLectureActivity) as FirstCourseActivity  
  ,convert(int,0) as FlagCompletedCourse  
  ,convert(float,0) as CourseCompletedPrcnt  
 into staging.Omni_TGC_LTDCourseConsumption  
 from Marketing.Omni_TGC_LTDLectureConsumption a   
  left join (  select course_id, count(lecture_number) Counts, sum(Duration) CourseRunTime, sum(Duration)/60.0 CourseRunTimeMins  
				from  #DMCourse
				group by course_id
			)b on a.Courseid = b.course_id  

  group by a.Customerid  
  ,a.Courseid  
  ,b.Counts  
  ,b.CourseRunTime,  
  b.CourseRunTimeMins  
  
 -- if they watched more than 90% of the course, then flag as completed.  
 update staging.Omni_TGC_LTDCourseConsumption  
 set FlagCompletedCourse = case when isnull(FINALStreamedMins,0)*1./nullif(CourseRunTimeMins,0) >= .90  then 1 else 0 end,  
  CourseCompletedPrcnt  = isnull(isnull(FINALStreamedMins,0)*1./nullif(CourseRunTimeMins,0),0)  
  
 -- Load into final table  
  
 If object_id ('Marketing.Omni_TGC_LTDCourseConsumption') is not null   
 drop table Marketing.Omni_TGC_LTDCourseConsumption  
  
 select *  ,getdate() as DMLastupdated
 into Marketing.Omni_TGC_LTDCourseConsumption  
 from  staging.Omni_TGC_LTDCourseConsumption  



 ---------------------------------------------------------------------------------------------------------------------------------------------------------
 ---------------------------------------------------------------LTD-Downloads-----------------------------------------------------------------------------
 ---------------------------------------------------------------------------------------------------------------------------------------------------------

  If object_id ('staging.Omni_TGC_LTDLectureDownloads') is not null  
 drop table staging.Omni_TGC_LTDLectureDownloads  

   select Customerid, CourseID,LectureNumber
  ,Min(case when TotalActions >0 then 1 else 0 end)Downloaded
  ,MAX(Actiondate) as LastLectureActivity  
  ,Min(Actiondate) as FirstLectureActivity  
  ,convert(int,1) as FlagCompletedLecture  
  ,convert(float,1) as LectureCompletedPrcnt
  Into staging.Omni_TGC_LTDLectureDownloads
  from DataWarehouse.Archive.Omni_TGC_Downloads
  where Customerid is not null and CourseID is not null
  and CourseID < 1000000  
  group by Customerid, CourseID,LectureNumber


  If object_id ('Marketing.Omni_TGC_LTDLectureDownloads') is not null   
 drop table Marketing.Omni_TGC_LTDLectureDownloads  
  
 select *,getdate() as DMLastUpdated  
 into Marketing.Omni_TGC_LTDLectureDownloads  
 from  staging.Omni_TGC_LTDLectureDownloads  



  
 -- Aggregate at course level  
 If object_id ('staging.Omni_TGC_LTDCourseDownloads') is not null  
 drop table staging.Omni_TGC_LTDCourseDownloads  

 
 select a.Customerid  
  ,a.Courseid  
  ,b.Counts as NumOfLectures  
  ,b.CourseRunTime  
  ,b.CourseRunTimeMins  
  ,sum(a.FlagCompletedLecture) NumOfLecturesCompleted  
  ,max(a.LastLectureActivity) as LastCourseActivity  
  ,min(a.FirstLectureActivity) as FirstCourseActivity  
  ,convert(int,0) as FlagCompletedCourse  
  ,convert(float,0) as CourseCompletedPrcnt  
 into staging.Omni_TGC_LTDCourseDownloads  
 from Marketing.Omni_TGC_LTDLectureDownloads a   
  left join (  select course_id, count(lecture_number) Counts, sum(Duration) CourseRunTime, sum(Duration)/60.0 CourseRunTimeMins  
				from  #DMCourse
				group by course_id
			)b on a.Courseid = b.course_id  

  group by a.Customerid  
  ,a.Courseid  
  ,b.Counts  
  ,b.CourseRunTime,  
  b.CourseRunTimeMins  

 update staging.Omni_TGC_LTDCourseDownloads  
 set FlagCompletedCourse = case when NumOfLectures = NumOfLecturesCompleted then 1 else 0 end ,  
  CourseCompletedPrcnt  =    isnull(NumOfLecturesCompleted*1./nullif(NumOfLectures,0),0)


  
 If object_id ('Marketing.Omni_TGC_LTDCourseDownloads') is not null   
 drop table Marketing.Omni_TGC_LTDCourseDownloads  
  
 select *  ,getdate() as DMLastupdated
 into Marketing.Omni_TGC_LTDCourseDownloads  
 from  staging.Omni_TGC_LTDCourseDownloads  


 ------------------------------------------------------------------------------------------------------------------------------------

 If object_id ('Staging.Omni_TGC_CourseFormat_LTD_Consumption') is not null   
 drop table Staging.Omni_TGC_CourseFormat_LTD_Consumption  
 
select Customerid, courseid,StockItemID,FormatMedia,FormatAD,cast(min(DateOrdered) as date) DateOrdered,
Case when formatmedia = 'DL' then 'Digital'
     when formatmedia = 'DV' then 'Digital'
      else 'Regular' end as FormatType,
	  Cast(0 as bit) as StreamedFlag,
	  Cast(0 as bit) as DownloadedFlag,
	  Cast(null as Date) as FirstStreamActivity,
	  Cast(null as Date) as FirstDownloadActivity

Into Staging.Omni_TGC_CourseFormat_LTD_Consumption
from  marketing.dmpurchaseorderitems
where SUBSTRING(StockItemID, 1, 2) NOT IN ('PT','DT') 
and Year(DateOrdered)>=2017
group by Customerid, courseid,StockItemID,FormatMedia,FormatAD ,Case when formatmedia = 'DL' then 'Digital' when formatmedia = 'DV' then 'Digital' else 'Regular' end 

/*Update Course Streaming Activity*/
  update DM
  set FirstStreamActivity = FirstCourseActivity,
  StreamedFlag = Case when ltd.customerid is not null then 1 else 0 end
   from Staging.Omni_TGC_CourseFormat_LTD_Consumption DM
  join Marketing.Omni_TGC_LTDCourseConsumption LTD
  on ltd.customerid = DM.Customerid
  and DM.Courseid = LTD.Courseid


/*Update Course Download Activity*/  
  update DM
  set FirstDownloadActivity = FirstCourseActivity,
  DownloadedFlag = Case when ltd.customerid is not null then 1 else 0 end
   from Staging.Omni_TGC_CourseFormat_LTD_Consumption DM
  join Marketing.Omni_TGC_LTDCourseDownloads LTD
  on ltd.customerid = DM.Customerid
  and DM.Courseid = LTD.Courseid

 If object_id ('Marketing.Omni_TGC_CourseFormat_LTD_Consumption') is not null   
 drop table Marketing.Omni_TGC_CourseFormat_LTD_Consumption  


 select * ,getdate() as DMLastUpdated
 into  Marketing.Omni_TGC_CourseFormat_LTD_Consumption 
 from  Staging.Omni_TGC_CourseFormat_LTD_Consumption

 End
GO
