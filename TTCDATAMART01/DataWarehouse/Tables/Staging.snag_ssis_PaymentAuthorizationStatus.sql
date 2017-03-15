CREATE TABLE [Staging].[snag_ssis_PaymentAuthorizationStatus]
(
[id] [bigint] NULL,
[version] [bigint] NULL,
[created_at] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[plan_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[updated_at] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uuid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[payment_hadler] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[subscribed_via_platform] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
