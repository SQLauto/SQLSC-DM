CREATE TABLE [Marketing].[Omni_TGC_LTDLectureDownloads]
(
[Customerid] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseID] [int] NULL,
[LectureNumber] [int] NULL,
[Downloaded] [int] NULL,
[LastLectureActivity] [date] NULL,
[FirstLectureActivity] [date] NULL,
[FlagCompletedLecture] [int] NULL,
[LectureCompletedPrcnt] [float] NULL,
[DMLastUpdated] [datetime] NOT NULL
) ON [PRIMARY]
GO
