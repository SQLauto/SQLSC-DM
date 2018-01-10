CREATE TABLE [Archive].[omni_TGC_Apps_Streaming]
(
[omni_TGC_Apps_Streaming_id] [bigint] NOT NULL IDENTITY(1, 1),
[Date] [date] NULL,
[userID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MobileDeviceType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MobileDevices] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MediaName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[courseid] [int] NULL,
[LectureNumber] [int] NULL,
[DeviceConnected] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MediaViews] [int] NULL,
[MediaTimePlayed] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Watched25pct] [int] NULL,
[Watched50pct] [int] NULL,
[Watched75pct] [int] NULL,
[Watched95pct] [int] NULL,
[MediaCompletes] [int] NULL,
[App] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DMlastupdated] [datetime] NULL CONSTRAINT [DF__omni_TGC___DMlas__5D718504] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Archive].[omni_TGC_Apps_Streaming] ADD CONSTRAINT [PK__omni_TGC__7F580F7FD9B45585] PRIMARY KEY CLUSTERED  ([omni_TGC_Apps_Streaming_id]) ON [PRIMARY]
GO
