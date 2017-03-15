CREATE TABLE [dbo].[Email_Customer_Information]
(
[subscriber_email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dax_customer_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[web_user_id] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[website_country] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[store_country] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[magento_created_date] [datetime] NULL,
[magento_last_updated_date] [datetime] NULL
) ON [PRIMARY]
GO
