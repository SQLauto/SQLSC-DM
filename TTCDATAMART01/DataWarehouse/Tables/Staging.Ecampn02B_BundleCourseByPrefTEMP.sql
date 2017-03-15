CREATE TABLE [Staging].[Ecampn02B_BundleCourseByPrefTEMP]
(
[SumSales] [money] NULL,
[CourseID] [int] NOT NULL,
[PreferredCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Rank] [float] NULL,
[BundleFlag] [tinyint] NULL,
[CourseParts] [int] NULL,
[SumSalesBkp] [money] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Ecampn02B_BundleCourseByPrefTEMP] ON [Staging].[Ecampn02B_BundleCourseByPrefTEMP] ([CourseID]) ON [PRIMARY]
GO
