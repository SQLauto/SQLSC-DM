CREATE TABLE [Staging].[Omni_TGC_LTDCourseDownloads]
(
[Customerid] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Courseid] [int] NULL,
[NumOfLectures] [int] NULL,
[CourseRunTime] [int] NULL,
[CourseRunTimeMins] [numeric] (17, 6) NULL,
[NumOfLecturesCompleted] [int] NULL,
[LastCourseActivity] [date] NULL,
[FirstCourseActivity] [date] NULL,
[FlagCompletedCourse] [int] NULL,
[CourseCompletedPrcnt] [float] NULL
) ON [PRIMARY]
GO
