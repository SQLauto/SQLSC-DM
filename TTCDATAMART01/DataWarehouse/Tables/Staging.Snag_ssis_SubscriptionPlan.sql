CREATE TABLE [Staging].[Snag_ssis_SubscriptionPlan]
(
[id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[version] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_cycle_period_multiplier] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_cycle_period_type] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[recurring_payment_amount] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[recurring_payment_currency_code] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scheduled_from_date] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scheduled_to_date] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[visible] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uuid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[site_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[update_date] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[seller_note] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
