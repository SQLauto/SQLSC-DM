CREATE TABLE [SailThru].[Message_Blast_Files]
(
[profile_id] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[send_time] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[opens ts] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[blast_id] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[message_id] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[device] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[message_revenue] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[delivery_status] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[engagement] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Optout_time] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Import_Datetime] [datetime] NULL,
[Import_Filename] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
