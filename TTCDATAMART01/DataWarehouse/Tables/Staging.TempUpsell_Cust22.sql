CREATE TABLE [Staging].[TempUpsell_Cust22]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseID] [int] NULL,
[CourseParts] [money] NULL,
[SubjectCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreferredCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sales] [money] NULL,
[CourseSat] [float] NULL,
[SalesRank] [bigint] NULL,
[MatchPrefSubj] [int] NULL,
[Rank2] [bigint] NULL,
[Rank3] [bigint] NULL
) ON [PRIMARY]
GO
