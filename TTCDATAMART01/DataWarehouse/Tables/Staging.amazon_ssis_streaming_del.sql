CREATE TABLE [Staging].[amazon_ssis_streaming_del]
(
[Partner] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportDate] [date] NULL,
[vendor_sku] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[content_type] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseID] [int] NULL,
[series_or_movie_title] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[season_number] [int] NULL,
[episode_number] [int] NULL,
[episode_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[total_number_of_streams] [float] NULL,
[total_number_of_minutes_streamed] [float] NULL
) ON [PRIMARY]
GO
