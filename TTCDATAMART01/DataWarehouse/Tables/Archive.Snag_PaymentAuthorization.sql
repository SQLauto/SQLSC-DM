CREATE TABLE [Archive].[Snag_PaymentAuthorization]
(
[id] [bigint] NOT NULL,
[version] [bigint] NOT NULL,
[status] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_id] [bigint] NULL,
[uuid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[next_billing_date] [datetime] NULL,
[update_date] [datetime] NULL,
[DMLastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__Snag_Paym__Lastu__4B9DBD12] DEFAULT (getdate())
) ON [PRIMARY]
GO
