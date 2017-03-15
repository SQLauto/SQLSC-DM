CREATE TABLE [dbo].[epc_survey]
(
[survey_id] [int] NOT NULL,
[preference_id] [int] NULL,
[created_date] [datetime] NULL,
[feedback] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[epc_survey] ADD CONSTRAINT [PK__epc_surv__9DC31A07607251E5] PRIMARY KEY CLUSTERED  ([survey_id]) ON [PRIMARY]
GO
