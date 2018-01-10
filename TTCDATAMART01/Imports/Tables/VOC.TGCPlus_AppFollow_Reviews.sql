CREATE TABLE [VOC].[TGCPlus_AppFollow_Reviews]
(
[app_collection] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[app_store] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[country] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[author] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[title] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created] [datetime] NULL,
[date] [datetime] NULL,
[rating] [float] NULL,
[review_id] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[was_changed] [float] NULL,
[answer_date] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[content] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_id] [float] NULL,
[app_version] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_answer] [float] NULL,
[answer_text] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[app_ext_id] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
