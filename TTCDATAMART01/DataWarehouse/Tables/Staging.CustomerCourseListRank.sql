CREATE TABLE [Staging].[CustomerCourseListRank]
(
[SumSales] [money] NULL,
[TotalOrders] [int] NULL,
[CourseID] [int] NOT NULL,
[CourseParts] [money] NULL,
[PreferredCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Rank] [float] NULL,
[FlagPurchased] [bit] NULL,
[FlagBundle] [bit] NULL,
[Customerid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseListRank] [int] NULL
) ON [PRIMARY]
GO
