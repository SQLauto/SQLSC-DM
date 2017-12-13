CREATE TABLE [Archive].[FBA_funnelBKPPRDEL]
(
[FBA_funnel_Id] [bigint] NOT NULL IDENTITY(1, 1),
[ASIN] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FunnelDate] [datetime] NULL,
[Title] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sessions] [int] NULL,
[PageViews] [int] NULL,
[BuyBoxPercentage] [float] NULL,
[UnitsOrdered] [int] NULL,
[OrderedProductSales] [float] NULL,
[TotalOrderItems] [int] NULL,
[DMLastupdated] [datetime] NULL
) ON [PRIMARY]
GO
