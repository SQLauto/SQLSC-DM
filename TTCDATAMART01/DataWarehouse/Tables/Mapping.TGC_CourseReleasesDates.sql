CREATE TABLE [Mapping].[TGC_CourseReleasesDates]
(
[BU] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[courseid] [bigint] NULL,
[ReleaseDate] [date] NULL,
[DMLastUpdated] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Mapping].[TGC_CourseReleasesDates] ADD CONSTRAINT [BU_CourseRelease] UNIQUE NONCLUSTERED  ([BU], [courseid]) ON [PRIMARY]
GO
