CREATE TABLE [Archive].[Omni_TGCPlus_New_Visitors]
(
[Omni_TGCPlus_ssis_New_Visitors_id] [int] NOT NULL IDENTITY(1, 1),
[Date] [datetime] NULL,
[MarketingCloudVisitorID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[utm_campaign] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UniqueVisitors] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMlastupdated] [datetime] NULL CONSTRAINT [DF__Omni_TGCP__DMlas__309E1336] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Archive].[Omni_TGCPlus_New_Visitors] ADD CONSTRAINT [PK__Omni_TGC__23A6D6F8DDE26553] PRIMARY KEY CLUSTERED  ([Omni_TGCPlus_ssis_New_Visitors_id]) ON [PRIMARY]
GO
