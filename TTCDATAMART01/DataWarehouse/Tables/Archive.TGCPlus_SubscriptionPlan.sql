CREATE TABLE [Archive].[TGCPlus_SubscriptionPlan]
(
[id] [bigint] NOT NULL,
[version] [bigint] NULL,
[billing_cycle_period_multiplier] [int] NULL,
[billing_cycle_period_type] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[recurring_payment_amount] [real] NULL,
[recurring_payment_currency_code] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scheduled_from_date] [datetime] NULL,
[scheduled_to_date] [datetime] NULL,
[visible] [bit] NULL,
[uuid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[site_id] [bigint] NULL,
[update_date] [datetime] NULL,
[seller_note] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMLastUpdateESTDateTime] [datetime] NOT NULL CONSTRAINT [DF__TGCPlus_S__DMLas__2881CB63] DEFAULT (getdate())
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_TGCPlus_SubscriptionPlan_id] ON [Archive].[TGCPlus_SubscriptionPlan] ([id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_TGCPlus_SubscriptionPlan_uuid] ON [Archive].[TGCPlus_SubscriptionPlan] ([uuid]) ON [PRIMARY]
GO
