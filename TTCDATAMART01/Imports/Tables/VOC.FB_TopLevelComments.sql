CREATE TABLE [VOC].[FB_TopLevelComments]
(
[FB_TopLevelComments_id] [bigint] NOT NULL IDENTITY(1, 1),
[post_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[post_text] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[comment_date] [datetime] NULL,
[comment_text] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[comment_likes] [int] NULL,
[comment_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[post_date] [datetime] NULL,
[comment_replies] [int] NULL,
[DMLastupdated] [datetime] NULL CONSTRAINT [DF__FB_TopLev__DMLas__17F790F9] DEFAULT (getdate())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [VOC].[FB_TopLevelComments] ADD CONSTRAINT [PK__FB_TopLe__225ADE191E212194] PRIMARY KEY CLUSTERED  ([FB_TopLevelComments_id]) ON [PRIMARY]
GO
