CREATE TABLE [Staging].[omni_TGC_ssis_USDownloads]
(
[Date] [datetime] NULL,
[MarketingCloudVisitorID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MobileDeviceType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GeoSegmentationCountries] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Browser] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LectureDownloaded] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AllVisits] [int] NULL
) ON [PRIMARY]
GO
