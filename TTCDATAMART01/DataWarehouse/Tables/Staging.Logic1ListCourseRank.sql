CREATE TABLE [Staging].[Logic1ListCourseRank]
(
[ListID] [smallint] NOT NULL,
[CourseID] [smallint] NOT NULL,
[DisplayOrder] [smallint] NOT NULL,
[UpsellCourseID] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Staging].[Logic1ListCourseRank] ADD CONSTRAINT [UC_Logic1ListCourseRank] UNIQUE NONCLUSTERED  ([ListID], [CourseID], [DisplayOrder], [UpsellCourseID]) ON [PRIMARY]
GO
ALTER TABLE [Staging].[Logic1ListCourseRank] ADD CONSTRAINT [FK_Logic1ListCourseRank_ListID] FOREIGN KEY ([ListID]) REFERENCES [Mapping].[TGC_Upsell_Logic_List] ([ListID])
GO
