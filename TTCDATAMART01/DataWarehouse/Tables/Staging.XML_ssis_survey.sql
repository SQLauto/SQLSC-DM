CREATE TABLE [Staging].[XML_ssis_survey]
(
[Survey_Id] [numeric] (20, 0) NULL,
[SurveyID] [int] NULL,
[KsID] [int] NULL,
[Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SurveyURL] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDate] [datetime] NULL,
[EndDate] [datetime] NULL,
[CreateDate] [datetime] NULL
) ON [PRIMARY]
GO
