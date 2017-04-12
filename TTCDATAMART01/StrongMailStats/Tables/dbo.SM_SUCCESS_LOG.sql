CREATE TABLE [dbo].[SM_SUCCESS_LOG]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[DATESTAMP] [datetime] NULL,
[SNO] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MAILINGID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DBID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MESSAGEID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USERID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DBROWNUM] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DBNAME] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MSGSNO] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EMAIL] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VSGNAME] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OUTBOUNDIP] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MXIP] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SM_SUCCESS_LOG] ADD CONSTRAINT [PK__SM_SUCCE__3214EC27D03B1BE6] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
GRANT REFERENCES ON  [dbo].[SM_SUCCESS_LOG] TO [TEACHCO\OLTP_DATA Group]
GO
GRANT SELECT ON  [dbo].[SM_SUCCESS_LOG] TO [TEACHCO\OLTP_DATA Group]
GO
