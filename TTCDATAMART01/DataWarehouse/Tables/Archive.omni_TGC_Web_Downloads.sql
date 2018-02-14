CREATE TABLE [Archive].[omni_TGC_Web_Downloads]
(
[omni_TGC_Web_Downloads_id] [bigint] NOT NULL IDENTITY(1, 1),
[Date] [date] NULL,
[MarketingCloudVisitorID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserId] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MobileDeviceType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MobileDevice] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MediaName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[courseid] [int] NULL,
[LectureNumber] [int] NULL,
[DownloadedCountryCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DownloadedFormatType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lecture_duration] [int] NULL,
[Browser] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GeoSegmentationCountries] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Allvisits] [int] NULL,
[DMlastupdated] [datetime] NULL CONSTRAINT [DF__omni_TGC___DMlas__446776C6] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Archive].[omni_TGC_Web_Downloads] ADD CONSTRAINT [PK__omni_TGC__8BC75D0AAAD30A09] PRIMARY KEY CLUSTERED  ([omni_TGC_Web_Downloads_id]) ON [PRIMARY]
GO
