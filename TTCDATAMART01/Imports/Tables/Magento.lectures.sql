CREATE TABLE [Magento].[lectures]
(
[id] [int] NOT NULL,
[product_id] [int] NOT NULL,
[audio_brightcove_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[video_brightcove_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[akamai_download_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[professor] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[original_lecture_number] [int] NULL,
[lecture_number] [int] NOT NULL,
[title] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[image] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[default_course_number] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[audio_duration] [int] NULL,
[video_duration] [int] NULL,
[audio_available] [tinyint] NOT NULL,
[video_available] [tinyint] NOT NULL,
[audio_download_filesize] [float] NULL,
[video_download_filesize_pc] [float] NULL,
[video_download_filesize_mac] [float] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
