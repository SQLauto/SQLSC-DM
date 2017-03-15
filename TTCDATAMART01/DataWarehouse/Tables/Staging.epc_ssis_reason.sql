CREATE TABLE [Staging].[epc_ssis_reason]
(
[reason_id] [int] NOT NULL,
[name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMLastupdatedDate] [datetime] NOT NULL CONSTRAINT [DF__epc_ssis___DMLas__4CF43603] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Staging].[epc_ssis_reason] ADD CONSTRAINT [PK__epc_ssis__846BB5544B0BED91] PRIMARY KEY CLUSTERED  ([reason_id]) ON [PRIMARY]
GO
