CREATE TABLE [Archive].[Omni_TGC_Downloads_20180314]
(
[Omni_TGC_Downloads_id] [bigint] NOT NULL IDENTITY(1, 1),
[Actiondate] [date] NOT NULL,
[CustomerID] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MagentoUserID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MarketingCloudVisitorID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MobileDeviceType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MobileDevice] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MediaName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseID] [int] NULL,
[LectureNumber] [int] NULL,
[Action] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TotalActions] [int] NULL,
[FlagOnline] [int] NOT NULL,
[StreamedOrDownloadedFormatType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Lecture_duration] [int] NULL,
[GeoSegmentationCountries] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BrowserOrAppVersion] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Platform] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FormatPurchased] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StockItemID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingCountryCode] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOrdered] [datetime] NULL,
[TransactionType] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DMLastUpdated] [datetime] NULL
) ON [PRIMARY]
GO
