CREATE TABLE [Staging].[FBA_ssis_funnel_1]
(
[ParentASIN] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Day] [datetime] NULL,
[ChildASIN] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Title] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sessions] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PageViews] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BuyBoxPercentage] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UnitsOrdered] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderedProductSales] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalOrderItems] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
