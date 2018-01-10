CREATE TABLE [VOC].[TGCPlus_YouTube_Comments]
(
[comment_id] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[parent_id] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[authorDisplayName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[videoId] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[textOriginal] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[viewerRating] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[likeCount] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[publishedAt] [date] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
