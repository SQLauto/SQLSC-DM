CREATE TABLE [Marketing].[TGCPlus_ConsumptionALL_bkp_del]
(
[CourseID] [int] NULL,
[Coursename] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LectureNumber] [int] NULL,
[LectureTitle] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FilmType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategory] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LectureSeconds] [float] NULL,
[LectureMinutes] [float] NULL,
[YearPlayed] [int] NULL,
[MonthPlayed] [int] NULL,
[WeekPlayed] [date] NULL,
[DatePlayed] [date] NULL,
[NumOfPlays] [int] NULL,
[StreamedSeconds] [float] NULL,
[StreamedMinutes] [float] NULL,
[UniqueCustcount] [int] NULL,
[AvlblSeconds] [float] NULL,
[AvlblMinutes] [float] NULL,
[MaxConsumptionDate] [datetime] NULL,
[ReportDate] [datetime] NULL
) ON [PRIMARY]
GO
