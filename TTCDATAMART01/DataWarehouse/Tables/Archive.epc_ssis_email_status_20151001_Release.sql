CREATE TABLE [Archive].[epc_ssis_email_status_20151001_Release]
(
[recipient_failure_id] [int] NOT NULL,
[email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_date] [datetime] NULL,
[transaction_date] [datetime] NULL,
[category] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type_number] [int] NULL,
[reason] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMLastupdatedDate] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
