CREATE TABLE [Archive].[Snag_SubscriptionOffer]
(
[id] [bigint] NOT NULL,
[version] [bigint] NULL,
[absolute_amount_off] [real] NULL,
[campaign_type] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[offer_codes] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cookie_valid_days] [int] NULL,
[description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[expire] [bit] NULL,
[percentage_amount_off] [real] NULL,
[reoccuring_billing_periods] [int] NULL,
[scheduled_from_date] [datetime] NULL,
[scheduled_to_date] [datetime] NULL,
[title] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[update_date] [datetime] NULL,
[uuid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[site_id] [int] NULL,
[code] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[offer_strategy_type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[period_type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[period_multiplier] [int] NULL,
[DMLastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__Snag_Subs__Lastu__402C0A66] DEFAULT (getdate())
) ON [PRIMARY]
GO
