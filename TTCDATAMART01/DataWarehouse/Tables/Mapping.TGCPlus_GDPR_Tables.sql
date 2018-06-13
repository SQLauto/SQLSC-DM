CREATE TABLE [Mapping].[TGCPlus_GDPR_Tables]
(
[tableName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DMLastUpdated] [datetime] NULL CONSTRAINT [DF__TGCPlus_G__DMLas__2EDF4E69] DEFAULT (getdate())
) ON [PRIMARY]
GO
