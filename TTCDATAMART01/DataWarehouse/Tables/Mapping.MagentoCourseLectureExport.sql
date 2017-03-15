CREATE TABLE [Mapping].[MagentoCourseLectureExport]
(
[MediaName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseID] [int] NULL,
[LectureNum] [int] NULL,
[Title] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatType] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LectureLength] [int] NULL,
[NumLecture] [int] NULL,
[CourseParts] [dbo].[udtCourseParts] NULL
) ON [PRIMARY]
GO
