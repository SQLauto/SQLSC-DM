CREATE TABLE [Staging].[Temp_BSR_HouseRank_USFnl]
(
[Sumsales] [money] NULL,
[TotalOrders] [int] NULL,
[CourseID] [int] NULL,
[CourseName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Parts] [dbo].[udtCourseParts] NULL,
[ReleaseDate] [datetime] NULL,
[WeeksSinceRelease] [int] NULL,
[SalesPerWeek] [money] NULL,
[RankFnl] [bigint] NULL,
[WebSite] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
