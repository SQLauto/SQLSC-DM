CREATE TABLE [dbo].[Import_Log]
(
[ID] [bigint] NOT NULL IDENTITY(1, 1),
[Operation_Date] [datetime] NULL,
[Source] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Schema_Name] [sys].[sysname] NOT NULL,
[Table_Name] [sys].[sysname] NOT NULL,
[Operation] [sys].[sysname] NOT NULL,
[Operation_Count] [int] NULL,
[After_Count] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Import_Log] ADD CONSTRAINT [PK__Import_L__3214EC2709ED5735] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
