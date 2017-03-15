CREATE TABLE [dbo].[TGC_Plus_FBA_Combo1_20170216]
(
[CustomerID] [int] NULL,
[TGCCustFlag] [int] NOT NULL,
[CustomerSegmentFnl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Frequency] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewSeg] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[a12mf] [int] NULL,
[TGC2016Orders] [int] NOT NULL,
[TGC2016Sales] [int] NOT NULL,
[TGCP_EmailAddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCP_ID] [bigint] NULL,
[TGCP_UUID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlusCustFlag] [int] NOT NULL,
[PaidFlag] [int] NULL,
[LTDPaidAmt] [float] NULL,
[CustStatusFlag] [float] NULL,
[PaidAtleastOnce] [int] NOT NULL,
[FBACustomerid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FBACustFlag] [int] NOT NULL,
[CustGroup] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FBA_Sales] [money] NULL,
[FBA_Orders] [int] NULL
) ON [PRIMARY]
GO
