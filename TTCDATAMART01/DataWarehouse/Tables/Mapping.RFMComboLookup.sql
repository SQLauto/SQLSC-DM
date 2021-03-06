CREATE TABLE [Mapping].[RFMComboLookup]
(
[SeqNum] [int] NULL,
[RFMCells] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ComboID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [tinyint] NULL,
[CustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MultiOrSingle] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewSeg] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A12mf] [int] NULL,
[Concatenated] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Frequency] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MonetaryValue] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Recency] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegment2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegmentFnl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegment2ID] [int] NULL,
[CustomerSegmentFnlID] [int] NULL,
[CustomerSegmentFrcstID] [int] NULL
) ON [PRIMARY]
GO
