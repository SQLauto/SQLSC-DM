SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE View [Marketing].[Vw_TGCPlus_ConsumptionCourseLvl]
as

select CourseID,
	Coursename,
	FilmType,
	YearPlayed,
	MonthPlayed,
	WeekPlayed,
	DatePlayed,
	sum(NumOfPlays) NumOfPlays,
	sum(StreamedSeconds) StreamedSeconds,
	sum(StreamedMinutes) StreamedMinutes
from Marketing.TGCPlus_ConsumptionAll
group by CourseID,
	Coursename,
	FilmType,
	YearPlayed,
	MonthPlayed,
	WeekPlayed,
	DatePlayed
	

GO
