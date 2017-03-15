CREATE TABLE [Staging].[VL_ssis_PaymentAuthorizationUsedOffer]
(
[pa_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pa_user_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uso_id] [bigint] NOT NULL,
[uso_version] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uso_applied_at] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uso_offer_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uso_offer_code_applied] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uso_redeemed_at] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uso_uuid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uso_update_date] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
