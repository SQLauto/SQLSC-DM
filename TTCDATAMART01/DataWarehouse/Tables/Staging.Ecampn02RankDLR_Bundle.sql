CREATE TABLE [Staging].[Ecampn02RankDLR_Bundle]
(
[SumSales] [money] NULL,
[CourseID] [int] NOT NULL,
[PreferredCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Rank] [float] NULL,
[BundleFlag] [tinyint] NULL
) ON [PRIMARY]
GO
