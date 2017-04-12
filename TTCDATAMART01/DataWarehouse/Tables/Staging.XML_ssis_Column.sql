CREATE TABLE [Staging].[XML_ssis_Column]
(
[Column_Id] [numeric] (20, 0) NULL,
[ColumnID] [int] NULL,
[QuestionID] [int] NULL,
[Index] [int] NULL,
[Weight] [decimal] (28, 10) NULL,
[Name] [nvarchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumericValue] [decimal] (28, 10) NULL,
[Type] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Question_Id] [numeric] (20, 0) NULL
) ON [PRIMARY]
GO
