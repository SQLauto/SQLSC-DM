CREATE TABLE [Archive].[Audible_Weekly_Sales]
(
[CourseID] [float] NULL,
[ReleaseDate] [date] NULL,
[WeekEnding] [date] NULL,
[ALaCarteUnits] [float] NULL,
[ALaCarteNetPayments] [float] NULL,
[AudibleListenerUnits] [float] NULL,
[AudibleListenerNetPayments] [float] NULL,
[AudibleListenerOverPlanUnits] [float] NULL,
[AudibleListenerOverPlanNetPayments] [float] NULL,
[TotalNetUnits] [float] NULL,
[TotalNetPayments] [float] NULL,
[DMLastupdated] [datetime] NULL CONSTRAINT [DF__Audible_s__DMLas__55183D72] DEFAULT (getdate())
) ON [PRIMARY]
GO
