CREATE TABLE [dbo].[TEMP_AUXTRACKING]
(
[TRDATE] [datetime] NULL,
[TTYPE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COUNTVALUE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IPADDRESS] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SERIALNUMBER] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MAILINGID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATABASEID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MESSAGEID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USERID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EMAILADDRESS] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LINKID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXTRA] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LINK] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FORWARDEMAIL] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FORWARDLEVEL] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT REFERENCES ON  [dbo].[TEMP_AUXTRACKING] TO [TEACHCO\OLTP_DATA Group]
GO
GRANT SELECT ON  [dbo].[TEMP_AUXTRACKING] TO [TEACHCO\OLTP_DATA Group]
GO
