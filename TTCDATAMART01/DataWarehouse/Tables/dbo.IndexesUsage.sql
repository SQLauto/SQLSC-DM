CREATE TABLE [dbo].[IndexesUsage]
(
[IndexName] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UsedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IndexesUsage] ADD CONSTRAINT [PK__IndexesU__CFC27E322A6E744B] PRIMARY KEY CLUSTERED  ([IndexName]) ON [PRIMARY]
GO
