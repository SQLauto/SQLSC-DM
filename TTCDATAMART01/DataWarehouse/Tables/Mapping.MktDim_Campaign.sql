CREATE TABLE [Mapping].[MktDim_Campaign]
(
[MD_CampaignID] [int] NOT NULL IDENTITY(1, 1),
[MD_Campaign] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_Campaign_Description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagActive] [tinyint] NULL CONSTRAINT [DF__MktDim_Ca__FlagA__782E0A62] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [Mapping].[MktDim_Campaign] ADD CONSTRAINT [pk_Campaign_cid] PRIMARY KEY CLUSTERED  ([MD_CampaignID]) ON [PRIMARY]
GO
ALTER TABLE [Mapping].[MktDim_Campaign] ADD CONSTRAINT [uc_MktDimCampaign_Campaign] UNIQUE NONCLUSTERED  ([MD_Campaign], [MD_Campaign_Description]) ON [PRIMARY]
GO
