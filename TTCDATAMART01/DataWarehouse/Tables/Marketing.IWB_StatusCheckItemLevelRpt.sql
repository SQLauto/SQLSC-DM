CREATE TABLE [Marketing].[IWB_StatusCheckItemLevelRpt]
(
[YearOrdered] [int] NULL,
[MonthOrdered] [int] NULL,
[WeekOf] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingCountryCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ShipToCountryCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CurrencyCode] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderStatus] [int] NOT NULL,
[OrderStatusDescription] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ordersource] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Adcode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AdcodeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CatalogCode] [int] NULL,
[CatalogName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ItemID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FlagNewCust] [int] NOT NULL,
[OrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
