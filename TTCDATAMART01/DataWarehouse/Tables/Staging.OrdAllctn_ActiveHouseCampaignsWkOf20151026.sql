CREATE TABLE [Staging].[OrdAllctn_ActiveHouseCampaignsWkOf20151026]
(
[AdCode] [int] NOT NULL,
[AdcodeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AdcodeDesc] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CatalogCode] [int] NOT NULL,
[CatalogName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CatalogDesc] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OldCampaignID] [int] NULL,
[OldCampaignName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDate] [datetime] NULL,
[StopDate] [datetime] NULL,
[CurrencyCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PiecesMailed] [int] NULL,
[FixedCost] [money] NOT NULL,
[VariableCost] [money] NOT NULL,
[AdID] [int] NULL,
[CountryID] [int] NULL,
[MD_Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AudienceID] [int] NULL,
[MD_Audience] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChannelID] [int] NULL,
[MD_Channel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_PromotionTypeID] [int] NULL,
[MD_PromotionType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_CampaignID] [int] NULL,
[MD_CampaignName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_CampaignDesc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PriceTypeID] [int] NULL,
[MD_PriceType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PromotionTypeID] [smallint] NULL,
[PromotionType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_Year] [int] NULL,
[DaxPeriodCodeIsPublic] [bit] NULL,
[IPR_Channel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
