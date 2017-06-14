CREATE TABLE [Archive].[Stripe_Failures_Report]
(
[userId_metadata] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created] [datetime] NULL,
[createdplus7days] [datetime] NULL,
[Finalcreated] [datetime] NULL,
[CardFunding] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CardTrials] [int] NULL,
[Status] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[userid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeclinedDate] [datetime] NULL,
[Nextretrydate] [datetime] NULL,
[Originalbillingdate] [datetime] NULL,
[Retry] [int] NULL,
[Complete] [int] NULL,
[Failed] [int] NULL,
[DunningCompleted] [varchar] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DMLastupdated] [datetime] NULL CONSTRAINT [DF__Stripe_Fa__DMLas__0E3F731E] DEFAULT (getdate())
) ON [PRIMARY]
GO
