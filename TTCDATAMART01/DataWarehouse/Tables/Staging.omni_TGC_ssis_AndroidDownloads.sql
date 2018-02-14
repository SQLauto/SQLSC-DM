CREATE TABLE [Staging].[omni_TGC_ssis_AndroidDownloads]
(
[Date] [datetime] NULL,
[userID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MobileDeviceType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MobileDevice] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GeoSegmentationCountries] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AppId] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LectureDownloaded] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Allvisits] [int] NULL
) ON [PRIMARY]
GO
