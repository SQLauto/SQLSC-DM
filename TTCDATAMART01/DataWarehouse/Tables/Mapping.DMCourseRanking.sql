CREATE TABLE [Mapping].[DMCourseRanking]
(
[CRCComboID] [nchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRComboID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[R3SubjectPrefRev] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Gender] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTDPurchasesBin] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseID] [numeric] (18, 0) NULL,
[Total] [money] NULL,
[Rank] [float] NULL,
[RankUpdated] [float] NULL
) ON [PRIMARY]
GO
