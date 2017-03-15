CREATE TABLE [Staging].[MailTrackerOrders]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MatchCode] [nvarchar] (65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSince] [datetime] NULL,
[DateOrdered] [datetime] NULL,
[Adcode] [int] NULL,
[CardNum] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NetOrderAmount] [money] NULL,
[OrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdcodeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CatalogCode] [int] NOT NULL,
[CatalogName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OldCampaignID] [int] NULL,
[OldCampaignName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDate] [datetime] NULL,
[StopDate] [datetime] NULL,
[MatchCustomerid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MatchLevel] [int] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_MailTrackerOrders_1] ON [Staging].[MailTrackerOrders] ([CustomerID], [CatalogCode]) ON [PRIMARY]
GO
