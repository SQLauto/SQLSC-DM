CREATE TABLE [Mapping].[MktDim_Hierarchy]
(
[MD_HierarchyID] [int] NOT NULL IDENTITY(1, 1),
[MD_AudienceID] [int] NULL,
[MD_Audience_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_ChannelID] [int] NULL,
[MD_Channel_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_PromotionTypeID] [int] NULL,
[MD_PromotionType_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_CampaignID] [int] NULL,
[MD_Campaign_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagActive] [tinyint] NULL CONSTRAINT [DF__MktDim_Hi__FlagA__13D624D7] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [Mapping].[MktDim_Hierarchy] ADD CONSTRAINT [pk_MktDimHierarchy_hid] PRIMARY KEY CLUSTERED  ([MD_HierarchyID]) ON [PRIMARY]
GO
ALTER TABLE [Mapping].[MktDim_Hierarchy] ADD CONSTRAINT [fk_HierAudience_aid] FOREIGN KEY ([MD_AudienceID]) REFERENCES [Mapping].[MktDim_Audience] ([MD_AudienceID])
GO
ALTER TABLE [Mapping].[MktDim_Hierarchy] ADD CONSTRAINT [fk_HierCampaign_cid] FOREIGN KEY ([MD_CampaignID]) REFERENCES [Mapping].[MktDim_Campaign] ([MD_CampaignID])
GO
ALTER TABLE [Mapping].[MktDim_Hierarchy] ADD CONSTRAINT [fk_HierChannel_cid] FOREIGN KEY ([MD_ChannelID]) REFERENCES [Mapping].[MktDim_Channel] ([MD_ChannelID])
GO
ALTER TABLE [Mapping].[MktDim_Hierarchy] ADD CONSTRAINT [fk_HierPromotion_pid] FOREIGN KEY ([MD_PromotionTypeID]) REFERENCES [Mapping].[MktDim_PromotionType] ([MD_PromotionTypeID])
GO
