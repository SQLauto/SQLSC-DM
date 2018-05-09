CREATE TABLE [staging].[DAX_OrderItemExport_bryantj_3inserts]
(
[orderid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderItemid] [numeric] (28, 12) NOT NULL,
[ITEMID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SalesStatus] [int] NOT NULL,
[Quantity] [numeric] (28, 12) NOT NULL,
[SALESPRICE] [numeric] (28, 12) NOT NULL,
[CURRENCYCODE] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SALESTYPE] [int] NOT NULL,
[DLVMODE] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DELIVERYNAME] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DELIVERYSTREET] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[deliverycity] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DELIVERYSTATE] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DELIVERYZIPCODE] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DELIVERYCOUNTRYREGIONID] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JSSOURCEID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JSLISTPRICE] [numeric] (28, 12) NOT NULL,
[JSPRICEOVERRIDE] [int] NOT NULL,
[JSREASONCODE] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JSORIGINALSALESID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LineType] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Shipdate] [datetime] NULL,
[CrossSell] [int] NULL
) ON [PRIMARY]
GO
