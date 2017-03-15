CREATE TABLE [Staging].[amazon_ssis_weeklySubscription]
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
[CancelledSubscriptions] [int] NULL
) ON [PRIMARY]
GO
