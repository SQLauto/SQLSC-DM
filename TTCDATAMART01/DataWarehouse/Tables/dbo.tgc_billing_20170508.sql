CREATE TABLE [dbo].[tgc_billing_20170508]
(
[id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[version] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_cycle_period_multiplier] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_cycle_period_type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[charged_amount_currency_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[completed_at] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pre_tax_amount] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[subscription_plan_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tax_amount] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[update_date] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[site_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uuid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tx_uuid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[service_period_from] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[service_period_to] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[payment_handler_fee] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[payment_handler] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
