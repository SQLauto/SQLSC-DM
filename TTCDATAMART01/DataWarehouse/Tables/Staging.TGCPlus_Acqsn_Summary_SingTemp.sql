CREATE TABLE [Staging].[TGCPlus_Acqsn_Summary_SingTemp]
(
[ActivityYear] [int] NULL,
[ActivityMonth] [int] NULL,
[ActivityWeek] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ActivityDate] [date] NULL,
[IntlCampaign] [int] NULL,
[IntlCampaignName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlCamapaignOfferCode] [int] NULL,
[IntlCamapaignOfferName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlMD_Audience] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlMD_Year] [int] NULL,
[IntlMD_ChannelID] [int] NULL,
[IntlMD_Channel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlMD_PromotionTypeID] [int] NULL,
[IntlMD_PromotionType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlMD_CampaignID] [int] NULL,
[IntlMD_CampaignName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Intl_Cmpn_StartDate] [datetime] NULL,
[Intl_Cmpn_StopDate] [datetime] NULL,
[UTM_CampaignName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UTM_Medium] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UTM_Source] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DM_Subscribers] [int] NULL,
[TGCCustCountSUB] [int] NULL,
[NonTGCCustCountSUB] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
