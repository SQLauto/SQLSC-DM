CREATE TABLE [Staging].[Temp_BSR_PrspctRank_USFnl]
(
[Sumsales] [money] NULL,
[TotalOrders] [int] NULL,
[CourseID] [int] NULL,
[CourseName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Parts] [dbo].[udtCourseParts] NULL,
[ReleaseDate] [datetime] NULL,
[MonthsSinceRelease] [int] NULL,
[OrdersPerMonth] [money] NULL,
[RankFnl] [bigint] NULL
) ON [PRIMARY]
GO
