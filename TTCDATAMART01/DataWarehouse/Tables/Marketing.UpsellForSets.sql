CREATE TABLE [Marketing].[UpsellForSets]
(
[BundleID] [int] NULL,
[BundleName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MainReleaseDate] [datetime] NULL,
[MainDaysSinceRls] [int] NULL,
[MainCourseParts] [dbo].[udtCourseParts] NULL,
[MainSubjCat] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpsellCourseID] [int] NULL,
[UpsellCourseName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpsellReleaseDate] [datetime] NULL,
[UpsellDaysSinceRls] [int] NULL,
[UpsellCourseParts] [dbo].[udtCourseParts] NULL,
[UpsellSubjCat] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DisplayOrder] [bigint] NULL,
[UpdateDate] [datetime] NULL
) ON [PRIMARY]
GO
