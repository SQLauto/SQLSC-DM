CREATE TABLE [Archive].[EPC_epc_email_status_20151001]
(
[recipient_failure_id] [int] NOT NULL,
[email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_date] [datetime] NULL,
[transaction_date] [datetime] NULL,
[category] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type_number] [int] NULL,
[reason] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_id] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
