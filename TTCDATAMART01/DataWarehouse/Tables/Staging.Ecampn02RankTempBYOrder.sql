CREATE TABLE [Staging].[Ecampn02RankTempBYOrder]
(
[SumSales] [money] NULL,
[TotalOrders] [int] NULL,
[CourseID] [int] NOT NULL,
[PreferredCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Rank] [float] NULL
) ON [PRIMARY]
GO
