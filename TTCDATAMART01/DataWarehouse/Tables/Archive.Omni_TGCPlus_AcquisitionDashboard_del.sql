CREATE TABLE [Archive].[Omni_TGCPlus_AcquisitionDashboard_del]
(
[Omni_TGCPlus_AcquisitionDashboard_id] [int] NOT NULL IDENTITY(1, 1),
[MarketingCloudVisitorID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AllVisits] [int] NULL,
[Date] [datetime] NULL,
[UniqueVisitors] [int] NULL,
[utm_campaign] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCPlusRegistration] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCPlusSubscriptionSignups] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCPlusAddtoWatchlist] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCPlusRemovefromWatchlist] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCPlusSubscriptionCancellation] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCPlusSubscriptionChangePlans] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMlastupdated] [datetime] NULL CONSTRAINT [DF__Omni_TGCP__DMlas__1E7F62FB] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Archive].[Omni_TGCPlus_AcquisitionDashboard_del] ADD CONSTRAINT [PK__Omni_TGC__23574203D77CFDBE] PRIMARY KEY CLUSTERED  ([Omni_TGCPlus_AcquisitionDashboard_id]) ON [PRIMARY]
GO
