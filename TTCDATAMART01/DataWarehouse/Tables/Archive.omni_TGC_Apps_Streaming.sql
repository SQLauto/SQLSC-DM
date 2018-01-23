CREATE TABLE [Archive].[omni_TGC_Apps_Streaming]
(
[omni_TGC_Apps_Streaming_id] [bigint] NOT NULL IDENTITY(1, 1),
[Date] [date] NULL,
[userID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MobileDeviceType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MobileDevice] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MediaName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[courseid] [int] NULL,
[LectureNumber] [int] NULL,
[DeviceConnected] [bit] NULL,
[MediaViews] [int] NULL,
[MediaTimePlayed] [int] NULL,
[Watched25pct] [int] NULL,
[Watched50pct] [int] NULL,
[Watched75pct] [int] NULL,
[Watched95pct] [int] NULL,
[MediaCompletes] [int] NULL,
[App] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AppId] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lecture_duration] [int] NULL,
[GeoSegmentationCountries] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMlastupdated] [datetime] NULL CONSTRAINT [DF__omni_TGC___DMlas__7C0BE614] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Archive].[omni_TGC_Apps_Streaming] ADD CONSTRAINT [PK__omni_TGC__7F580F7FE39A14A9] PRIMARY KEY CLUSTERED  ([omni_TGC_Apps_Streaming_id]) ON [PRIMARY]
GO
