CREATE TABLE [dbo].[TGC_Plus_FBA_Combo1_20170216Summary]
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
[PaidAtleastOnce] [int] NOT NULL,
[FBACustFlag] [int] NOT NULL,
[CustGroup] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCPlus_CustStatusFlag] [float] NULL,
[CustCounts] [int] NULL,
[TGC2016Orders] [int] NULL,
[TGC2016Sales] [int] NULL,
[TGCPlus_LTDPaidAmt] [float] NULL,
[FBA_Orders] [int] NULL,
[FBA_Sales] [money] NULL
) ON [PRIMARY]
GO
