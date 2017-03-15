CREATE TABLE [Staging].[TempSetCourse]
(
[BundleID] [int] NULL,
[CourseID] [int] NOT NULL,
[CourseParts] [dbo].[udtCourseParts] NULL,
[Rank] [bigint] NULL
) ON [PRIMARY]
GO
