CREATE TABLE [Staging].[Upsell_CourseAffinity_TempAnonymous]
(
[CourseID] [int] NULL,
[Parts] [dbo].[udtCourseParts] NULL,
[CSATScore] [float] NULL,
[CourseName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategoryID] [int] NULL,
[ReleaseDate] [datetime] NULL,
[FP_Rank] [float] NULL,
[FP_StartDate] [datetime] NULL,
[FP_EndDate] [datetime] NULL,
[ReportDate] [datetime] NULL,
[FlagAnonymous] [int] NOT NULL,
[SP_CourseID] [int] NOT NULL,
[SP_Parts] [dbo].[udtCourseParts] NULL,
[SP_CSATScore] [float] NULL,
[SP_CourseName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SP_SubjectCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SP_SubjectCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SP_SubjectCategoryID] [int] NULL,
[SP_ReleaseDate] [datetime] NULL,
[SP_DaysSinceRelease] [int] NULL,
[FlagRecentRelease] [int] NOT NULL,
[TotalSP_SinceRelease] [int] NULL,
[TotalSP_All] [int] NULL,
[SP_CourseAffFactor] [int] NULL,
[CustCount] [int] NOT NULL,
[AdjustedCustCount] [int] NOT NULL,
[Rank] [int] NULL,
[RankAdjusted] [float] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_Upsell_CourseAffinity_TempAnonymous_FC] ON [Staging].[Upsell_CourseAffinity_TempAnonymous] ([CourseID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Upsell_CourseAffinity_TempAnonymous_SC] ON [Staging].[Upsell_CourseAffinity_TempAnonymous] ([SP_CourseID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Upsell_CourseAffinity_TempAnonymous_SRD] ON [Staging].[Upsell_CourseAffinity_TempAnonymous] ([SP_ReleaseDate]) ON [PRIMARY]
GO
