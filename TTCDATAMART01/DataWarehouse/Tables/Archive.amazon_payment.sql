CREATE TABLE [Archive].[amazon_payment]
(
[Platform] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Category] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubscriptionName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingAmount] [float] NULL,
[Subscribers] [int] NULL,
[LicenseFee] [float] NULL,
[BadDebt] [float] NULL,
[NetRoyaltyPayment] [float] NULL,
[CaptionCost] [float] NULL,
[NetPayment] [float] NULL,
[EligibleCaptionCost] [float] NULL,
[RemainingBalance] [float] NULL,
[PaymentTerms] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaymentDate] [date] NULL,
[ReportDate] [date] NULL,
[DmLastupdated] [datetime] NULL CONSTRAINT [DF__amazon_pa__DmLas__612CA3BB] DEFAULT (getdate())
) ON [PRIMARY]
GO
