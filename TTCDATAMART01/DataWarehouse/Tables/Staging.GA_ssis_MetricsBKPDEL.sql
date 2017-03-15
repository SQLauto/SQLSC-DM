CREATE TABLE [Staging].[GA_ssis_MetricsBKPDEL]
(
[Campaign] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Date] [date] NULL,
[Sessions] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[New_users] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Pageviews] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Goal_1_completions_Finished_Registration] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Goal_2_completions_Signedup_For_Subscription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
