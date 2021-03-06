CREATE TABLE [dbo].[TEMP_SUCCESS]
(
[SCDATE] [datetime] NULL,
[SERIALNUMBER] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MAILINGID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATABASEID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MESSAGEID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USERID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATABASEROWNUMBER] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATABASENAME] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MESSAGESERIALNUMBER] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EMAILADDRESS] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VSGNAME] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OUTBOUNDIP] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MXIP] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT REFERENCES ON  [dbo].[TEMP_SUCCESS] TO [TEACHCO\OLTP_DATA Group]
GO
GRANT SELECT ON  [dbo].[TEMP_SUCCESS] TO [TEACHCO\OLTP_DATA Group]
GO
