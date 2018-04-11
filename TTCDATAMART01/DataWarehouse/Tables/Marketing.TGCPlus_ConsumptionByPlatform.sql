CREATE TABLE [Marketing].[TGCplus_ConsumptionByPlatform]
(
[Platform] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BrowserVersion] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Browser] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategory] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FilmType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Player] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagAudio] [bit] NULL,
[FlagOffline] [bit] NULL,
[Speed] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaidFlag] [bit] NULL,
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
