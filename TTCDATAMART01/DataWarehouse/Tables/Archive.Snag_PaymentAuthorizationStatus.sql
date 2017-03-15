CREATE TABLE [Archive].[Snag_PaymentAuthorizationStatus]
(
[id] [bigint] NOT NULL,
[version] [bigint] NOT NULL,
[created_at] [datetime] NULL,
[plan_id] [bigint] NULL,
[state] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[updated_at] [datetime] NULL,
[uuid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[payment_hadler] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[subscribed_via_platform] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMLastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__Snag_Paym__Lastu__47CD2C2E] DEFAULT (getdate())
) ON [PRIMARY]
GO
