CREATE TABLE [Mapping].[Date]
(
[DateID] [int] NOT NULL,
[Date] [datetime] NOT NULL,
[Year] [int] NOT NULL,
[Month] [int] NOT NULL,
[Half] [int] NOT NULL,
[Quarter] [int] NOT NULL,
[Week] [int] NOT NULL,
[WeekEnd] [int] NOT NULL,
[FlagHoliday] [int] NOT NULL,
[FlagMonthStart] [int] NOT NULL,
[FlagMonthEnd] [int] NOT NULL,
[FlagQtrStart] [int] NOT NULL,
[FlagQtrEnd] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Mapping].[Date] ADD CONSTRAINT [PK__Date__77387D06E23B8966] PRIMARY KEY CLUSTERED  ([Date]) ON [PRIMARY]
GO
