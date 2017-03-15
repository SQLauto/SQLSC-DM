CREATE TABLE [dbo].[epc_preference]
(
[preference_id] [int] NOT NULL,
[email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_date] [datetime] NULL,
[last_updated_date] [datetime] NULL,
[snooze_end_date] [datetime] NULL,
[registration_source_id] [int] NULL,
[snooze_start_date] [datetime] NULL,
[guest_key] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[store_id] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[epc_preference] ADD CONSTRAINT [PK__epc_pref__FB41DBCF45BE5BA9] PRIMARY KEY CLUSTERED  ([preference_id]) ON [PRIMARY]
GO
