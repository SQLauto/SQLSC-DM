CREATE TABLE [Archive].[Omni_LC_Streaming]
(
[Omni_LC_Streaming_id] [bigint] NOT NULL IDENTITY(1, 1),
[Date] [datetime] NULL,
[userID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MobileDeviceType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MediaName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseId] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LectureNumber] [int] NULL,
[StreamedFormatType] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lecture_duration] [int] NULL,
[MediaViews] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MediaTimePlayed] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Watched25pct] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Watched50pct] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Watched75pct] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Watched95pct] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MediaCompletes] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GeoSegmentationCountries] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MarketingCloudVisitorID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rb_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Browser] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Library] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DMlastupdated] [datetime] NOT NULL CONSTRAINT [DF__Omni_LC_S__DMlas__31E5D846] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Archive].[Omni_LC_Streaming] ADD CONSTRAINT [PK__Omni_LC___6D493B139060DD78] PRIMARY KEY CLUSTERED  ([Omni_LC_Streaming_id]) ON [PRIMARY]
GO
