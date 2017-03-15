CREATE TABLE [Marketing].[SalesBycourseAll_FM]
(
[CourseID] [int] NULL,
[CourseName] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReleaseDate] [datetime] NULL,
[TerminationDate1] [datetime] NULL,
[TerminationDate] [datetime] NULL,
[SubjectCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatMedia] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOrdered] [smalldatetime] NULL,
[MonthOrdered] [int] NULL,
[YearOrdered] [int] NULL,
[Parts] [dbo].[udtCourseParts] NULL,
[TotalQuantity] [int] NULL,
[OrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalSales] [money] NULL,
[DaysSinceRelease] [int] NULL,
[YearSinceRelease] [int] NULL
) ON [PRIMARY]
GO
