CREATE TABLE [Staging].[MailTrackerSales]
(
[Adcode] [int] NULL,
[AdcodeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CatalogCode] [int] NOT NULL,
[CatalogName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OldCampaignID] [int] NULL,
[OldCampaignName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDate] [datetime] NULL,
[StopDate] [datetime] NULL,
[CustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagMailed] [int] NULL,
[MultiOrSingle] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SeqNum] [int] NOT NULL,
[RFMCells] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ComboID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SubjRank] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TotalMailed] [int] NULL,
[TotalSales] [money] NULL,
[TotalOrders] [int] NULL
) ON [PRIMARY]
GO
