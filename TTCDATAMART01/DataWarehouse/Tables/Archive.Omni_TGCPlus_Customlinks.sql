CREATE TABLE [Archive].[Omni_TGCPlus_Customlinks]
(
[Omni_TGCPlus_Customlinks_id] [int] NOT NULL IDENTITY(1, 1),
[Date] [datetime] NULL,
[MarketingCloudVisitorID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomLink] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AllVisits] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMlastupdated] [datetime] NULL CONSTRAINT [DF__Omni_TGCP__DMlas__224FF3DF] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Archive].[Omni_TGCPlus_Customlinks] ADD CONSTRAINT [PK__Omni_TGC__323D297F16521D83] PRIMARY KEY CLUSTERED  ([Omni_TGCPlus_Customlinks_id]) ON [PRIMARY]
GO
