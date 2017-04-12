CREATE TABLE [Staging].[XML_ssis_respondentResponse]
(
[Response_Id] [numeric] (20, 0) NULL,
[InternalRespondentId] [int] NULL,
[ResponseID] [int] NULL,
[RespondentID] [int] NULL,
[QuestionID] [int] NULL,
[SurveyID] [int] NULL,
[ColumnID] [int] NULL,
[AnswerID] [int] NULL,
[Value] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Weight] [decimal] (28, 10) NULL,
[NumericValue] [decimal] (28, 10) NULL,
[Respondent_Id] [numeric] (20, 0) NULL
) ON [PRIMARY]
GO
