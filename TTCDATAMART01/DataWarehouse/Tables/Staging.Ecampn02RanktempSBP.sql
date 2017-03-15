CREATE TABLE [Staging].[Ecampn02RanktempSBP]
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
