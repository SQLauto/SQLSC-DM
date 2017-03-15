CREATE TABLE [Archive].[epc_ssis_Soft_Bounce_20151001_Release]
(
[email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_Soft_Bounce_date] [datetime] NULL,
[Soft_Bounce_Count] [int] NULL,
[last_Email_Sent_date] [datetime] NOT NULL,
[Email_Sent_Count] [int] NULL,
[Soft_Bounce_Flag] [int] NULL
) ON [PRIMARY]
GO
