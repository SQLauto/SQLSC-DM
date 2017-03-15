CREATE TABLE [Marketing].[SalesBycourseAll_FM_Summary]
(
[Parts] [dbo].[udtCourseParts] NULL,
[Quantity] [int] NULL,
[Sales] [money] NULL,
[CourseID] [int] NULL,
[CourseName] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseReleaseDate] [datetime] NULL,
[SubjectCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatMedia] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[YearSinceRelease] [int] NULL,
[ReleaseYear] [int] NULL
) ON [PRIMARY]
GO
