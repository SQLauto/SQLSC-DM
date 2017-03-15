CREATE TABLE [Mapping].[DMDates]
(
[DateID] [int] NOT NULL IDENTITY(1, 1),
[MktDate] [smalldatetime] NOT NULL,
[YearNum] [int] NOT NULL CONSTRAINT [DF_MktDateOrdered_YearNum] DEFAULT ((0)),
[HalfYearNum] [tinyint] NOT NULL CONSTRAINT [DF_MktDateOrdered_SemesterNum] DEFAULT ((0)),
[QuarterNum] [tinyint] NOT NULL CONSTRAINT [DF_MktDateOrdered_QuarterNum] DEFAULT ((0)),
[MonthNum] [tinyint] NOT NULL CONSTRAINT [DF_MktDateOrdered_MonthNum] DEFAULT ((0)),
[WeekNum] [tinyint] NOT NULL CONSTRAINT [DF_MktDateOrdered_WeekNum] DEFAULT ((0)),
[FlagWeekEnd] [tinyint] NOT NULL CONSTRAINT [DF_MktDateOrdered_FlagWeekEnd] DEFAULT ((0)),
[FlagHoliday] [tinyint] NOT NULL CONSTRAINT [DF_MktDateOrdered_FlagHoliday] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [Mapping].[DMDates] ADD CONSTRAINT [PK_MktDateOrdered] PRIMARY KEY NONCLUSTERED  ([DateID]) ON [PRIMARY]
GO
