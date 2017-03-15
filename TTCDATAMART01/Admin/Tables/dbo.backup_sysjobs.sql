CREATE TABLE [dbo].[backup_sysjobs]
(
[name] [sys].[sysname] NOT NULL,
[enabled] [tinyint] NOT NULL,
[servername] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
