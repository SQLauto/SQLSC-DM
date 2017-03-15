CREATE TABLE [Staging].[CC_Upsell_Items_Temp_test]
(
[Orderid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Orderitemid] [numeric] (18, 0) NULL,
[ITEMID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CrossSell] [int] NULL,
[LineType] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Quantity] [numeric] (18, 0) NULL,
[SALESPRICE] [numeric] (18, 0) NULL,
[TotalSales] [numeric] (37, 0) NULL
) ON [PRIMARY]
GO
