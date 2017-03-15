CREATE TABLE [staging].[DAX_OrderItemCreditExport]
(
[voucher] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[itemid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[creditdate] [datetime] NOT NULL,
[createdby] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[orderid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[customerid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[totalcredit] [numeric] (28, 12) NOT NULL,
[reasoncode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[reasoncodedescription] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CURRENCY] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginalOrderdate] [datetime] NULL
) ON [PRIMARY]
GO
