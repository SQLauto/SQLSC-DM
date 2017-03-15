CREATE TABLE [Staging].[epc_ssis_preference]
(
[preference_id] [int] NOT NULL,
[email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_date] [datetime] NULL,
[last_updated_date] [datetime] NULL,
[snooze_end_date] [datetime] NULL,
[registration_source_id] [int] NULL,
[snooze_start_date] [datetime] NULL,
[guest_key] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMLastupdatedDate] [datetime] NOT NULL CONSTRAINT [DF__epc_ssis___DMLas__3EA616AC] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Staging].[epc_ssis_preference] ADD CONSTRAINT [PK__epc_ssis__FB41DBCF3CBDCE3A] PRIMARY KEY CLUSTERED  ([preference_id]) ON [PRIMARY]
GO
