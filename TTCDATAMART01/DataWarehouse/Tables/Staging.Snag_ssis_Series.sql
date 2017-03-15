CREATE TABLE [Staging].[Snag_ssis_Series]
(
[id] [bigint] NULL,
[version] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[description] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[title] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[site_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[banner_image] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mobile_image] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[poster_image] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uuid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[video_image] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[update_date] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[course_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
