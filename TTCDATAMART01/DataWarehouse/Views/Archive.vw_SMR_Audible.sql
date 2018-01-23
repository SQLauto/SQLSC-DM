SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[vw_SMR_Audible] as
select 
'Audible' as Platform, 
cast(Report_Month as date) as ReportDate, 
Course_ID, DMC.CourseName, DMC.PrimaryWebCategory,  DMC.ReleaseDate, 
sum(Revenue)/datediff ( day , dateadd ( day , 1-day(Report_Month) , Report_Month) , dateadd ( month , 1 , dateadd ( day , 1-day(Report_Month) , Report_Month))) RPD,
30 as DayUnit
from archive.Vw_Tb_Audible_Sales (nolock) a
	left join staging.Vw_DMCourse (nolock) DMC on a.Course_ID = DMC.CourseID
where a.Course_ID > 0
group by Report_Month, Course_ID, DMC.CourseName, DMC.PrimaryWebCategory, DMC.ReleaseDate
union all
select 
'Audible' as Platform,
cast(WeekEnding as date) as ReportDate, 
b.courseId as course_Id, DMC.CourseName, DMC.PrimaryWebCategory, DMC.ReleaseDate, 
(sum(TotalNetPayments)/7) RPD,
7 as DayUnit
from archive.audible_weekly_sales (nolock) b 
	left join staging.Vw_DMCourse (nolock) DMC on b.CourseID = DMC.CourseID
where b.CourseID > 0
group by WeekEnding, b.courseId, DMC.CourseName, DMC.PrimaryWebCategory, DMC.ReleaseDate
; 
GO
