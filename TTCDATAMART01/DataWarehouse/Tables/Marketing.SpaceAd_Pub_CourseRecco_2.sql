CREATE TABLE [Marketing].[SpaceAd_Pub_CourseRecco_2]
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
[Rank2] [bigint] NULL
) ON [PRIMARY]
GO
