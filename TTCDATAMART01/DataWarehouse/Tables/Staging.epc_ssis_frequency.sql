CREATE TABLE [Staging].[epc_ssis_frequency]
(
[frequency_id] [int] NOT NULL,
[name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMLastupdatedDate] [datetime] NOT NULL CONSTRAINT [DF__epc_ssis___DMLas__351CAC72] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Staging].[epc_ssis_frequency] ADD CONSTRAINT [PK__epc_ssis__F32AB2AB33346400] PRIMARY KEY CLUSTERED  ([frequency_id]) ON [PRIMARY]
GO
