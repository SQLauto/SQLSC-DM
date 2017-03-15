CREATE TABLE [Staging].[wpmailcourses2]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SubjectCategory2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PastOrdersBin] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseID] [int] NULL,
[Rank] [smallint] NULL,
[Gender] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRComboID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FinalRank] [int] NULL,
[CourseID2] [numeric] (18, 0) NULL,
[RankUpdated] [float] NULL,
[FinalRank2] [bigint] NULL
) ON [PRIMARY]
GO
