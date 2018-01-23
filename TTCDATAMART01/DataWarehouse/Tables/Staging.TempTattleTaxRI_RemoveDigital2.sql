CREATE TABLE [Staging].[TempTattleTaxRI_RemoveDigital2]
(
[BusinessUnit] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaxYear] [int] NULL,
[DateOrdered] [datetime] NULL,
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCPlus_CustomerID] [bigint] NULL,
[OrderID] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrencyCode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipFullName] [nvarchar] (201) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipAddress] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipAddress2] [varchar] (511) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipCity] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipRegion] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipPostalCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipCountryCode] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingName] [nvarchar] (201) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingAddress] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingAddress2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingAddress3] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingCity] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingRegion] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingPostalCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingCountryCode] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GiftFlag] [int] NULL,
[TotalSales] [real] NULL,
[TotalDiscount] [money] NULL,
[TotalShippingcharge] [money] NULL,
[TotalTax] [real] NULL,
[OrderStatus] [int] NULL,
[OrderStatusName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaymentStatus] [int] NULL,
[PaymentStatusValue] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SalesTypeID] [int] NULL,
[SalesTypeValue] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Item_SKU] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Item_Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Item_MediaType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Item_DigitalPhysical] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Item_Category] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Item_Quantity] [numeric] (28, 12) NULL,
[Item_Sales] [numeric] (28, 12) NULL,
[Item_TotalSalesPrice] [real] NULL,
[ReportDate] [datetime] NOT NULL,
[NetAmount] [real] NULL,
[NetAmountFINALOrderLevel] [real] NULL,
[TotalDigitalSalesOrderLevel] [money] NULL,
[ComboCustID] [varchar] (61) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
