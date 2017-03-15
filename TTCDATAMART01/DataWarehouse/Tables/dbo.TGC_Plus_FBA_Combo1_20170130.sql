CREATE TABLE [dbo].[TGC_Plus_FBA_Combo1_20170130]
(
[CustomerID] [int] NULL,
[TGCCustFlag] [int] NOT NULL,
[CustomerSegmentFnl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Frequency] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewSeg] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[a12mf] [int] NULL,
[TGCOrders2016] [int] NOT NULL,
[TGCSales2016] [int] NOT NULL,
[TGCP_EmailAddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCP_ID] [bigint] NULL,
[TGCP_UUID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlusCustFlag] [int] NOT NULL,
[PaidFlag] [int] NULL,
[LTDPaidAmt] [float] NULL,
[PaidAtlestOnce] [int] NOT NULL,
[FBACustomerid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FBACustFlag] [int] NOT NULL,
[CustGroup] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FBA_BuyerEmail] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FBAOrdersLTD] [int] NULL,
[FBASalesLTD] [money] NULL
) ON [PRIMARY]
GO
