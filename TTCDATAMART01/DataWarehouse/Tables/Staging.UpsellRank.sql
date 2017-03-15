CREATE TABLE [Staging].[UpsellRank]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SubjectPreferenceID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PastOrdersBin] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseID] [int] NULL,
[Rank] [smallint] NULL
) ON [PRIMARY]
GO
