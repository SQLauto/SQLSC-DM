CREATE TABLE [dbo].[MktSoftBounces]
(
[Email] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SoftBounces] [int] NULL,
[FirstSoftBounceDate] [datetime] NULL,
[LastSuccessDate] [datetime] NULL,
[LastSoftBounceDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MktSoftBounces] ADD CONSTRAINT [PK_MktSoftBounces] PRIMARY KEY CLUSTERED  ([Email]) ON [PRIMARY]
GO
GRANT REFERENCES ON  [dbo].[MktSoftBounces] TO [TEACHCO\OLTP_DATA Group]
GO
GRANT SELECT ON  [dbo].[MktSoftBounces] TO [TEACHCO\OLTP_DATA Group]
GO
