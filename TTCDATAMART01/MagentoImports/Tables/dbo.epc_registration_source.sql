CREATE TABLE [dbo].[epc_registration_source]
(
[registration_source_id] [int] NOT NULL,
[name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[epc_registration_source] ADD CONSTRAINT [PK__epc_regi__6DB1CC05498EEC8D] PRIMARY KEY CLUSTERED  ([registration_source_id]) ON [PRIMARY]
GO
