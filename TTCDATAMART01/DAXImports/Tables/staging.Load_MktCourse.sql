CREATE TABLE [staging].[Load_MktCourse]
(
[CourseID] [int] NOT NULL,
[CourseName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseDescription] [varchar] (6000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseDescriptionUpsell] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CopyrightYear] [int] NULL,
[ContentMinutes] [int] NULL,
[PublishDate] [datetime] NULL,
[CourseParts] [money] NULL,
[LectureLength] [int] NULL,
[NumLecture] [int] NULL,
[CourseTypeCode] [smallint] NULL,
[PrimarySubject] [int] NULL,
[ClearanceFlag] [bit] NULL,
[SamplesAvailable] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PackageSubject] [int] NULL
) ON [PRIMARY]
GO
