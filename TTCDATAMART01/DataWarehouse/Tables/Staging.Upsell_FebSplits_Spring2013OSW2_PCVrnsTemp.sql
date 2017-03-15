CREATE TABLE [Staging].[Upsell_FebSplits_Spring2013OSW2_PCVrnsTemp]
(
[MainCourseID] [int] NULL,
[MainCourseName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[courseid] [int] NULL,
[AbbrvCourseName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseParts] [money] NULL,
[TotalUnits] [int] NULL,
[TotalSales] [money] NULL,
[TotalOrders] [int] NULL,
[Rank] [float] NULL,
[FlagSameCourse] [tinyint] NULL,
[FlagOSWCourse] [tinyint] NULL
) ON [PRIMARY]
GO
