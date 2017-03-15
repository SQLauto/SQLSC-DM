CREATE TABLE [Staging].[epc_ssis_preference_history]
(
[preference_history_id] [int] NOT NULL,
[preference_id] [int] NULL,
[change_date] [datetime] NULL,
[change_type] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[change_source] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[value_old] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[value_new] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMLastupdatedDate] [datetime] NOT NULL CONSTRAINT [DF__epc_ssis___DMLas__436ACBC9] DEFAULT (getdate())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Staging].[epc_ssis_preference_history] ADD CONSTRAINT [PK__epc_ssis__DEFD93D141828357] PRIMARY KEY CLUSTERED  ([preference_history_id]) ON [PRIMARY]
GO
