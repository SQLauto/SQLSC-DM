CREATE TABLE [Staging].[Logic3ListCourseRank]
(
[ListID] [smallint] NOT NULL,
[CourseID] [smallint] NOT NULL,
[DisplayOrder] [smallint] NOT NULL,
[UpsellCourseID] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Staging].[Logic3ListCourseRank] ADD CONSTRAINT [UC_Logic3ListCourseRank] UNIQUE NONCLUSTERED  ([ListID], [CourseID], [DisplayOrder]) ON [PRIMARY]
GO
ALTER TABLE [Staging].[Logic3ListCourseRank] ADD CONSTRAINT [FK_Logic3ListCourseRank_ListID] FOREIGN KEY ([ListID]) REFERENCES [Mapping].[TGC_Upsell_Logic_List] ([ListID])
GO
