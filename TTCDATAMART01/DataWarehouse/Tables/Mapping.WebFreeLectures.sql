CREATE TABLE [Mapping].[WebFreeLectures]
(
[FreeLectureID] [int] NOT NULL,
[FromCourseID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FromLectureNumber] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LectureFormat] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FreeLectureLength] [int] NULL,
[DisplayLectureTitle] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FreeLectureDescription] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProfessorPhotoLink] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProfessorDisplayName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProfessorDegree] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProfessorAdditionalInfo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LectureIdentifier] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
