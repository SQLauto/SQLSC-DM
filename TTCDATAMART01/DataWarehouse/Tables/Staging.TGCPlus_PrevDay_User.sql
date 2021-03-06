CREATE TABLE [Staging].[TGCPlus_PrevDay_User]
(
[id] [bigint] NOT NULL,
[version] [bigint] NULL,
[active] [bit] NULL,
[city] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[first_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[full_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gender] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[joined] [datetime] NULL,
[large_profile_pic] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_login_date] [datetime] NULL,
[last_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[original_profile_pic] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[password] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[profile_pic] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[registration_type] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[verified_email] [bit] NULL,
[parental_control_enabled] [bit] NULL,
[player_settings_id] [bigint] NULL,
[site_id] [bigint] NULL,
[uuid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[privacy_settings_id] [bigint] NULL,
[facebook_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[google_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[twitter_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[facebook_access_token] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[update_date] [datetime] NULL,
[campaign] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCPluscampaign] [int] NULL,
[entitled_dt] [datetime] NULL,
[subscription_plan_id] [bigint] NULL,
[offer_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[offer_code_used] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[offer_applied_method] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[payment_handler] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[subscribed_via_platform] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMLastUpdateESTDateTime] [datetime] NOT NULL,
[registered_via_platform] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VL_entitled_dt] [datetime] NULL,
[email_notification] [int] NULL,
[country_of_registration] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email_consent_visible] [int] NULL
) ON [PRIMARY]
GO
