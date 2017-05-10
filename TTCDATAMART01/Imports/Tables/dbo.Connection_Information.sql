CREATE TABLE [dbo].[Connection_Information]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[Connection_Name] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Connection_Type] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Connection_Data] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Connection_Username] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Connection_Password] [varbinary] (128) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Connection_Information] ADD CONSTRAINT [PK__Connecti__3214EC27267B8B4D] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
