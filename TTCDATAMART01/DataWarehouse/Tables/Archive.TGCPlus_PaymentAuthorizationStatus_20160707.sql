CREATE TABLE [Archive].[TGCPlus_PaymentAuthorizationStatus_20160707]
(
[pa_id] [bigint] NULL,
[pa_user_id] [bigint] NULL,
[pas_id] [bigint] NOT NULL,
[pas_version] [bigint] NULL,
[pas_created_at] [datetime] NULL,
[pas_plan_id] [bigint] NULL,
[pas_state] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pas_updated_at] [datetime] NULL,
[pas_uuid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pas_payment_handler] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pas_subscribed_via_platform] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMLastUpdateESTDateTime] [datetime] NOT NULL
) ON [PRIMARY]
GO
