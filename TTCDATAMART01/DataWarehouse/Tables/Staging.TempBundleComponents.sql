CREATE TABLE [Staging].[TempBundleComponents]
(
[BundleID] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BundleName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BundleParts] [dbo].[udtCourseParts] NULL,
[CourseID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseParts] [dbo].[udtCourseParts] NULL,
[Total] [int] NULL,
[Portion] [float] NULL
) ON [PRIMARY]
GO
