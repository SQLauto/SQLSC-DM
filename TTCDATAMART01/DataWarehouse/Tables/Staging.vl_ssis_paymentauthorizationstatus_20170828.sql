CREATE TABLE [Staging].[vl_ssis_paymentauthorizationstatus_20170828]
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
[pas_subscribed_via_platform] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
