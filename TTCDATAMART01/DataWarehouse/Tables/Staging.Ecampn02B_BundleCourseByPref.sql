CREATE TABLE [Staging].[Ecampn02B_BundleCourseByPref]
(
[SumSales] [money] NULL,
[CourseID] [int] NOT NULL,
[PreferredCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Ecampn02B_BundleCourseByPref] ON [Staging].[Ecampn02B_BundleCourseByPref] ([CourseID]) ON [PRIMARY]
GO
