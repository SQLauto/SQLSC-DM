CREATE TABLE [Archive].[Amazon_streaming]
(
[Partner] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportDate] [date] NULL,
[vendor_sku] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[content_type] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReleaseDate] [date] NULL,
[AvailableDate] [date] NULL,
[CourseID] [int] NULL,
[series_or_movie_title] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[season_number] [int] NULL,
[episode_number] [int] NULL,
[episode_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[total_number_of_streams] [float] NULL,
[total_number_of_minutes_streamed] [float] NULL,
[Average_minutes_streamed] [float] NULL,
[DMLastUpdated] [datetime] NULL CONSTRAINT [DF__Amazon_st__DMLas__771F1236] DEFAULT (getdate())
) ON [PRIMARY]
GO
