CREATE TABLE [Archive].[TGCPlus_SubscriptionOffer]
(
[id] [bigint] NOT NULL,
[version] [bigint] NULL,
[absolute_amount_off] [real] NULL,
[campaign_type] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[offer_codes] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cookie_valid_days] [bigint] NULL,
[description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[expire] [bit] NULL,
[percentage_amount_off] [real] NULL,
[reoccuring_billing_periods] [bigint] NULL,
[scheduled_from_date] [datetime] NULL,
[scheduled_to_date] [datetime] NULL,
[title] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[update_date] [datetime] NULL,
[uuid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[site_id] [bigint] NULL,
[code] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[offer_strategy_type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[period_type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[period_multiplier] [bigint] NULL,
[DMLastUpdateESTDateTime] [datetime] NOT NULL CONSTRAINT [DF__TGCPlus_S__DMLas__23BD1646] DEFAULT (getdate())
) ON [PRIMARY]
GO
