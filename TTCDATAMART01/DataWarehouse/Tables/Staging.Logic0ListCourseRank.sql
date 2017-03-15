CREATE TABLE [Staging].[Logic0ListCourseRank]
(
[ListID] [smallint] NOT NULL,
[CourseID] [smallint] NOT NULL,
[DisplayOrder] [smallint] NOT NULL,
[UpsellCourseID] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Staging].[Logic0ListCourseRank] ADD CONSTRAINT [UC_Logic0ListCourseRank] UNIQUE NONCLUSTERED  ([ListID], [CourseID], [DisplayOrder], [UpsellCourseID]) ON [PRIMARY]
GO
ALTER TABLE [Staging].[Logic0ListCourseRank] ADD CONSTRAINT [FK_Logic0ListCourseRank_ListID] FOREIGN KEY ([ListID]) REFERENCES [Mapping].[TGC_Upsell_Logic_List] ([ListID])
GO
