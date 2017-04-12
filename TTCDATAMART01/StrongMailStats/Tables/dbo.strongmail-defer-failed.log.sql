CREATE TABLE [dbo].[strongmail-defer-failed.log]
(
[Column 0] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Column 1] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT REFERENCES ON  [dbo].[strongmail-defer-failed.log] TO [TEACHCO\OLTP_DATA Group]
GO
GRANT SELECT ON  [dbo].[strongmail-defer-failed.log] TO [TEACHCO\OLTP_DATA Group]
GO
