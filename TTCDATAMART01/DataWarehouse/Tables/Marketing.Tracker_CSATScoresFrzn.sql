CREATE TABLE [Marketing].[Tracker_CSATScoresFrzn]
(
[CourseID] [int] NULL,
[CourseName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AbbrvCourseName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseParts] [dbo].[udtCourseParts] NULL,
[ReleaseDate] [datetime] NULL,
[TrackerStartDate] [date] NULL,
[TrackerEndDate] [date] NULL,
[NumOfTrackers] [int] NULL,
[MinSubDate] [date] NULL,
[MaxSubmitDate] [date] NULL,
[CourseSat_9s10s] [int] NULL,
[CourseSat_0s8s] [int] NULL,
[CourseSat_All] [int] NULL,
[CSATScore] [numeric] (38, 6) NULL,
[FlagComplete] [int] NOT NULL,
[ReportDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
