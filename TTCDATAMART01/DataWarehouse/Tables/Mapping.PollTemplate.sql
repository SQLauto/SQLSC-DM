CREATE TABLE [Mapping].[PollTemplate]
(
[BusinessUnit] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Surveytype] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Criteria] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumOfGroups] [int] NULL,
[SampleSize] [int] NULL,
[DateFilled] [date] NULL,
[DMLastUpdated] [datetime] NULL CONSTRAINT [DF__PollTempl__DMLas__33DF369E] DEFAULT (getdate())
) ON [PRIMARY]
GO
