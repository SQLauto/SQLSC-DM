CREATE TABLE [Staging].[Ecampn02A_BundleCourse]
(
[BundleID] [int] NOT NULL,
[BundleName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseID] [int] NOT NULL,
[CourseName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseParts] [dbo].[udtCourseParts] NULL,
[ReleaseDate] [datetime] NULL,
[Sales] [money] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Ecampn02A_BundleCourse1] ON [Staging].[Ecampn02A_BundleCourse] ([BundleID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Ecampn02A_BundleCourse2] ON [Staging].[Ecampn02A_BundleCourse] ([CourseID]) ON [PRIMARY]
GO
