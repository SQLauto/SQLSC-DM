CREATE TABLE [Archive].[epc_ssis_survey_20151001_Release]
(
[survey_id] [int] NOT NULL,
[preference_id] [int] NULL,
[created_date] [datetime] NULL,
[feedback] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMLastupdatedDate] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
