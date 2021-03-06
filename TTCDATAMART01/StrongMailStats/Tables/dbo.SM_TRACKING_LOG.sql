CREATE TABLE [dbo].[SM_TRACKING_LOG]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[DATESTAMP] [datetime] NULL,
[TTYPE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COUNTVALUE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IPADDR] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SNO] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MAILINGID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DBID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MESSAGEID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USERID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EMAIL] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LINKID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXTRA] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LINK] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FORWARDEMAIL] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SM_TRACKING_LOG] ADD CONSTRAINT [PK__SM_TRACKING_LOG__300424B4] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Tracking_Log_DateStamp] ON [dbo].[SM_TRACKING_LOG] ([DATESTAMP]) ON [PRIMARY]
GO
GRANT REFERENCES ON  [dbo].[SM_TRACKING_LOG] TO [TEACHCO\OLTP_DATA Group]
GO
GRANT SELECT ON  [dbo].[SM_TRACKING_LOG] TO [TEACHCO\OLTP_DATA Group]
GO
