CREATE TABLE [Staging].[Audible_ssis_Weekly_Sales]
(
[CourseID] [float] NULL,
[ReleaseDate] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WeekEnding] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ALaCarteUnits] [float] NULL,
[ALaCarteNetPayments] [float] NULL,
[AudibleListenerUnits] [float] NULL,
[AudibleListenerNetPayments] [float] NULL,
[AudibleListenerOverPlanUnits] [float] NULL,
[AudibleListenerOverPlanNetPayments] [float] NULL
) ON [PRIMARY]
GO
