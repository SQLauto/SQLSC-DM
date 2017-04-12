CREATE TABLE [dbo].[tmp_AOLBounces]
(
[email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT REFERENCES ON  [dbo].[tmp_AOLBounces] TO [TEACHCO\OLTP_DATA Group]
GO
GRANT SELECT ON  [dbo].[tmp_AOLBounces] TO [TEACHCO\OLTP_DATA Group]
GO
