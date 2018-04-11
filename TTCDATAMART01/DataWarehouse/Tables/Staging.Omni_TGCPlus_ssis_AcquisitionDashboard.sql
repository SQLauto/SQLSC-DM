CREATE TABLE [Staging].[Omni_TGCPlus_ssis_AcquisitionDashboard]
(
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
[PageViews] [int] NULL
) ON [PRIMARY]
GO
