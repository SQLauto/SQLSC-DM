CREATE TABLE [Staging].[epc_ssis_survey_question]
(
[survey_question_id] [int] NOT NULL,
[survey_id] [int] NULL,
[reason_id] [int] NULL,
[DMLastupdatedDate] [datetime] NOT NULL CONSTRAINT [DF__epc_ssis___DMLas__5D2A9DCC] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Staging].[epc_ssis_survey_question] ADD CONSTRAINT [PK__epc_ssis__8CBDBAF85B42555A] PRIMARY KEY CLUSTERED  ([survey_question_id]) ON [PRIMARY]
GO
