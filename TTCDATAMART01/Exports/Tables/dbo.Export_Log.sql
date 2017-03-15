CREATE TABLE [dbo].[Export_Log]
(
[ID] [bigint] NOT NULL IDENTITY(1, 1),
[Operation_Date] [datetime] NOT NULL,
[Operation_Name] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Schema_Name] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Table_Name] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Destination_Name] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Export_Row_Count] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Export_Log] ADD CONSTRAINT [PK__Export_L__3214EC272346D2F3] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Export_log_Op_Schema_Date_Table] ON [dbo].[Export_Log] ([Operation_Name], [Schema_Name], [Table_Name], [Operation_Date]) ON [PRIMARY]
GO
