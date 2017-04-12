CREATE TABLE [Staging].[XML_ssis_Answer]
(
[AnswerID] [int] NULL,
[KsID] [int] NULL,
[QuestionID] [int] NULL,
[Weight] [decimal] (28, 10) NULL,
[Value] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumericValue] [decimal] (28, 10) NULL,
[CustomID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Question_Id] [numeric] (20, 0) NULL
) ON [PRIMARY]
GO
