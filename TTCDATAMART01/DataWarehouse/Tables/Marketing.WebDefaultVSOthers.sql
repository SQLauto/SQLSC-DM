CREATE TABLE [Marketing].[WebDefaultVSOthers]
(
[Sales] [money] NULL,
[Orders] [int] NULL,
[Day] [int] NULL,
[Month] [int] NULL,
[Year] [int] NULL,
[FlagEmailOrder] [tinyint] NULL,
[FlagDefaultWeb] [int] NULL,
[FlagDefaultWebName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagVDL] [int] NOT NULL,
[ReportDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
