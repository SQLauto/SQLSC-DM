CREATE TABLE [dbo].[CourseBacklog_Analysis_BaseTbl2]
(
[SubmitDate] [datetime] NULL,
[Qtr] [float] NULL,
[Year] [float] NULL,
[Email ] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerID] [float] NULL,
[Frequency] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastFormatWatched] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Backlog] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BacklogNumber] [float] NULL,
[BirthYear] [float] NULL,
[Gender] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Education] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CompleteFlag] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
