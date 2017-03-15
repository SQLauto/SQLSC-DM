SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [Staging].[SP_TGCPlus_ConsumptionFreeMonthChurn] 
As
Begin
/* SP to Calculate TGCplus */


/* Load initial Streaming information */
	select *
	into #video1
	from DataWarehouse.Marketing.TGCplus_VideoEvents_Smry
	where SeqNum = 1

/* Segment initial Streaming information */
	select a.*, 
		   CustStatus = case when a.CustStatusFlag = -1 then 'Cancelled'
									 else 'Entitled'
							   end,
		   b.courseid IntlCourseID, b.episodeNumber IntlLectureNumber, 
		   b.FilmType IntlFilmType, b.lectureRunTime IntlLectureRunTime, b.MaxVPOS IntlMaxVPOS,
		   b.MinTstamp IntlDateTimePlayed, b.TSTAMP IntlDatePlayed, b.useragent IntlUserAgent, b.Vid Intlvid,
		   b.StreamedMins IntlStreamedMins, b.Platform IntlPlatform, b.Week IntlWeekPlayed, b.Year IntlYearPlayed,
		   c.seriestitle IntlCourseName, c.title IntlLectureName,c.genre IntlSubjectCategory,
		   case when b.streamedMins = 0 then '1) < 0.5 mins'
				 when b.StreamedMins > 0 and b.StreamedMins < 2 then '2) 0.5 - 2 mins'
				 when b.StreamedMins >= 2 and b.StreamedMins <= 10 then '3) 2 - 10 mins'
				 when b.StreamedMins > 10 and b.StreamedMins <= 20 then '4) 10.5 - 20 mins'
				 when b.StreamedMins > 20 and b.StreamedMins <= 30 then '5) 20.5 - 30 mins'
				 when b.StreamedMins > 30 and b.StreamedMins <= 40 then '6) 30.5 - 40 mins'
				 when b.StreamedMins > 40 then '7) > 40 mins'
				 else '8) None'
		   end as IntlStreamedMinBin,
		   datediff(MINUTE,a.IntlSubDate, b.TSTAMP) IntlPlay_MSIS,
		   datediff(day,a.IntlSubDate, b.TSTAMP) IntlPlay_DSIS,
		   case when datediff(day,a.IntlSubDate, b.TSTAMP) = 0 then '1) Same Day'
				 when datediff(day,a.IntlSubDate, b.TSTAMP) = 1 then '2) Day 2'
				 when datediff(day,a.IntlSubDate, b.TSTAMP) = 2 then '3) Day 3'
				 when datediff(day,a.IntlSubDate, b.TSTAMP) < 0 then '6) Beta'
				 when datediff(day,a.IntlSubDate, b.TSTAMP) > 2 then '4) Days 4+'
				 else '5) None'
				 end as IntlPlay_DSISBin,
		   TenureDays=DATEDIFF(d,a.IntlSubDate,cast(getdate() as date)),
		   TenureMonths=
						case when cast(getdate() as date) = a.IntlSubDate then 0
							   when DATEPART(D,dateadd(day,-1,cast(getdate() as date))) >=DATEPART(D,a.IntlSubDate) 
								THEN ( case when DATEPART(M,dateadd(day,-1,cast(getdate() as date))) = DATEPART(M,a.IntlSubDate) AND DATEPART(YYYY,dateadd(day,-1,cast(getdate() as date))) = DATEPART(YYYY,a.IntlSubDate) 
								THEN 0 ELSE DATEDIFF(M,a.IntlSubDate,dateadd(day,-1,cast(getdate() as date)))END )
							   ELSE DATEDIFF(M,a.IntlSubDate,dateadd(day,-1,cast(getdate() as date)))-1 end
				 --(8387 row(s) affected)
		   --,a.IntlSubDate, b.MinTstamp
	into #video2
	from DataWarehouse.Marketing.TGCPlus_CustomerSignature a 
	left join #video1 b on a.uuid = b.UUID 
	left join DataWarehouse.Archive.TGCPlus_Film c on b.Vid = c.uuid

	--select IntlStreamedMinBin, count(*) from #video2
	--group by IntlStreamedMinBin
	--order by 1

	--select IntlPlay_DSISBin, count(*) from #video2
	--group by IntlPlay_DSISBin
	--order by 2 desc


/* Calculating LTD values for watched Courses*/
	select a.uuid, a.id,
		   count(distinct a.CourseID) LTDCoursesWatched,
		   count(a.episodenumber) LTDLecturesWatched,
		   sum(a.Plays) LTDNumPlays,
		   sum(a.pings) LTDNumPings,
		   sum(a.StreamedMins) LTDStreamedMins,
		   sum(a.streamedmins)/60 LTDStreamedHrs,
		   count(distinct a.tstamp) LTDNumDaysWatched,
		   count(distinct b.genre) LTDNumSubjects,
		   count(distinct a.Platform) LTDNumPlatforms
	into #custltd
	from DataWarehouse.Marketing.TGCplus_VideoEvents_Smry a 
	join datawarehouse.archive.tgcplus_film b on a.Vid = b.uuid
	where a.FilmType <> 'Trailer'
	group by a.uuid, a.id


/* Segment LTD values for watched Courses*/
	select *, 
		   LTDCourseWatchBin = case when LTDCoursesWatched = 1 then '1) 1 course'
												   when  LTDCoursesWatched between 2 and 3 then '2) 2-3 courses'
												   when  LTDCoursesWatched between 4 and 7 then '3) 4-7 courses'
												   when  LTDCoursesWatched >= 8 then '4) >= 8 courses'
												   else '5) None'
											end,
		   LTDLectureWatchBin =       case when LTDLecturesWatched between 1 and 5 then '1) 1-5 Lectures'
												   when LTDLecturesWatched between 6 and 15 then '2) 6-15 Lectures'
												   when LTDLecturesWatched between 16 and 50 then '3) 16-50 Lectures'
												   when LTDLecturesWatched > 51 then '4) >= 51 Lectures'
												   else '5) None'
											end,
		   LTDStreamedMinsBin =       case when LTDStreamedMins = 0 then '1) 0 mins'
												   when LTDStreamedMins between .5 and 10 then '2) 0.5-10 mins'
												   when LTDStreamedMins between 10.5 and 30 then '3) 10.5-30 mins'
												   when LTDStreamedMins between 30.5 and 50 then '4) 30.5-50 mins'
												   when LTDStreamedMins between 50.5 and 80 then '5) 50.5-80 mins'
												   when LTDStreamedMins between 80.5 and 130 then '6) 80.5-130 mins'
												   when LTDStreamedMins between 130.5 and 200 then '7) 130.5-200 mins'
												   when LTDStreamedMins between 200.5 and 300 then '8) 200.5-300 mins'
												   when LTDStreamedMins between 300.5 and 500 then '9) 300.5-500 mins'
												   when LTDStreamedMins between 500.5 and 800 then '10) 500.5-800 mins'
												   when LTDStreamedMins between 800.5 and 1300 then '11) 800.5-1300 mins'
												   when LTDStreamedMins between 1300.5 and 2000 then '12) 1300.5-2000 mins'
												   when LTDStreamedMins between 2000.5 and 5000 then '13) 2000.5-5000 mins'
												   when LTDStreamedMins > 5000 then '14) > 5000 mins'
												   else '15) None'
											end,
		   LTDNumSubjectBin = case when LTDNumSubjects = 1 then '1) 1 Subject'
												   when LTDNumSubjects = 2 then '2) 2 Subjects'
												   when LTDNumSubjects between 3 and 4 then '3) 3-4 Subjects'
												   when LTDNumSubjects between 5 and 6 then '4) 5-6 Subjects'
												   when LTDNumSubjects > 6 then '5) >= 7 Subjects'
												   else '6) None'
											end
	into #custltd2
	from #custltd

--select * from #Custltd2

	select a.*, b.LTDCoursesWatched, b.LTDCourseWatchBin,
		   b.LTDLecturesWatched, b.LTDLectureWatchBin,
		   b.LTDNumDaysWatched, b.LTDNumPings, b.LTDNumPlatforms, b.LTDNumPlays,
		   b.LTDNumSubjects, b.LTDNumSubjectBin, b.LTDStreamedMins, b.LTDStreamedMinsBin,
		   b.LTDStreamedHrs
	into #video3
	from #video2 a 
	left join #custltd2 b on a.uuid = b.UUID



/* Calculate Downstream 30 days Streaming*/
	select  a.uuid, a.IntlSubDate, 
		   dateadd(day,30,cast(dateadd(day,1,a.IntlSubDate) as date)) DS0_StopDate,
		   min(b.TSTAMP) minstamp, max(b.TSTAMP) maxstamp,
		   sum(isnull(b.StreamedMins,0)) DS0Mnth_StreamedMins,
		   sum(isnull(b.plays,0)) DS0Mnth_NumPlays,
		   count(distinct b.Platform) DS0Mnth_NumPlatform,
		   count(distinct b.courseid) DS0Mnth_NumCourses,
		   count(distinct b.episodeNumber) DS0Mnth_NumLectures,
		   count(distinct c.genre) DS0Mnth_NumSubjects,
		   count(distinct b.tstamp) DS0Mnth_NumDaysWatched
	into #DS0_1
	from DataWarehouse.Marketing.TGCPlus_CustomerSignature a
		   left join DataWarehouse.Marketing.TGCplus_VideoEvents_Smry b 
		   on a.uuid = b.UUID and b.TSTAMP between cast(a.IntlSubDate as date) and dateadd(day,30,cast(dateadd(day,1,a.IntlSubDate) as date))
		   join DataWarehouse.Archive.TGCPlus_Film c on b.Vid = c.uuid
	where b.FilmType <> 'Trailer'
	group by a.uuid, a.IntlSubDate,dateadd(day,30,cast(dateadd(day,1,a.IntlSubDate) as date))

/* Segment Downstream 30 days Streaming*/
	select *, 
				 DS0Mnth_CourseWatchBin =   case when DS0Mnth_NumCourses = 1 then '1) 1 course'
																	   when  DS0Mnth_NumCourses between 2 and 3 then '2) 2-3 courses'
																	   when  DS0Mnth_NumCourses between 4 and 7 then '3) 4-7 courses'
																	   when  DS0Mnth_NumCourses >= 8 then '4) >= 8 courses'
																	   else '5) None'
																end,
		   DS0Mnth_LectureWatchBin =  case when DS0Mnth_NumLectures between 1 and 5 then '1) 1-5 Lectures'
												   when DS0Mnth_NumLectures between 6 and 15 then '2) 6-15 Lectures'
												   when DS0Mnth_NumLectures between 16 and 50 then '3) 16-50 Lectures'
												   when DS0Mnth_NumLectures > 51 then '4) >= 51 Lectures'
												   else '5) None'
											end,
		   DS0Mnth_StreamedMinsBin =  case when DS0Mnth_StreamedMins = 0 then '1) 0 mins'
												   when DS0Mnth_StreamedMins between .5 and 10 then '2) 0.5-10 mins'
												   when DS0Mnth_StreamedMins between 10.5 and 30 then '3) 10.5-30 mins'
												   when DS0Mnth_StreamedMins between 30.5 and 50 then '4) 30.5-50 mins'
												   when DS0Mnth_StreamedMins between 50.5 and 80 then '5) 50.5-80 mins'
												   when DS0Mnth_StreamedMins between 80.5 and 130 then '6) 80.5-130 mins'
												   when DS0Mnth_StreamedMins between 130.5 and 200 then '7) 130.5-200 mins'
												   when DS0Mnth_StreamedMins between 200.5 and 300 then '8) 200.5-300 mins'
												   when DS0Mnth_StreamedMins between 300.5 and 500 then '9) 300.5-500 mins'
												   when DS0Mnth_StreamedMins between 500.5 and 800 then '10) 500.5-800 mins'
												   when DS0Mnth_StreamedMins between 800.5 and 1300 then '11) 800.5-1300 mins'
												   when DS0Mnth_StreamedMins between 1300.5 and 2000 then '12) 1300.5-2000 mins'
												   when DS0Mnth_StreamedMins between 2000.5 and 5000 then '13) 2000.5-5000 mins'
												   when DS0Mnth_StreamedMins > 5000 then '14) > 5000 mins'
												   else '15) None'
											end,
		   DS0Mnth_NumSubjectBin =    case when DS0Mnth_NumSubjects = 1 then '1) 1 Subject'
												   when DS0Mnth_NumSubjects = 2 then '2) 2 Subjects'
												   when DS0Mnth_NumSubjects between 3 and 4 then '3) 3-4 Subjects'
												   when DS0Mnth_NumSubjects between 5 and 6 then '4) 5-6 Subjects'
												   when DS0Mnth_NumSubjects > 6 then '5) >= 7 Subjects'
												   else '6) None'
											end
	into #DS0_2
	from #DS0_1


/* Load into Final Table */

If object_id('Marketing.TGCPlus_ConsumptionFreeMonthChurn') is not null
Drop table Marketing.TGCPlus_ConsumptionFreeMonthChurn

	select a.*, b.IntlSubDate as DS0_IntlSubDate,
		   b.DS0_StopDate,
		   b.minstamp, b.maxstamp,
		   b.DS0Mnth_NumCourses, b.DS0Mnth_CourseWatchBin,
		   b.DS0Mnth_NumLectures, b.DS0Mnth_LectureWatchBin,
		   b.DS0Mnth_NumDaysWatched,
		   b.DS0Mnth_NumPlatform,
		   b.DS0Mnth_NumPlays,
		   b.DS0Mnth_NumSubjects, b.DS0Mnth_NumSubjectBin,
		   b.DS0Mnth_StreamedMins, b.DS0Mnth_StreamedMinsBin
	into Marketing.TGCPlus_ConsumptionFreeMonthChurn
	from #video3 a 
	left join #DS0_2 b on a.uuid = b.UUID

--select * from Marketing.TGCPlus_ConsumptionFreeMonthChurn

/*Clean up temp tables*/
drop table #video1
drop table #video2
drop table #custltd
drop table #custltd2
drop table #DS0_1
drop table #DS0_2



End
GO
