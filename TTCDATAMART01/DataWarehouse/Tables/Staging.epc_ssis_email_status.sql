CREATE TABLE [Staging].[epc_ssis_email_status]
(
[recipient_failure_id] [int] NOT NULL,
[email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_date] [datetime] NULL,
[transaction_date] [datetime] NULL,
[category] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type_number] [int] NULL,
[reason] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMLastupdatedDate] [datetime] NOT NULL CONSTRAINT [DF__epc_ssis___DMLas__3057F755] DEFAULT (getdate())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Staging].[epc_ssis_email_status] ADD CONSTRAINT [PK__epc_ssis__B4816FAB2E6FAEE3] PRIMARY KEY CLUSTERED  ([recipient_failure_id]) ON [PRIMARY]
GO
