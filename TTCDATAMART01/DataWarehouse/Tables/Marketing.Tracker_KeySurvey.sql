CREATE TABLE [Marketing].[Tracker_KeySurvey]
(
[Year] [int] NULL,
[Month] [int] NULL,
[Survey_date] [date] NULL,
[CourseID] [int] NULL,
[CourseName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuestionCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MediaType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NineTens] [int] NULL,
[ZeroEights] [int] NULL,
[ReportRunDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
