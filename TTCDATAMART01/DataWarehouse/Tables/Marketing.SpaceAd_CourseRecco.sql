CREATE TABLE [Marketing].[SpaceAd_CourseRecco]
(
[CourseID] [int] NULL,
[Parts] [money] NULL,
[CSATScore] [float] NULL,
[CourseName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SP_CourseID] [int] NULL,
[SP_Parts] [money] NULL,
[SP_CSATScore] [float] NULL,
[SP_CourseName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SP_SubjectCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustCount] [int] NULL,
[SP_TotalSales] [money] NULL,
[FlagBundle] [tinyint] NULL,
[Rank] [bigint] NULL,
[ReportDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
