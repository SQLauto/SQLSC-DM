CREATE TABLE [Staging].[MailTrackerOrdersByRFM]
(
[MatchCustomerid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Adcode] [int] NULL,
[AdcodeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CatalogCode] [int] NOT NULL,
[CatalogName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSince] [datetime] NULL,
[MatchLevel] [int] NULL,
[OldCampaignID] [int] NULL,
[OldCampaignName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDate] [datetime] NULL,
[StopDate] [datetime] NULL,
[SeqNum] [int] NULL,
[CustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagMailed] [int] NULL,
[MultiOrSingle] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NetOrderAmount] [money] NULL,
[OrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RFMCells] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ComboID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjRank] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_MailTrackerOrdersByRFM_1] ON [Staging].[MailTrackerOrdersByRFM] ([MatchCustomerid], [Adcode], [SeqNum], [SubjRank]) ON [PRIMARY]
GO
