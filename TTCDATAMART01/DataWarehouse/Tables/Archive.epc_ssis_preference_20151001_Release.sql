CREATE TABLE [Archive].[epc_ssis_preference_20151001_Release]
(
[preference_id] [int] NOT NULL,
[email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_date] [datetime] NULL,
[last_updated_date] [datetime] NULL,
[snooze_end_date] [datetime] NULL,
[registration_source_id] [int] NULL,
[snooze_start_date] [datetime] NULL,
[guest_key] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMLastupdatedDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
