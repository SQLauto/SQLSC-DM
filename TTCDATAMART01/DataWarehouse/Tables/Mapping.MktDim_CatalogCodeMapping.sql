CREATE TABLE [Mapping].[MktDim_CatalogCodeMapping]
(
[CatalogCode] [int] NOT NULL IDENTITY(1, 1),
[CatalogName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CatalogDesc] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CampaignID] [int] NULL,
[CampaignName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StartDate] [datetime] NULL,
[AdID] [int] NULL,
[DimPromotionTypeID] [int] NULL,
[DimPromtionType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MailingDescription] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Category] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_Year] [int] NULL,
[MD_Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_AudienceID] [int] NULL,
[MD_Audience_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_ChannelID] [int] NULL,
[MD_Channel_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_PromotionTypeID] [int] NULL,
[MD_PromotionType_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_CampaignID] [int] NULL,
[MD_Campaign_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_PriceTypeID] [int] NULL,
[MD_PriceType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_HIerarchyID] [int] NULL
) ON [PRIMARY]
GO
