CREATE TABLE [Archive].[Amazon_WeeklySubscription]
(
[Partner] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Subscription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportYear] [int] NULL,
[ReportWeek] [int] NULL,
[ReportStartDate] [date] NULL,
[ReportEndDate] [date] NULL,
[SubscriptionCategory] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ActiveSubscriptions] [int] NULL,
[NewSubscriptions] [int] NULL,
[CancelledSubscriptions] [int] NULL,
[DMLastupdated] [datetime] NULL CONSTRAINT [DF__Amazon_We__DMLas__52C28186] DEFAULT (getdate())
) ON [PRIMARY]
GO
