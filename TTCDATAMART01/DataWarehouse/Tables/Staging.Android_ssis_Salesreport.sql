CREATE TABLE [Staging].[Android_ssis_Salesreport]
(
[OrderNumber] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderChargedDate] [datetime] NULL,
[OrderChargedTimestamp] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FinancialStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeviceModel] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProductTitle] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProductID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProductType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SKUID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrencyofSale] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ItemPrice] [real] NULL,
[TaxesCollected] [real] NULL,
[ChargedAmount] [real] NULL,
[CityofBuyer] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StateofBuyer] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PostalCodeofBuyer] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryofBuyer] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
