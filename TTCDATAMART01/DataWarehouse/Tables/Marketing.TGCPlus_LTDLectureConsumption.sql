CREATE TABLE [Marketing].[TGCPlus_LTDLectureConsumption]
(
[Id] [bigint] NOT NULL,
[Vid] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Course_id] [bigint] NULL,
[CourseTitle] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Episode_Number] [bigint] NULL,
[LectureTitle] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Film_Type] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LectureRunMins] [numeric] (17, 6) NULL,
[StreamedMins] [numeric] (38, 1) NULL,
[Max_VPOS] [int] NULL,
[Max_VPOSMins] [numeric] (17, 6) NULL,
[StreamedMinsCapped] [numeric] (38, 1) NULL,
[FINALStreamedMins] [numeric] (38, 1) NULL,
[LastLectureActivity] [date] NULL,
[FirstLectureActivity] [date] NULL,
[FlagCompletedLecture] [int] NULL,
[LectureCompletedPrcnt] [float] NULL
) ON [PRIMARY]
GO
