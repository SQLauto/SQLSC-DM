CREATE TABLE [Staging].[MktCatalogCodes]
(
[CatalogCode] [int] NOT NULL,
[CampaignID] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ActiveFlag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ForecastedTotalRev] [money] NULL,
[StartDate] [datetime] NULL,
[StopDate] [datetime] NULL,
[PctCompleted] [money] NULL,
[MiscPercentage] [money] NULL,
[FulFillmentCost] [money] NULL,
[SpecialShipping] [tinyint] NULL,
[SpecialShippingCharge] [money] NULL,
[CurrencyCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DaxMktYear] [int] NULL,
[DaxMktRegion] [int] NULL,
[DaxMktTargetType] [int] NULL,
[DaxMktChannel] [int] NULL,
[DaxMktPromotionType] [int] NULL,
[DaxMktCampaign] [int] NULL,
[DaxMktPricingType] [int] NULL,
[DaxPeriodCodeIsPublic] [bit] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_MktCatalogCodes_CatalogCode] ON [Staging].[MktCatalogCodes] ([CatalogCode]) ON [PRIMARY]
GO
