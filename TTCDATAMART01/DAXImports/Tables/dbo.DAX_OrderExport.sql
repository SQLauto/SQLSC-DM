CREATE TABLE [dbo].[DAX_OrderExport]
(
[orderid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Customerid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[InvoiceAccount] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[deliveryMode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderStatus] [int] NOT NULL,
[SalesType] [int] NOT NULL,
[CURRENCYCODE] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ShipToName] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ShiptoAddress] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ShipToCity] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ShipToState] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ShipToZip] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ShipToCountryCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderChannel] [int] NOT NULL,
[Ordersource] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SourceCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CUSTGROUP] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MultipleDeliveries] [int] NULL,
[Orderdate] [datetime] NOT NULL,
[csrid] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedDate] [datetime] NOT NULL,
[modifiedby] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TotalMerchandise] [money] NULL,
[TotalTaxes] [money] NULL,
[TotalShipping] [money] NULL,
[TotalCoupons] [money] NULL,
[OtherCharges] [money] NULL,
[BillingName] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BillingAddress1] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BillingAddress2] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BillingAddress3] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BillingCity] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BillingState] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BillingZip] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BillingCountryCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WebOrderID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[jsGiftFlag] [int] NULL,
[jsGiftMessage] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaxGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PurchID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[jsDeliveryPhone] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[jsShipComplete] [int] NULL,
[AffiliateSubID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [OrderExport_DateOrdered] ON [dbo].[DAX_OrderExport] ([Orderdate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [OrderExport_Orderid] ON [dbo].[DAX_OrderExport] ([orderid]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[DAX_OrderExport] TO [TEACHCO\nareddys]
GO
