CREATE TABLE [dbo].[SM_RetryFailed_Log]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[Datestamp] [datetime] NULL,
[SNo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MailingID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DBID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MessageID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DBRowNum] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DBName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MsgSNo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Bounce] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VSGName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OutboundIP] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MXIP] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Category] [int] NULL,
[Type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Code] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SM_RetryFailed_Log] ADD CONSTRAINT [PK__SM_RetryFailed_L__023D5A04] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
GRANT REFERENCES ON  [dbo].[SM_RetryFailed_Log] TO [TEACHCO\OLTP_DATA Group]
GO
GRANT SELECT ON  [dbo].[SM_RetryFailed_Log] TO [TEACHCO\OLTP_DATA Group]
GO
