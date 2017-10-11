CREATE TABLE [Staging].[VL_ssis_User]
(
[id] [bigint] NOT NULL,
[version] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[first_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[full_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gender] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[joined] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[large_profile_pic] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_login_date] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[original_profile_pic] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[password] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[profile_pic] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[registration_type] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[verified_email] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[parental_control_enabled] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[player_settings_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[site_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uuid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[privacy_settings_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[facebook_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[google_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[twitter_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[facebook_access_token] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[update_date] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[campaign] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[entitled_dt] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[subscription_plan_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[offer_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[offer_code_used] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[offer_applied_method] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[payment_handler] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[subscribed_via_platform] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[registered_via_platform] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email_notification] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[country_of_registration] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email_consent_visible] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
