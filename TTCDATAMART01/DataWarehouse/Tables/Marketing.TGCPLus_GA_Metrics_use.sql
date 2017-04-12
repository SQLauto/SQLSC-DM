CREATE TABLE [Marketing].[TGCPLus_GA_Metrics_use]
(
[Campaign] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATE] [date] NULL,
[uuid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[browser] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeviceCategory] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sessions] [int] NULL,
[New_users] [int] NULL,
[Pageviews] [int] NULL,
[Goal_1_completions_Finished_Registration] [int] NULL,
[Goal_2_completions_Signedup_For_Subscription] [int] NULL,
[AllUsers] [int] NULL
) ON [PRIMARY]
GO
