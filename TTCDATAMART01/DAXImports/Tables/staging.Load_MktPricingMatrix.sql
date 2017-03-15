CREATE TABLE [staging].[Load_MktPricingMatrix]
(
[CatalogCode] [int] NOT NULL,
[UserStockItemID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StockItemID] [int] NULL,
[UnitPrice] [money] NOT NULL,
[PageAllocation] [smallint] NULL,
[UnitCurrency] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
