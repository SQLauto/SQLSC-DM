CREATE TABLE [Archive].[SM_AGGREGATE_LOG]
(
[ID] [bigint] NOT NULL,
[LOGTYPE] [int] NULL,
[LOGNAME] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LOGDATE] [datetime] NULL,
[SNO] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MAILINGID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DBID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MESSAGEID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USERID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DBROWNUM] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DBNAME] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MSGSNO] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EMAIL] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BOUNCE] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CATEGORY] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BOUNCETYPE] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CODE] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VSGNAME] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OUTBOUNDIP] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MXIP] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Archive].[SM_AGGREGATE_LOG] ADD CONSTRAINT [PK__SM_AGGRE__3214EC2756D05213] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
