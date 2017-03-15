CREATE TABLE [Staging].[epc_ssis_survey]
(
[survey_id] [int] NOT NULL,
[preference_id] [int] NULL,
[created_date] [datetime] NULL,
[feedback] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMLastupdatedDate] [datetime] NOT NULL CONSTRAINT [DF__epc_ssis___DMLas__5865E8AF] DEFAULT (getdate())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Staging].[epc_ssis_survey] ADD CONSTRAINT [PK__epc_ssis__9DC31A07567DA03D] PRIMARY KEY CLUSTERED  ([survey_id]) ON [PRIMARY]
GO
