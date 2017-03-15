CREATE TABLE [Staging].[Logic2ListCourseRank]
(
[ListID] [smallint] NOT NULL,
[CourseID] [smallint] NOT NULL,
[DisplayOrder] [smallint] NOT NULL,
[UpsellCourseID] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Staging].[Logic2ListCourseRank] ADD CONSTRAINT [UC_Logic2ListCourseRank] UNIQUE NONCLUSTERED  ([ListID], [CourseID], [DisplayOrder], [UpsellCourseID]) ON [PRIMARY]
GO
ALTER TABLE [Staging].[Logic2ListCourseRank] ADD CONSTRAINT [FK_Logic2ListCourseRank_ListID] FOREIGN KEY ([ListID]) REFERENCES [Mapping].[TGC_Upsell_Logic_List] ([ListID])
GO
