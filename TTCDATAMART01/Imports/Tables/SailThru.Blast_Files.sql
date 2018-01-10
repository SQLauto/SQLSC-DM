CREATE TABLE [SailThru].[Blast_Files]
(
[name] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[link_params] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[link_params utm_source] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[link_params utm_medium] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[link_params utm_campaign] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[template] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[day] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[list_name] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[id] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Import_Datetime] [datetime] NULL,
[Import_Filename] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
