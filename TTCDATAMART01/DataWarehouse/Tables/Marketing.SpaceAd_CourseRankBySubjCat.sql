CREATE TABLE [Marketing].[SpaceAd_CourseRankBySubjCat]
(
[SubjectCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SP_CourseID] [int] NULL,
[SP_Parts] [dbo].[udtCourseParts] NULL,
[SP_CSATScore] [float] NULL,
[SP_CourseName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SP_SubjectCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SP_TotalSales] [money] NULL,
[Rank] [float] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_SpaceAd_CourseRankBySubjCat] ON [Marketing].[SpaceAd_CourseRankBySubjCat] ([SubjectCategory]) ON [PRIMARY]
GO
