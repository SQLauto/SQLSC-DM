CREATE TABLE [Archive].[Omni_TGCPlus_MCID_UUID_Mapping]
(
[Omni_TGCPlus_MCID_UUID_Mapping_id] [int] NOT NULL IDENTITY(1, 1),
[MarketingCloudVisitorID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCPlusUserID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AllVisits] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMlastupdated] [datetime] NULL CONSTRAINT [DF__Omni_TGCP__DMlas__262084C3] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Archive].[Omni_TGCPlus_MCID_UUID_Mapping] ADD CONSTRAINT [PK__Omni_TGC__D17A5960119EDB66] PRIMARY KEY CLUSTERED  ([Omni_TGCPlus_MCID_UUID_Mapping_id]) ON [PRIMARY]
GO
