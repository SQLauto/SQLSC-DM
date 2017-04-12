CREATE TABLE [Staging].[XML_ssis_respondentResponse_errors]
(
[Response_Id] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InternalRespondentId] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ResponseID] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RespondentID] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuestionID] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SurveyID] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ColumnID] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AnswerID] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Value] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Weight] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumericValue] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Respondent_Id] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorCode] [int] NULL,
[ErrorColumn] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
