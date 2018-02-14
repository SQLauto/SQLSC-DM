CREATE TABLE [Archive].[Omni_TGC_Streaming]
(
[Omni_TGC_Streaming_id] [bigint] NOT NULL IDENTITY(1, 1),
[Actiondate] [date] NOT NULL,
[CustomerID] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MagentoUserID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MarketingCloudVisitorID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MobileDeviceType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MobileDevice] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MediaName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseID] [int] NULL,
[LectureNumber] [int] NULL,
[Action] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TotalActions] [int] NULL,
[MediaTimePlayed] [numeric] (18, 6) NULL,
[Watched25pct] [int] NULL,
[Watched50pct] [int] NULL,
[Watched75pct] [int] NULL,
[Watched95pct] [int] NULL,
[MediaCompletes] [int] NULL,
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
[DMLastUpdated] [datetime] NULL CONSTRAINT [DF__Omni_TGC___DMLas__23E5989B] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Archive].[Omni_TGC_Streaming] ADD CONSTRAINT [PK__Omni_TGC__E9940D4AB3A5C006] PRIMARY KEY CLUSTERED  ([Omni_TGC_Streaming_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Omni_TGC_Streaming_ActionDate_Platform] ON [Archive].[Omni_TGC_Streaming] ([Actiondate], [Platform]) ON [PRIMARY]
GO
