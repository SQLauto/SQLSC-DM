CREATE TABLE [Staging].[MagentoCourseLectureExport]
(
[course_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lecture_number] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[audio_brightcove_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[video_brightcove_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[akamai_download_id] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[title] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[description] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
