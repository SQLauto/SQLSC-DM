CREATE TABLE [Archive].[TGCPlus_UserBilling_del]
(
[id] [bigint] NOT NULL,
[version] [bigint] NULL,
[billing_cycle_period_multiplier] [int] NULL,
[billing_cycle_period_type] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[charged_amount_currency_code] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[completed_at] [datetime] NULL,
[description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pre_tax_amount] [real] NULL,
[subscription_plan_id] [bigint] NULL,
[tax_amount] [real] NULL,
[user_id] [bigint] NULL,
[type] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[update_date] [datetime] NULL,
[site_id] [bigint] NULL,
[uuid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tx_uuid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[service_period_from] [datetime] NULL,
[service_period_to] [datetime] NULL,
[payment_handler_fee] [real] NULL,
[DMLastUpdateESTDateTime] [datetime] NOT NULL,
[payment_handler] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
