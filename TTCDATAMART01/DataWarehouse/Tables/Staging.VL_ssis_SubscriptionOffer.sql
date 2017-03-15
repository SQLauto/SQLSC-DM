CREATE TABLE [Staging].[VL_ssis_SubscriptionOffer]
(
[id] [bigint] NOT NULL,
[version] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[absolute_amount_off] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[campaign_type] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[offer_codes] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cookie_valid_days] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[expire] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[percentage_amount_off] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reoccuring_billing_periods] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scheduled_from_date] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scheduled_to_date] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[title] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[update_date] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uuid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[site_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[code] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[offer_strategy_type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[period_type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[period_multiplier] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
