CREATE TABLE [Amazon].[Raw_Orders]
(
[AmazonOrderId] [nvarchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SellerOrderId] [nvarchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SalesChannel] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderType] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderStatus] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderTotal_Amount] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderTotal_CurrencyCode] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PurchaseDate] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EarliestShipDate] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LatestShipDate] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdateDate] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumberOfItemsShipped] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumberOfItemsUnshipped] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FulfillmentChannel] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipServiceLevel] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipmentServiceLevelCategory] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaymentMethod] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaymentMethodDetails] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MarketplaceId] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsBusinessOrder] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsPremiumOrder] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsPrime] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsReplacementOrder] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BuyerName] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BuyerEmail] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShippingAddress_Name] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShippingAddress_AddressLine1] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShippingAddress_City] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShippingAddress_StateOrRegion] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShippingAddress_PostalCode] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShippingAddress_CountryCode] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[API_Log_ID] [bigint] NULL,
[Import_Timestamp] [datetime] NULL CONSTRAINT [DF__Raw_Order__Impor__308E3499] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Amazon].[Raw_Orders] ADD CONSTRAINT [PK__Raw_Orde__3997F8F208D6FD6B] PRIMARY KEY CLUSTERED  ([AmazonOrderId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
