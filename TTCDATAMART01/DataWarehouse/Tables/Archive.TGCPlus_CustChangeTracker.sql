CREATE TABLE [Archive].[TGCPlus_CustChangeTracker]
(
[AsOfDate] [date] NULL,
[CustomerID] [bigint] NULL,
[uuid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailAddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustStatusFlag] [float] NULL,
[TGCCustFlag] [int] NULL,
[PaidFlag] [int] NULL,
[DSMonthCancelled_New] [int] NULL,
[DS] [int] NULL,
[BillingRank] [bigint] NULL,
[PreferredCategory_LTD] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagChange] [int] NOT NULL
) ON [PRIMARY]
GO
