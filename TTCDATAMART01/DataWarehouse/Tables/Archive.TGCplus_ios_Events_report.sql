CREATE TABLE [Archive].[TGCplus_ios_Events_report]
(
[TGCplus_ios_Events_report_id] [int] NOT NULL IDENTITY(1, 1),
[ReportDate] [date] NULL,
[AppName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AppAppleID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubscriptionName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubscriptionAppleID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubscriptionGroupID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubscriptionDuration] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreservedPricing] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProceedsReason] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Client] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Device] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Country] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventDate] [datetime] NULL,
[Event] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Trial] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrialDuration] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MarketingOptIn] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MarketingOptInDuration] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ConsecutivePaidPeriods] [int] NULL,
[OriginalStartDate] [datetime] NULL,
[PreviousSubscriptionName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreviousSubscriptionAppleID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DaysBeforeCanceling] [int] NULL,
[CancellationReason] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DaysCanceled] [int] NULL,
[Quantity] [int] NULL,
[DMLastupdated] [datetime] NULL CONSTRAINT [DF__TGCplus_i__DMLas__4340789E] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Archive].[TGCplus_ios_Events_report] ADD CONSTRAINT [PK__TGCplus___47078E0830E078D5] PRIMARY KEY CLUSTERED  ([TGCplus_ios_Events_report_id]) ON [PRIMARY]
GO
