CREATE TABLE [Marketing].[TGCPlus_LTDLectureConsumption_IB]
(
[Id] [bigint] NOT NULL,
[Vid] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Course_id] [bigint] NULL,
[CourseTitle] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Episode_Number] [bigint] NULL,
[LectureTitle] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Film_Type] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategory] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LectureRunMins] [numeric] (17, 6) NULL,
[FlagAudio] [bit] NULL,
[FlagOffline] [bit] NULL,
[Speed] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Player] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[YearPlayed] [int] NULL,
[MonthPlayed] [int] NULL,
[WeekPlayed] [date] NULL,
[DatePlayed] [date] NULL,
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
