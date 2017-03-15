CREATE TABLE [Archive].[Snag_Series]
(
[id] [bigint] NOT NULL,
[version] [bigint] NULL,
[description] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[title] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[site_id] [bigint] NULL,
[banner_image] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mobile_image] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[poster_image] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uuid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[video_image] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[update_date] [datetime] NULL,
[DMLastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__Snag_Seri__Lastu__3C5B7982] DEFAULT (getdate()),
[course_id] [bigint] NULL
) ON [PRIMARY]
GO
