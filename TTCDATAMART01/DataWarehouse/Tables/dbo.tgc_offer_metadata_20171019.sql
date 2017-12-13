CREATE TABLE [dbo].[tgc_offer_metadata_20171019]
(
[uuid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[title] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[display_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[expire] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cookie_valid_days] [int] NULL,
[strategy_type] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[period_type] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[period_multiplier] [int] NULL,
[percentage_amount_off] [real] NULL,
[absolute_amount_ff] [real] NULL,
[offer_limit_type] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[single_user_number_of_coupons] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[single_use_code_prefix] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[application_limit] [int] NULL,
[single_use_coupon_codes] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[offer_codes] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer_types] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scheduled_from_date] [datetime] NULL,
[scheduled_to_date] [datetime] NULL
) ON [PRIMARY]
GO
