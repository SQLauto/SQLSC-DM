CREATE TABLE [Marketing].[CraftsyCusts_OverlapReport]
(
[EmailAddress] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCCustFlag] [int] NOT NULL,
[NewSeg] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[a12mf] [int] NULL,
[CustomerSegmentFnl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectPreference] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MediaFormatPreference] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderSourcePreference] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TenureDays] [int] NULL,
[LTDAvgOrd] [money] NULL,
[LTDPurchAmount] [money] NULL,
[LTDPurchases] [int] NULL,
[Gender] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AgeBin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EducationBin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HouseHoldIncomeBin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCPID] [bigint] NULL,
[FlagTGCPlusCust] [int] NOT NULL,
[TGCP_CustStatus] [varchar] (19) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaidFlag] [int] NULL,
[TGCP_LTDPaidAmt] [float] NULL,
[TGCP_SubType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateAdded] [datetime] NOT NULL
) ON [PRIMARY]
GO
