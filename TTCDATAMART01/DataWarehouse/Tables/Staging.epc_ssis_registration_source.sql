CREATE TABLE [Staging].[epc_ssis_registration_source]
(
[registration_source_id] [int] NOT NULL,
[name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMLastupdatedDate] [datetime] NOT NULL CONSTRAINT [DF__epc_ssis___DMLas__51B8EB20] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Staging].[epc_ssis_registration_source] ADD CONSTRAINT [PK__epc_ssis__6DB1CC054FD0A2AE] PRIMARY KEY CLUSTERED  ([registration_source_id]) ON [PRIMARY]
GO
