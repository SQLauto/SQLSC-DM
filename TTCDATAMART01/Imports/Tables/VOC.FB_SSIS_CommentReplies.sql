CREATE TABLE [VOC].[FB_SSIS_CommentReplies]
(
[reply_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reply_date] [datetime] NULL,
[reply_text] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[original_comment_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reply_count] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
