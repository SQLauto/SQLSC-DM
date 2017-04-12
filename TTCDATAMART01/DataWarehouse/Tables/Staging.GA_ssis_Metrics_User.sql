CREATE TABLE [Staging].[GA_ssis_Metrics_User]
(
[Campaign] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Date] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Browser] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeviceCategory] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UUID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sessions] [int] NULL,
[New_users] [int] NULL,
[Pageviews] [int] NULL,
[Goal_1_completions_Finished_Registration] [int] NULL,
[Goal_2_completions_Signedup_For_Subscription] [int] NULL,
[Users] [int] NULL
) ON [PRIMARY]
GO
