CREATE TABLE [dbo].[ETLErrors]
(
[ErrorDate] [datetime] NULL CONSTRAINT [DF__ETLErrors__Error__145515FA] DEFAULT (getdate()),
[TaskName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TableName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PackageName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KeyFieldName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KeyFieldValue] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorDescription] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
