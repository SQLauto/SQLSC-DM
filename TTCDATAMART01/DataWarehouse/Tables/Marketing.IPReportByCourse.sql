CREATE TABLE [Marketing].[IPReportByCourse]
(
[CourseID] [int] NULL,
[CourseName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StockItemID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MediaTypeID] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseReleaseDate] [date] NULL,
[ReportStartDate] [date] NULL,
[ReportEndDate] [date] NULL,
[Units] [int] NULL,
[Sales] [money] NULL,
[ReportRunDate] [date] NULL,
[Partner] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
