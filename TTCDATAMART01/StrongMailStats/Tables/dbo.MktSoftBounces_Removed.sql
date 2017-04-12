CREATE TABLE [dbo].[MktSoftBounces_Removed]
(
[RemovalKey] [int] NOT NULL IDENTITY(1, 1),
[Email] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SoftBounces] [int] NULL,
[FirstSoftBounceDate] [datetime] NULL,
[LastSuccessDate] [datetime] NULL,
[LastSoftBounceDate] [datetime] NULL,
[RemovalDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MktSoftBounces_Removed] ADD CONSTRAINT [PK__MktSoftBounces_R__173876EA] PRIMARY KEY CLUSTERED  ([RemovalKey]) ON [PRIMARY]
GO
GRANT REFERENCES ON  [dbo].[MktSoftBounces_Removed] TO [TEACHCO\OLTP_DATA Group]
GO
GRANT SELECT ON  [dbo].[MktSoftBounces_Removed] TO [TEACHCO\OLTP_DATA Group]
GO
