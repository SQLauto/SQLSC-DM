CREATE TABLE [Archive].[TGCplus_ios_report]
(
[TGCplus_ios_report_id] [int] NOT NULL IDENTITY(1, 1),
[ReportDate] [date] NULL,
[AppName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AppAppleID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubscriptionName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubscriptionAppleID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubscriptionGroupID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubscriptionDuration] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerPrice] [money] NULL,
[CustomerCurrency] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeveloperProceeds] [money] NULL,
[ProceedsCurrency] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreservedPricing] [money] NULL,
[ProceedsReason] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Client] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Device] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Country] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ActiveSubscriptions] [int] NULL,
[ActiveFreeTrials] [int] NULL,
[MarketingOptIns] [int] NULL,
[DMlastupdated] [datetime] NULL CONSTRAINT [DF__TGCplus_i__DMlas__41D687C2] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Archive].[TGCplus_ios_report] ADD CONSTRAINT [PK__TGCplus___5F131AE8AD0FEEF5] PRIMARY KEY CLUSTERED  ([TGCplus_ios_report_id]) ON [PRIMARY]
GO
