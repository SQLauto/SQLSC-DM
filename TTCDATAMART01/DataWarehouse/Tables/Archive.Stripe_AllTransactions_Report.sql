CREATE TABLE [Archive].[Stripe_AllTransactions_Report]
(
[userId_metadata] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created] [datetime] NULL,
[createdplus7days] [datetime] NULL,
[Finalcreated] [datetime] NULL,
[CardFunding] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CardTrials] [int] NULL,
[DMlastupdated] [datetime] NOT NULL
) ON [PRIMARY]
GO
