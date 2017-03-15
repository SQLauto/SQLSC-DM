CREATE TABLE [Archive].[FBA_funnel]
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
[DMLastupdated] [datetime] NULL CONSTRAINT [DF__FBA_funne__DMLas__07AB4B11] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Archive].[FBA_funnel] ADD CONSTRAINT [PK__FBA_funn__2D35F9B754450B94] PRIMARY KEY CLUSTERED  ([FBA_funnel_Id]) ON [PRIMARY]
GO
