CREATE TABLE [Staging].[Logic_2ListCourseRank]
(
[ListID] [smallint] NOT NULL,
[CourseID] [smallint] NOT NULL,
[DisplayOrder] [smallint] NOT NULL,
[UpsellCourseID] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Staging].[Logic_2ListCourseRank] ADD CONSTRAINT [UC_Logic_2ListCourseRank] UNIQUE NONCLUSTERED  ([ListID], [CourseID], [DisplayOrder]) ON [PRIMARY]
GO
ALTER TABLE [Staging].[Logic_2ListCourseRank] ADD CONSTRAINT [FK_Logic_2ListCourseRank_ListID] FOREIGN KEY ([ListID]) REFERENCES [Mapping].[TGC_Upsell_Logic_List] ([ListID])
GO
