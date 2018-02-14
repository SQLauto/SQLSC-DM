CREATE TABLE [Mapping].[EmailTypeConversionTable2018]
(
[CatalogCode] [int] NOT NULL,
[CatalogName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Flag_DoublePunch] [int] NOT NULL,
[EmailOfferId] [int] NULL,
[MD_PromotionTypeID] [int] NULL,
[MD_PromotionType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_CampaignId] [int] NULL,
[MD_CampaignName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
