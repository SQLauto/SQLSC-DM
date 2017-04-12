CREATE TABLE [Staging].[XML_ssis_respondent]
(
[Respondent_Id] [numeric] (20, 0) NULL,
[RespondentID] [int] NULL,
[KsID] [int] NULL,
[email] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ResponseLabel] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SurveyID] [int] NULL,
[KsSurveyID] [int] NULL,
[Completed] [int] NULL,
[SubmitDateTime] [datetime] NULL,
[RbrLink] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InternalNote] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalScore] [decimal] (28, 10) NULL
) ON [PRIMARY]
GO
