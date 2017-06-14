CREATE TABLE [dbo].[TGC_Plus_FBA_Combo1_20170427Summary]
(
[TGCCustFlag] [int] NOT NULL,
[CustomerSegmentFnl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Frequency] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewSeg] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[a12mf] [int] NULL,
[TGCCountry] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCFlagIntrntnl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlusCustFlag] [int] NOT NULL,
[PaidFlag] [int] NULL,
[PaidAtleastOnce] [int] NOT NULL,
[TGCP_Country] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCP_FlagIntrntnl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FBACustFlag] [int] NOT NULL,
[FBACountry] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FBAFlagIntntnl] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustGroup] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCPlus_CustStatusFlag] [float] NULL,
[CustCounts] [int] NULL,
[TGC2016Orders] [int] NULL,
[TGC2016Sales] [int] NULL,
[TGCPlus_PlusPayment_2016] [float] NULL,
[FBA_Orders2016] [int] NULL,
[FBA_Sales2016] [money] NULL
) ON [PRIMARY]
GO
