CREATE TABLE [Marketing].[CCUpsellItems]
(
[orderid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderItemid] [numeric] (18, 0) NULL,
[ITEMID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SalesStatus] [int] NULL,
[Quantity] [numeric] (18, 0) NULL,
[SALESPRICE] [money] NULL,
[CURRENCYCODE] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SALESTYPE] [int] NULL,
[JSSOURCEID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JSLISTPRICE] [money] NULL,
[JSORIGINALSALESID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LineType] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipDate] [datetime] NULL,
[CrossSell] [int] NULL
) ON [PRIMARY]
GO
