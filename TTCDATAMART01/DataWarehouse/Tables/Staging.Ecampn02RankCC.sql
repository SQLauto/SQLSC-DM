CREATE TABLE [Staging].[Ecampn02RankCC]
(
[SumSales] [money] NULL,
[CourseID] [int] NOT NULL,
[PreferredCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Rank] [float] NULL,
[SubjectCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagOnSale] [int] NOT NULL
) ON [PRIMARY]
GO
