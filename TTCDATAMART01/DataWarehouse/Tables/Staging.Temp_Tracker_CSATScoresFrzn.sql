CREATE TABLE [Staging].[Temp_Tracker_CSATScoresFrzn]
(
[CourseID] [float] NULL,
[AbbrvCourseName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseParts] [float] NULL,
[ReleaseDate] [datetime] NULL,
[TrackerStartDate] [datetime] NULL,
[TrackerEndDate] [datetime] NULL,
[NumOfTrackers] [float] NULL,
[MinSubDate] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MaxSubmitDate] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseSat_9s10s] [float] NULL,
[CourseSat_0s8s] [float] NULL,
[CourseSat_All] [float] NULL,
[CSATScore] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagComplete] [float] NULL,
[ReportDate] [datetime] NULL
) ON [PRIMARY]
GO
