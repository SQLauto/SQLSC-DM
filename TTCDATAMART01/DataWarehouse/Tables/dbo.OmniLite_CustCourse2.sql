CREATE TABLE [dbo].[OmniLite_CustCourse2]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateOrdered] [datetime] NULL,
[OrderSource] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderItemID] [numeric] (28, 12) NULL,
[CourseID] [int] NULL,
[StockItemID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseParts] [dbo].[udtCourseParts] NULL,
[FlagVideoDL] [tinyint] NULL,
[FlagDVD] [tinyint] NULL,
[FlagReturn] [int] NOT NULL
) ON [PRIMARY]
GO
