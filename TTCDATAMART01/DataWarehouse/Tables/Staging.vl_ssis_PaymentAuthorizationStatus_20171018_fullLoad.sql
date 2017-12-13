CREATE TABLE [Staging].[vl_ssis_PaymentAuthorizationStatus_20171018_fullLoad]
(
[pa_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pa_user_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pas_id] [bigint] NOT NULL,
[pas_version] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pas_created_at] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pas_plan_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pas_state] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pas_updated_at] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pas_uuid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pas_payment_handler] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pas_subscribed_via_platform] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[country_of_subscription] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
