CREATE TABLE [Mapping].[TGC_Upsell_Control_20170412_DEL]
(
[LocationID] [tinyint] NOT NULL,
[LogicID] [smallint] NOT NULL,
[TestRank] [tinyint] NOT NULL,
[IsCourseRequired] [bit] NOT NULL,
[FlagRecognized] [bit] NOT NULL,
[FlagActive] [bit] NOT NULL,
[Startdate] [date] NOT NULL,
[StopDate] [date] NOT NULL
) ON [PRIMARY]
GO
