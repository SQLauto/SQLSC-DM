CREATE TABLE [Archive].[omni_TGC_Apps_Downloads]
(
[omni_TGC_Apps_Downloads_id] [bigint] NOT NULL IDENTITY(1, 1),
[Date] [date] NULL,
[userID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MobileDeviceType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MobileDevice] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MediaName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[courseid] [int] NULL,
[LectureNumber] [int] NULL,
[App] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AppId] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DownloadedFormatType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lecture_duration] [int] NULL,
[GeoSegmentationCountries] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AllVisits] [int] NULL,
[DMlastupdated] [datetime] NULL CONSTRAINT [DF__omni_TGC___DMlas__4A20501C] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Archive].[omni_TGC_Apps_Downloads] ADD CONSTRAINT [PK__omni_TGC__D35856B3D429AE71] PRIMARY KEY CLUSTERED  ([omni_TGC_Apps_Downloads_id]) ON [PRIMARY]
GO
