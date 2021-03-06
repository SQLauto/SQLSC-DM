CREATE TABLE [Staging].[TempFBToplineReport]
(
[ReportingStarts] [date] NULL,
[ReportingEnds] [date] NULL,
[Campaign] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdSet] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ad] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Adcode] [float] NULL,
[IPR_Channel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_Audience] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_CampaignID] [int] NULL,
[MD_Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_Year] [int] NULL,
[MD_Channel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_CampaignName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_PriceType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_PromotionType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_PromotionTypeID] [int] NULL,
[MD_ChannelID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CatalogCode] [int] NULL,
[CatalogName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdcodeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Impressions] [float] NULL,
[Reach] [int] NULL,
[Clicks] [float] NULL,
[UniqueClicks] [float] NULL,
[Actions] [float] NULL,
[AmountSpent] [float] NULL,
[Revenue_FB] [float] NULL,
[Revenue_FB_1d] [float] NULL,
[Orders_FB] [float] NULL,
[Orders_FB_1d] [float] NULL
) ON [PRIMARY]
GO
