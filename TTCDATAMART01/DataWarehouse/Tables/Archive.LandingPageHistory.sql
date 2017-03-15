CREATE TABLE [Archive].[LandingPageHistory]
(
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
[CampaignName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
