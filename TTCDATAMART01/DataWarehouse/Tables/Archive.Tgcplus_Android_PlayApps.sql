CREATE TABLE [Archive].[Tgcplus_Android_PlayApps]
(
[ProductTitle] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProductType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransactionDate] [datetime] NULL,
[TransactionDateTime] [datetime] NULL,
[TaxType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransactionType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RefundType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Productid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SkuId] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Hardware] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BuyerCountry] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BuyerState] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BuyerPostalCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BuyerCurrency] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AmountBuyerCurrency] [real] NULL,
[CurrencyConversionRate] [real] NULL,
[MerchanCurrency] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AmountMerchantCurrency] [real] NULL,
[DMLastUpdated] [datetime] NULL CONSTRAINT [DF__Tgcplus_A__DMLas__634333DC] DEFAULT (getdate())
) ON [PRIMARY]
GO
