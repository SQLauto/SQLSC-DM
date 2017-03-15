CREATE TABLE [Archive].[epc_ssis_preference_history_20151001_Release]
(
[preference_history_id] [int] NOT NULL,
[preference_id] [int] NULL,
[change_date] [datetime] NULL,
[change_type] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[change_source] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[value_old] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[value_new] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMLastupdatedDate] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
