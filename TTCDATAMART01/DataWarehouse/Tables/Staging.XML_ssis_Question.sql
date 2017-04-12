CREATE TABLE [Staging].[XML_ssis_Question]
(
[Question_Id] [numeric] (20, 0) NULL,
[QuestionID] [int] NULL,
[KsID] [int] NULL,
[Name] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SurveyID] [int] NULL,
[IsHidden] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArticleCode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AnalysisCode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataModelID] [int] NULL,
[DataModelGroupID] [int] NULL,
[Survey_Id] [numeric] (20, 0) NULL
) ON [PRIMARY]
GO
