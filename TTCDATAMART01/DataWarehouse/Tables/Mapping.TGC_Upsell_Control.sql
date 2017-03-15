CREATE TABLE [Mapping].[TGC_Upsell_Control]
(
[LocationID] [tinyint] NOT NULL,
[LogicID] [smallint] NOT NULL,
[TestRank] [tinyint] NOT NULL,
[IsCourseRequired] [bit] NOT NULL CONSTRAINT [DF__TGC_Upsel__IsCou__5ABC6FF2] DEFAULT ((0)),
[FlagRecognized] [bit] NOT NULL CONSTRAINT [DF__TGC_Upsel__FlagR__5BB0942B] DEFAULT ((0)),
[FlagActive] [bit] NOT NULL CONSTRAINT [DF__TGC_Upsel__FlagA__5CA4B864] DEFAULT ((0)),
[Startdate] [date] NOT NULL,
[StopDate] [date] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Mapping].[TGC_Upsell_Control] ADD CONSTRAINT [UC_TGC_Upsell_Control] UNIQUE NONCLUSTERED  ([LocationID], [LogicID], [TestRank], [FlagActive]) ON [PRIMARY]
GO
ALTER TABLE [Mapping].[TGC_Upsell_Control] ADD CONSTRAINT [FK_TGC_Upsell_Control_LocationID] FOREIGN KEY ([LocationID]) REFERENCES [Mapping].[TGC_Upsell_Location] ([LocationID])
GO
ALTER TABLE [Mapping].[TGC_Upsell_Control] ADD CONSTRAINT [FK_TGC_Upsell_Control_LogicID] FOREIGN KEY ([LogicID]) REFERENCES [Mapping].[TGC_Upsell_Logic] ([LogicID])
GO
