CREATE TABLE [Staging].[XML_ssis_RespondentTaskProperty]
(
[InternalRespondentID] [int] NULL,
[PropertyID] [int] NULL,
[PropertyName] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PropertyValue] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaskDefinition_Id] [numeric] (20, 0) NULL
) ON [PRIMARY]
GO
