CREATE TABLE [Staging].[MktCourse]
(
[CourseID] [int] NOT NULL,
[CourseName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseDescription] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseDescriptionUpsell] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CopyrightYear] [int] NULL,
[ContentMinutes] [int] NULL,
[PublishDate] [datetime] NULL,
[CourseParts] [dbo].[udtCourseParts] NULL,
[LectureLength] [int] NULL,
[NumLecture] [int] NULL,
[CourseTypeCode] [smallint] NULL,
[PrimarySubject] [int] NULL,
[ClearanceFlag] [bit] NULL,
[SamplesAvailable] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PackageSubject] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_MktCourse_CourseID] ON [Staging].[MktCourse] ([CourseID]) INCLUDE ([CourseParts], [PublishDate]) ON [PRIMARY]
GO
