CREATE TABLE [dbo].[epc_preference_history]
(
[preference_history_id] [bigint] NOT NULL,
[preference_id] [int] NULL,
[change_date] [datetime] NULL,
[change_type] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[change_source] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[value_old] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[value_new] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[epc_preference_history] ADD CONSTRAINT [PK__epc_pref__DEFD93D16BE40491] PRIMARY KEY CLUSTERED  ([preference_history_id]) ON [PRIMARY]
GO
