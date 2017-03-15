CREATE TABLE [Staging].[TempSetCourseRank]
(
[BundleID] [int] NULL,
[CourseID] [int] NOT NULL,
[CourseParts] [dbo].[udtCourseParts] NULL,
[Rank] [bigint] NULL,
[UpsellCourseID] [int] NULL,
[DisplayOrder] [float] NULL,
[CountryCode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FinalRank] [float] NULL
) ON [PRIMARY]
GO
