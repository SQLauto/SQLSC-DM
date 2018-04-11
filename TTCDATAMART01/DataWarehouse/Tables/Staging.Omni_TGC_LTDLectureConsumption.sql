CREATE TABLE [Staging].[Omni_TGC_LTDLectureConsumption]
(
[Customerid] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseID] [int] NULL,
[LectureNumber] [int] NULL,
[Lecture_durationMins] [numeric] (16, 6) NULL,
[MediaCompleteFlag] [int] NULL,
[MaxVPosMins] [numeric] (20, 8) NULL,
[StreamedMinsCapped] [numeric] (38, 6) NULL,
[FINALStreamedMins] [numeric] (38, 6) NULL,
[TotalStreamedMins] [numeric] (38, 6) NULL,
[LastLectureActivity] [date] NULL,
[FirstLectureActivity] [date] NULL,
[FlagCompletedLecture] [int] NULL,
[LectureCompletedPrcnt] [float] NULL
) ON [PRIMARY]
GO
