CREATE TABLE [Staging].[MailTrackerMailingHistory]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MatchCode] [nvarchar] (65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SeqNum] [int] NOT NULL,
[RFMCells] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ComboID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MultiOrSingle] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Adcode] [int] NOT NULL,
[AdcodeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CatalogCode] [int] NOT NULL,
[CatalogName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OldCampaignID] [int] NULL,
[OldCampaignName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjRank] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FlagMailed] [int] NULL,
[StartDate] [datetime] NULL,
[StopDate] [datetime] NULL
) ON [PRIMARY]
GO
