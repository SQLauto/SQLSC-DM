CREATE TABLE [Staging].[XML_ssis_respondentTask]
(
[Task_Id] [numeric] (20, 0) NULL,
[TaskID] [int] NULL,
[TaskSummary] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaskDescription] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaskDueDate] [datetime] NULL,
[TaskResponsiblePartyID] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaskResponsiblePartyName] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaskCreatedByID] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaskCreatedByName] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaskDefinition_Id] [numeric] (20, 0) NULL
) ON [PRIMARY]
GO
