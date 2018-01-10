CREATE TABLE [VOC].[FB_SSIS_TopLevelComments]
(
[post_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[post_text] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[comment_date] [datetime] NULL,
[comment_text] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[comment_likes] [int] NULL,
[comment_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[post_date] [datetime] NULL,
[comment_replies] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
