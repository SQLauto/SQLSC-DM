CREATE TABLE [Mapping].[CatalogRequestSchedule]
(
[CRWeek] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipDate] [date] NULL,
[CRCatalog] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CouponCode] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OfferAdcode] [int] NULL,
[CatalogAdcode] [int] NULL,
[CpnExpirationDate] [date] NULL,
[DataPullDate] [date] NULL
) ON [PRIMARY]
GO
