CREATE TABLE [dbo].[epc_frequency]
(
[frequency_id] [int] NOT NULL,
[name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[epc_frequency] ADD CONSTRAINT [PK__epc_freq__F32AB2AB51300E55] PRIMARY KEY CLUSTERED  ([frequency_id]) ON [PRIMARY]
GO
