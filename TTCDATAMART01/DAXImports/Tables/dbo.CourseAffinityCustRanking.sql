CREATE TABLE [dbo].[CourseAffinityCustRanking]
(
[MainCourseID] [int] NULL,
[MainCourseName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MainReleaseDate] [datetime] NULL,
[MainDaysSinceRls] [int] NULL,
[MainCourseParts] [money] NULL,
[MainSubjCat] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpsellCourseID] [int] NULL,
[UpsellCourseName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpsellReleaseDate] [datetime] NULL,
[UpsellDaysSinceRls] [int] NULL,
[UpsellCourseParts] [money] NULL,
[UpsellSubjCat] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustCount] [int] NULL,
[Rank] [bigint] NULL,
[CustCount2] [numeric] (13, 1) NULL,
[Rank2] [bigint] NULL
) ON [PRIMARY]
GO
