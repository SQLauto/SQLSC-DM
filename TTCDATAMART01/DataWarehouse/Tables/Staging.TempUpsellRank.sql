CREATE TABLE [Staging].[TempUpsellRank]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SubjectPreferenceID] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PastOrdersBin] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Courseid] [int] NOT NULL,
[Rank] [int] NULL
) ON [PRIMARY]
GO
