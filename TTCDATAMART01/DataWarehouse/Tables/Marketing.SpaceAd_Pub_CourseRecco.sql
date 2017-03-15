CREATE TABLE [Marketing].[SpaceAd_Pub_CourseRecco]
(
[Publication] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseID] [int] NULL,
[Parts] [dbo].[udtCourseParts] NULL,
[CSATScore] [float] NULL,
[CourseName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SP_CourseID] [int] NULL,
[SP_Parts] [dbo].[udtCourseParts] NULL,
[SP_CSATScore] [float] NULL,
[SP_CourseName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SP_SubjectCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustCount] [int] NULL,
[SP_TotalSales] [money] NULL,
[FlagBundle] [tinyint] NULL,
[Rank] [float] NULL,
[ReportDate] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_SpaceAd_Pub_CourseRecco_pc] ON [Marketing].[SpaceAd_Pub_CourseRecco] ([Publication], [CourseID]) ON [PRIMARY]
GO
