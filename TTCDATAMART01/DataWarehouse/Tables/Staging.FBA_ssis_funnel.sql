CREATE TABLE [Staging].[FBA_ssis_funnel]
(
[ParentASIN] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Day] [datetime] NULL,
[ChildASIN] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Title] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sessions] [int] NULL,
[PageViews] [int] NULL,
[BuyBoxPercentage] [float] NULL,
[UnitsOrdered] [int] NULL,
[OrderedProductSales] [float] NULL,
[TotalOrderItems] [int] NULL
) ON [PRIMARY]
GO
