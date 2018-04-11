CREATE TABLE [Staging].[TGCplus_SP_Run]
(
[TGCplus_SP_Run_id] [int] NOT NULL IDENTITY(1, 1),
[ProcName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StartTime] [datetime] NULL CONSTRAINT [DF__TGCplus_S__Start__40F86F43] DEFAULT (getdate()),
[EndTime] [datetime] NULL,
[DMlastUpdated] [datetime] NULL CONSTRAINT [DF__TGCplus_S__DMlas__41EC937C] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Staging].[TGCplus_SP_Run] ADD CONSTRAINT [PK__TGCplus___48C724928EDC61BD] PRIMARY KEY CLUSTERED  ([TGCplus_SP_Run_id]) ON [PRIMARY]
GO
