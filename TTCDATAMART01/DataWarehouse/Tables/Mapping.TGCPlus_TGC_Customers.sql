CREATE TABLE [Mapping].[TGCPlus_TGC_Customers]
(
[TGCP_uuid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCP_id] [bigint] NOT NULL,
[EmailAddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MatchType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCP_IntlCampaignID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCP_RegistredDate] [date] NULL,
[TGCP_SubscribedDate] [date] NULL,
[CustomerSince] [date] NULL,
[AsOfDate] [date] NULL,
[ComboID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegmentFnl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
