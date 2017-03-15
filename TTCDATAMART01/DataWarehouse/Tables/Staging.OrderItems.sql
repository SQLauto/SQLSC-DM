CREATE TABLE [Staging].[OrderItems]
(
[OrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderItemID] [numeric] (28, 12) NOT NULL,
[StockItemID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Quantity] [numeric] (28, 12) NOT NULL,
[SalesPrice] [numeric] (28, 12) NOT NULL,
[ShipDate] [date] NULL,
[SalesStatus] [int] NULL,
[CURRENCYCODE] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SALESTYPE] [int] NULL,
[DLVMODE] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DELIVERYNAME] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DELIVERYSTREET] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[deliverycity] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DELIVERYSTATE] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DELIVERYZIPCODE] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DELIVERYCOUNTRYREGIONID] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JSSOURCEID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JSLISTPRICE] [numeric] (28, 12) NULL,
[JSPRICEOVERRIDE] [int] NULL,
[JSREASONCODE] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JSORIGINALSALESID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LineType] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipDateGMT] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxOrderItems_StockItemID] ON [Staging].[OrderItems] ([StockItemID]) INCLUDE ([JSORIGINALSALESID], [OrderID], [OrderItemID], [Quantity], [SalesPrice]) ON [PRIMARY]
GO
