CREATE TABLE [Staging].[Tmp_MergeSource]
(
[DoNotMerge] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[First NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Last NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADDR 1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADDR 2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CITY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STATE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZIP CODE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ACCOUNT NUMBER] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DUPE SEQUENCE] [float] NULL
) ON [PRIMARY]
GO
