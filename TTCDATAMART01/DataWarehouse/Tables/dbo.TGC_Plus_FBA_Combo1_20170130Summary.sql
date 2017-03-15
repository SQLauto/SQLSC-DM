CREATE TABLE [dbo].[TGC_Plus_FBA_Combo1_20170130Summary]
(
[TGCCustFlag] [int] NOT NULL,
[CustomerSegmentFnl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Frequency] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewSeg] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[a12mf] [int] NULL,
[PlusCustFlag] [int] NOT NULL,
[PaidFlag] [int] NULL,
[PaidAtlestOnce] [int] NOT NULL,
[FBACustFlag] [int] NOT NULL,
[CustGroup] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustCounts] [int] NULL,
[TGCSales2016] [int] NULL,
[TGCOrders2016] [int] NULL,
[TGCP_LTDPaidAmt] [float] NULL,
[FBASalesLTD] [money] NULL,
[FBAOrdersLTD] [int] NULL
) ON [PRIMARY]
GO
