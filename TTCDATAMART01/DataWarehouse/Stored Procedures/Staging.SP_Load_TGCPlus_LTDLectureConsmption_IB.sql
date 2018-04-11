SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROC [Staging].[SP_Load_TGCPlus_LTDLectureConsmption_IB]
AS

BEGIN


	/***************** Create working table *************************/

	If object_id ('#TempTGCPlus_LTDLectureConsumption') is not null
	drop table #TempTGCPlus_LTDLectureConsumption

	/*select V.Id
		,v.Vid
		,f.Course_id
		,F.seriestitle as CourseTitle
		,F.Episode_Number
		,F.title as LectureTitle
		,F.Film_Type
		,f.genre as SubjectCategory
		,(v.lectureRunTime / 60.0) as LectureRunMins
		,v.FlagAudio
		 v.FlagOffline,
		  v.Speed,
		  v.Player,
	Year(v.tstamp) as YearPlayed,        
	Month(v.tstamp) as MonthPlayed,  
	  cast(staging.getmonday(v.tstamp) as date) as WeekPlayed,        
  cast(v.tstamp as date) as DatePlayed,
		,sum(v.StreamedMins) StreamedMins
		,max(MaxVpos) Max_VPOS
		,(max(MaxVpos) / 60.0) Max_VPOSMins 
		,case when sum(v.StreamedMins) > (v.lectureRunTime / 60.0) then (v.lectureRunTime / 60.0) else sum(v.StreamedMins) end as StreamedMinsCapped
		,case when sum(v.StreamedMins) > (v.lectureRunTime / 60.0) then (v.lectureRunTime / 60.0) else sum(v.StreamedMins) end as FINALStreamedMins
		,MAX(V.tstamp) as LastLectureActivity
		,Min(V.tstamp) as FirstLectureActivity
		,convert(int,0) as FlagCompletedLecture
		,convert(float,0) as LectureCompletedPrcnt
	into #TempTGCPlus_LTDLectureConsumption
	from DataWarehouse.Marketing.TGCplus_VideoEvents_Smry V 
	left join DataWarehouse.Archive.TGCPlus_Film F
		on F.uuid=V.Vid
	group by v.Id
		,v.Vid
		,f.Course_id
		,F.seriestitle
		,F.Episode_Number
		,F.title
		,F.Film_Type
		,f.genre
		,(v.lectureRunTime / 60.0)
		,v.FlagAudio
		 v.FlagOffline,
		  v.Speed,
		  v.Player,
	Year(v.tstamp) as YearPlayed,        
	Month(v.tstamp) as MonthPlayed,  
	  cast(staging.getmonday(v.tstamp) as date) ,       
  cast(v.tstamp as date) as DatePlayed*/


  select	V.Id
		,v.Vid
		,f.Course_id
		,F.seriestitle as CourseTitle
		,F.Episode_Number
		,F.title as LectureTitle
		,F.Film_Type
		,f.genre as SubjectCategory
		,(v.lectureRunTime / 60.0) as LectureRunMins
		,v.FlagAudio
		 ,v.FlagOffline
		  ,v.Speed
		  ,v.Player
	,Year(v.tstamp) as YearPlayed       
	,Month(v.tstamp) as MonthPlayed
	  ,cast(staging.getmonday(v.tstamp) as date) as WeekPlayed     
  ,cast(v.tstamp as date) as DatePlayed
		,sum(v.StreamedMins) StreamedMins
		,max(MaxVpos) Max_VPOS
		,(max(MaxVpos) / 60.0) Max_VPOSMins 
		,case when sum(v.StreamedMins) > (v.lectureRunTime / 60.0) then (v.lectureRunTime / 60.0) else sum(v.StreamedMins) end as StreamedMinsCapped
		,case when sum(v.StreamedMins) > (v.lectureRunTime / 60.0) then (v.lectureRunTime / 60.0) else sum(v.StreamedMins) end as FINALStreamedMins
		,MAX(V.tstamp) as LastLectureActivity
		,Min(V.tstamp) as FirstLectureActivity
		,convert(int,0) as FlagCompletedLecture
		,convert(float,0) as LectureCompletedPrcnt
	into #TempTGCPlus_LTDLectureConsumption
	from DataWarehouse.Marketing.TGCplus_VideoEvents_Smry V 
	left join DataWarehouse.Archive.TGCPlus_Film F
		on F.uuid=V.Vid
		where year(v.TSTAMP)=2018
	group by v.Id
		,v.Vid
		,f.Course_id
		,F.seriestitle
		,F.Episode_Number
		,F.title
		,F.Film_Type
		,f.genre
		,(v.lectureRunTime / 60.0)
		,v.FlagAudio
		 ,v.FlagOffline,
		  v.Speed,
		  v.Player,
	Year(v.tstamp) ,   
	Month(v.tstamp),
	  cast(staging.getmonday(v.tstamp) as date) ,       
  cast(v.tstamp as date)
	
	-- if watched mins is greater than max vpos, then they streamed the same part multiple times and have not watched the complete lecture
	update #TempTGCPlus_LTDLectureConsumption
	set FINALStreamedMins = Max_VPOSMins
	where StreamedMinsCapped - Max_VPOSMins > 1

	-- if they watched more than 95% of the course, then flag as completed.
	update #TempTGCPlus_LTDLectureConsumption
	--set FlagCompletedLecture = case when isnull(FINALStreamedMins,0)*1./nullif(LectureRunMins,0) >.95  then 1 else 0 end,
	set FlagCompletedLecture = case when isnull(FINALStreamedMins,0)*1./nullif(LectureRunMins,0) >= .90  then 1 else 0 end,
		LectureCompletedPrcnt  = isnull(isnull(FINALStreamedMins,0)*1./nullif(LectureRunMins,0),0)

	If object_id ('Marketing.TGCPlus_LTDLectureConsumption_IB') is not null 
	drop table Marketing.TGCPlus_LTDLectureConsumption_IB

	select *
	into Marketing.TGCPlus_LTDLectureConsumption_IB
	from  #TempTGCPlus_LTDLectureConsumption


	--If object_id ('Marketing.TGCPlus_LTDLectureConsumption_IB') is not null
	--truncate table Marketing.TGCPlus_LTDLectureConsumption_IB

	--insert into Marketing.TGCPlus_LTDLectureConsumption_IB
	--select *
	--from  #TempTGCPlus_LTDLectureConsumption

	-- Aggregate at course level
	If object_id ('#TempTGCPlus_LTDCourseConsumption') is not null
	drop table #TempTGCPlus_LTDCourseConsumption
	
	select a.id
		,a.Course_id
		,a.CourseTitle
		,a.Film_Type
		,a.SubjectCategory
		,b.Counts as NumOfLectures
		,b.CourseRunTime
		,b.CourseRunTimeMins
		,a.FlagAudio
		 ,a.FlagOffline
		  ,a.Speed
		  ,a.Player
	, a.YearPlayed       
	, a.MonthPlayed
	  ,a.WeekPlayed     
  ,a.DatePlayed
		,sum(a.FlagCompletedLecture) NumOfLecturesCompleted
		,sum(a.FINALStreamedMins) FINALStreamedMins
		,max(a.LastLectureActivity) as LastCourseActivity
		,min(a.FirstLectureActivity) as FirstCourseActivity
		,convert(int,0) as FlagCompletedCourse
		,convert(float,0) as CourseCompletedPrcnt
	into #TempTGCPlus_LTDCourseConsumption
	from Marketing.TGCPlus_LTDLectureConsumption_IB a
		left join (select course_id, film_type, count(episode_number) Counts, sum(runtime) CourseRunTime, sum(runtime)/60.0 CourseRunTimeMins
					from DataWarehouse.Archive.TGCPlus_Film
					--where status = 'Open'
					group by course_id, film_type)b on a.Course_id = b.course_id
	where b.film_type = 'Episode'
	--and a.id in (3035217,2486163)
	group by a.id
		,a.Course_id
		,a.CourseTitle
		,a.Film_Type
		,a.SubjectCategory
		,b.Counts
		,b.CourseRunTime,
		b.CourseRunTimeMins
		,a.FlagAudio
		 ,a.FlagOffline
		  ,a.Speed
		  ,a.Player
	, a.YearPlayed       
	, a.MonthPlayed
	  ,a.WeekPlayed     
  ,a.DatePlayed

	-- if they watched more than 95% of the course, then flag as completed.
	update #TempTGCPlus_LTDCourseConsumption
	--set FlagCompletedCourse = case when isnull(FINALStreamedMins,0)*1./nullif(CourseRunTimeMins,0) >.95  then 1 else 0 end,
	set FlagCompletedCourse = case when isnull(FINALStreamedMins,0)*1./nullif(CourseRunTimeMins,0) >= .90  then 1 else 0 end,
		CourseCompletedPrcnt  = isnull(isnull(FINALStreamedMins,0)*1./nullif(CourseRunTimeMins,0),0)

	-- Load into final table

	If object_id ('Marketing.TGCPlus_LTDCourseConsumption_IB') is not null 
	drop table Marketing.TGCPlus_LTDCourseConsumption_IB

	select *
	into Marketing.TGCPlus_LTDCourseConsumption_IB
	from  #TempTGCPlus_LTDCourseConsumption

END
 
GO
