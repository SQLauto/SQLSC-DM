CREATE TABLE [Staging].[Ecampn02A_BundleCourseTEMP]
(
[BundleID] [int] NOT NULL,
[BundleName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseID] [int] NOT NULL,
[CourseName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseParts] [dbo].[udtCourseParts] NULL,
[PublishDate] [datetime] NULL,
[Sales] [money] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Ecampn02A_BundleCourseTEMP1] ON [Staging].[Ecampn02A_BundleCourseTEMP] ([BundleID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Ecampn02A_BundleCourseTEMP2] ON [Staging].[Ecampn02A_BundleCourseTEMP] ([CourseID]) ON [PRIMARY]
GO
