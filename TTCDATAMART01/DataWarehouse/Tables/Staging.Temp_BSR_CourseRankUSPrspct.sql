CREATE TABLE [Staging].[Temp_BSR_CourseRankUSPrspct]
(
[SumSales] [money] NULL,
[TotalOrders] [int] NULL,
[CourseID] [int] NULL,
[CourseName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Parts] [dbo].[udtCourseParts] NULL,
[ReleaseDate] [datetime] NULL
) ON [PRIMARY]
GO
