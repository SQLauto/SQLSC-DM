CREATE TABLE [Staging].[TGCPlus_ConsumptionByPlatform_temp]
(
[Platform] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BrowserVersion] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Browser] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategory] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryName] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[YearPlayed] [int] NULL,
[MonthPlayed] [int] NULL,
[WeekPlayed] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DatePlayed] [date] NULL,
[NumOfPlays] [int] NULL,
[StreamedSeconds] [float] NULL,
[StreamedMinutes] [float] NULL,
[UniqueCustcount] [int] NULL,
[AvlblSeconds] [float] NULL,
[AvlblMinutes] [float] NULL,
[MaxConsumptionDate] [datetime] NULL,
[ReportDate] [datetime] NULL,
[FilmType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
