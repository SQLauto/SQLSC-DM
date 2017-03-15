CREATE TABLE [dbo].[donotuse_WebAcctInfo_Final]
(
[email] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[_website] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[_store] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[website_id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[store_id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_in] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prefix] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[firstname] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[middlename] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastname] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[suffix] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[group_id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dob] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[password_hash] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[taxvat] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[confirmation] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_at] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gender] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rp_token] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rp_token_created_at] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[disable_auto_group_change] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reward_update_notification] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reward_warning_notification] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dax_customer_id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[datamart_customer_pref] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[web_user_id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lock_expires] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[num_failures] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_prospect] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[free_lecture_prospect] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[audio_format] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[video_format] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[signup_ad_code] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[signup_user_agent] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dax_customer_created_uctime] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[new_customer_sent_to_dax] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[new_customer_confirmed_by_dax] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dax_address_record] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[web_prospect_id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[free_lectures_date_collected] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[free_lect_last_date_collected] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[free_lectures_initial_source] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[free_lect_initial_user_agent] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email_verified] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_verified] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[confirmation_guid] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_account_at_signup] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[username] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_freelect_prospect_confirmed] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[free_lect_email_failed] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[free_lect_date_unsubscribed] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[updated_at] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[free_lect_subscribe_status] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[password] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[_address_city] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[_address_company] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[_address_country_id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[_address_fax] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[_address_firstname] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[_address_lastname] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[_address_middlename] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[_address_postcode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[_address_prefix] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[_address_region] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[_address_street] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[_address_suffix] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[_address_telephone] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[_address_vat_id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[_address_default_billing_] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[_address_default_shipping_] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateAdded] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_WebAcctInfo_Email] ON [dbo].[donotuse_WebAcctInfo_Final] ([email]) ON [PRIMARY]
GO
