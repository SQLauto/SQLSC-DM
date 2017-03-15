CREATE TABLE [Staging].[EmailPullPersonalizationCourse]
(
[Customerid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SumSales] [money] NULL,
[TotalOrders] [int] NULL,
[CourseID] [int] NOT NULL,
[CourseParts] [money] NULL,
[PreferredCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Rank] [float] NULL,
[FlagPurchased] [bit] NULL,
[FlagBundle] [bit] NULL,
[CampaignExpireDate] [date] NULL,
[blnMarkdown] [tinyint] NULL,
[Message] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CLRankNum] [int] NULL
) ON [PRIMARY]
GO
