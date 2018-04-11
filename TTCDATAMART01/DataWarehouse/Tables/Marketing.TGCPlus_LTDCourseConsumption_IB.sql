CREATE TABLE [Marketing].[TGCPlus_LTDCourseConsumption_IB]
(
[id] [bigint] NOT NULL,
[Course_id] [bigint] NULL,
[CourseTitle] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Film_Type] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategory] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumOfLectures] [int] NULL,
[CourseRunTime] [bigint] NULL,
[CourseRunTimeMins] [numeric] (26, 6) NULL,
[FlagAudio] [bit] NULL,
[FlagOffline] [bit] NULL,
[Speed] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Player] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[YearPlayed] [int] NULL,
[MonthPlayed] [int] NULL,
[WeekPlayed] [date] NULL,
[DatePlayed] [date] NULL,
[NumOfLecturesCompleted] [int] NULL,
[FINALStreamedMins] [numeric] (38, 1) NULL,
[LastCourseActivity] [date] NULL,
[FirstCourseActivity] [date] NULL,
[FlagCompletedCourse] [int] NULL,
[CourseCompletedPrcnt] [float] NULL
) ON [PRIMARY]
GO
