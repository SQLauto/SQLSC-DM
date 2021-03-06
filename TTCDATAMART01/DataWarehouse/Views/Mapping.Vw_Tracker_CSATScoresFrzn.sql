SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Mapping].[Vw_Tracker_CSATScoresFrzn]
AS


select a.CourseID
		,a.AbbrvCourseName
		,a.CourseParts
		,a.ReleaseDate
		,cast(DATEADD(q, DATEDIFF(q, 0, a.ReleaseDate) + 1, 0) as date) TrackerStartDate
		,cast(eomonth(DATEADD(q, DATEDIFF(q, 0, a.ReleaseDate) + 1, 0),12) as date)  TrackerEndDate
		,count(distinct b.TrackerName) NumOfTrackers
		,min(b.SubmitDate) MinSubDate
		,max(b.SubmitDate) MaxSubmitDate
		,sum(case when b.COURSESAT >= 10 then 1 else 0 end) CourseSat_9s10s
		,sum(case when b.COURSESAT < 10 then 1 else 0 end) CourseSat_0s8s
		,sum(case when b.COURSESAT between 1 and 11 then 1 else 0 end) CourseSat_All
		,case when sum(case when b.COURSESAT between 1 and 11 then 1.0 else 0 end) > 0 then 
						(sum(case when b.COURSESAT >= 10 then 1.0 else 0 end)/sum(case when b.COURSESAT between 1 and 11 then 1.0 else 0 end)) 
			else null 
		 end CSATScore
		,case when getdate() > eomonth(DATEADD(q, DATEDIFF(q, 0, a.ReleaseDate) + 1, 0),12) then 1 else 0 end as FlagComplete
		,getdate() ReportDate
from (select *
	from DataWarehouse.Mapping.dmcourse
	where BundleFlag = 0)a left join
	Marketing.QuarterlyTrackerResults b on a.CourseID = b.courseid
								and b.SubmitDate between DATEADD(q, DATEDIFF(q, 0, a.ReleaseDate) + 1, 0) and eomonth(DATEADD(q, DATEDIFF(q, 0, a.ReleaseDate) + 1, 0),12)
group by a.CourseID
		,a.AbbrvCourseName
		,a.CourseParts
		,a.ReleaseDate
	,DATEADD(q, DATEDIFF(q, 0, a.ReleaseDate) + 1, 0)
		,eomonth(DATEADD(q, DATEDIFF(q, 0, a.ReleaseDate) + 1, 0),12) 



GO
