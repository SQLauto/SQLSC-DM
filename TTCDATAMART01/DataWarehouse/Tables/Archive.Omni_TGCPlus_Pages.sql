CREATE TABLE [Archive].[Omni_TGCPlus_Pages]
(
[Omni_TGCPlus_Pages_id] [int] NOT NULL IDENTITY(1, 1),
[Date] [datetime] NULL,
[MarketingCloudVisitorID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Pages] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AllVisits] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMlastupdated] [datetime] NULL CONSTRAINT [DF__Omni_TGCP__DMlas__374B10C5] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Archive].[Omni_TGCPlus_Pages] ADD CONSTRAINT [PK__Omni_TGC__C73018C297B9C503] PRIMARY KEY CLUSTERED  ([Omni_TGCPlus_Pages_id]) ON [PRIMARY]
GO
