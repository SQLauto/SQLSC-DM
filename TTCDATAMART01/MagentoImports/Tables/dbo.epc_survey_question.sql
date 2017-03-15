CREATE TABLE [dbo].[epc_survey_question]
(
[survey_question_id] [int] NOT NULL,
[survey_id] [int] NULL,
[reason_id] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[epc_survey_question] ADD CONSTRAINT [PK__epc_surv__8CBDBAF86442E2C9] PRIMARY KEY CLUSTERED  ([survey_question_id]) ON [PRIMARY]
GO
