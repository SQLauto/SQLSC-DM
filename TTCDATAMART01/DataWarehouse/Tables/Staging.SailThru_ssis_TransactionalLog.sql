CREATE TABLE [Staging].[SailThru_ssis_TransactionalLog]
(
[Template] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Send_Time] [datetime] NULL,
[Open_Time] [datetime] NULL,
[Click_Time ] [datetime] NULL
) ON [PRIMARY]
GO
