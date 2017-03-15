CREATE TABLE [Archive].[Snag_Film]
(
[id] [bigint] NOT NULL,
[version] [bigint] NULL,
[android_poster_image_url] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cue_points] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[description] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[film_type] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[geo_restrictions] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[imdb_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[log_line] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[poster_image_url] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rating] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[release_date] [datetime] NULL,
[runtime] [bigint] NULL,
[season_id] [bigint] NULL,
[seo_title] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[show_id] [bigint] NULL,
[status] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[thumbnail_url] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[title] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmdb_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[video_image_url] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[widget_image_url] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[year] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[site_id] [bigint] NULL,
[uuid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[update_date] [datetime] NULL,
[primary_category_id] [int] NOT NULL,
[DMLastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__Snag_Film__Lastu__3E43C1F4] DEFAULT (getdate()),
[episode_number] [int] NULL
) ON [PRIMARY]
GO
