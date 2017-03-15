CREATE TABLE [Staging].[Temp_BSR_HouseRank_US]
(
[Sumsales] [money] NULL,
[TotalOrders] [int] NULL,
[CourseID] [int] NULL,
[CourseName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Parts] [dbo].[udtCourseParts] NULL,
[ReleaseDate] [datetime] NULL,
[WeeksSinceRelease] [int] NULL,
[SalesPerWeek] [money] NULL
) ON [PRIMARY]
GO
