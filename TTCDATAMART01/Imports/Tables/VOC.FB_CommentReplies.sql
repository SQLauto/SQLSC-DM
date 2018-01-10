CREATE TABLE [VOC].[FB_CommentReplies]
(
[FB_CommentReplies_id] [bigint] NOT NULL IDENTITY(1, 1),
[reply_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reply_date] [datetime] NULL,
[reply_text] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[original_comment_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reply_count] [int] NULL,
[DMLastupdated] [datetime] NULL CONSTRAINT [DF__FB_Commen__DMLas__1CBC4616] DEFAULT (getdate())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [VOC].[FB_CommentReplies] ADD CONSTRAINT [PK__FB_Comme__00299A6389363458] PRIMARY KEY CLUSTERED  ([FB_CommentReplies_id]) ON [PRIMARY]
GO
