CREATE TABLE [Marketing].[TGCPlus_ConsumptionAll]
(
[CourseID] [int] NULL,
[Coursename] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LectureNumber] [bigint] NULL,
[LectureTitle] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FilmType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategory] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseSeconds] [bigint] NULL,
[CourseMinutes] [numeric] (26, 6) NULL,
[FlagAudio] [bit] NULL,
[FlagOffline] [bit] NULL,
[Speed] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Player] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
[MaxConsumptionDate] [date] NOT NULL,
[ReportDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
