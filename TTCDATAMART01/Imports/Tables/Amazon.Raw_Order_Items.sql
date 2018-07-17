CREATE TABLE [Amazon].[Raw_Order_Items]
(
[Amazon_Order_ID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderItemId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ASIN] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SellerSKU] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Title] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuantityOrdered] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuantityShipped] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProductInfo_NumberOfItems] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ItemPrice_Amount] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ItemPrice_CurrencyCode] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShippingPrice_Amount] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShippingPrice_CurrencyCode] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GiftWrapPrice_Amount] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GiftWrapPrice_CurrencyCode] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PromotionIds] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PromotionDiscount_Amount] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PromotionDiscount_CurrencyCode] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShippingDiscount_Amount] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShippingDiscount_CurrencyCode] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ItemTax_Amount] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ItemTax_CurrencyCode] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShippingTax_Amount] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShippingTax_CurrencyCode] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GiftWrapTax_Amount] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GiftWrapTax_CurrencyCode] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaxCollection_Model] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaxCollection_ResponsibleParty] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsGift] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GiftWrapLevel] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GiftMessageText] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[API_Log_ID] [bigint] NULL,
[Import_Timestamp] [datetime] NULL,
[TGC_Order_Type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Return_Date] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_Raw_Orders_Amazon_Order_ID] ON [Amazon].[Raw_Order_Items] ([Amazon_Order_ID], [OrderItemId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_Raw_Order_Items_TGC_Order_Type] ON [Amazon].[Raw_Order_Items] ([TGC_Order_Type]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
