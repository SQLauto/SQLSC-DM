CREATE TABLE [VOC].[TGCPlus_YouTube_videoDetails]
(
[videoId] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[videoTitle] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[videoDescription] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tags] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[publishedAt] [date] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
