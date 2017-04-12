CREATE TABLE [Archive].[SM_TRACKING_LOG]
(
[ID] [bigint] NOT NULL,
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
ALTER TABLE [Archive].[SM_TRACKING_LOG] ADD CONSTRAINT [PK__SM_TRACK__3214EC278E093FE0] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO