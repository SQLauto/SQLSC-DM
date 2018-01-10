CREATE TABLE [SailThru].[Message_Transactional_Updates_Files]
(
[profile_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[template] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[send_time] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[click_time] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[open_time] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[clicks url] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[clicks ts] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[opens ts] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[device] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[message_revenue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[delivery_status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Import_Datetime] [datetime] NULL,
[Import_Filename] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
