CREATE TABLE [Staging].[XML_ssis_respondentTaskStatus]
(
[StatusID] [int] NULL,
[StatusName] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Closed] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Task_Id] [numeric] (20, 0) NULL
) ON [PRIMARY]
GO
