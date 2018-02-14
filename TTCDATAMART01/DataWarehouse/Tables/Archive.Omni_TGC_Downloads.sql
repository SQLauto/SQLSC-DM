CREATE TABLE [Archive].[Omni_TGC_Downloads]
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
[DMLastUpdated] [datetime] NULL CONSTRAINT [DF__Omni_TGC___DMLas__27B6297F] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Archive].[Omni_TGC_Downloads] ADD CONSTRAINT [PK__Omni_TGC__9C287C9F1B393B8F] PRIMARY KEY CLUSTERED  ([Omni_TGC_Downloads_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Omni_TGC_Downloads_ActionDate_Platform] ON [Archive].[Omni_TGC_Downloads] ([Actiondate], [Platform]) ON [PRIMARY]
GO
