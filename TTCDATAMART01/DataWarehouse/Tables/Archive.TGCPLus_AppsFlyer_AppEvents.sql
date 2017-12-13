CREATE TABLE [Archive].[TGCPLus_AppsFlyer_AppEvents]
(
[TGCPLus_AppsFlyer_AppEvents_id] [int] NOT NULL IDENTITY(1, 1),
[AttributedTouchType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AttributedTouchTime] [datetime] NULL,
[InstallTime] [datetime] NULL,
[EventTime] [datetime] NULL,
[EventName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventValue] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventRevenue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventRevenueCurrency] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventRevenueUSD] [real] NULL,
[EventSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsReceiptValidated] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Partner] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MediaSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Channel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Keywords] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Campaign] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CampaignID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Adset] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdsetID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ad] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SiteID] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubSiteID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubParam1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubParam2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubParam3] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubParam4] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubParam5] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CostModel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CostValue] [real] NULL,
[CostCurrency] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contributor1Partner] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contributor1MediaSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contributor1Campaign] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contributor1TouchType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contributor1TouchTime] [datetime] NULL,
[Contributor2Partner] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contributor2MediaSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contributor2Campaign] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contributor2TouchType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contributor2TouchTime] [datetime] NULL,
[Contributor3Partner] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contributor3MediaSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contributor3Campaign] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contributor3TouchType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contributor3TouchTime] [datetime] NULL,
[Region] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PostalCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMA] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IP] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WIFI] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Operator] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Carrier] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Language] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AppsFlyerID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdvertisingID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IDFA] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AndroidID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerUserID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IMEI] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IDFV] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Platform] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeviceType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OSVersion] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AppVersion] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SDKVersion] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AppID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AppName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BundleID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsRetargeting] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RetargetingConversionType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AttributionLookback] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReengagementWindow] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsPrimaryAttribution] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserAgent] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HTTPReferrer] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginalURL] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMLastupdated] [datetime] NULL CONSTRAINT [DF__TGCPLus_A__DMLas__018A25DF] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Archive].[TGCPLus_AppsFlyer_AppEvents] ADD CONSTRAINT [PK__TGCPLus___B50ADEC67384D7F5] PRIMARY KEY CLUSTERED  ([TGCPLus_AppsFlyer_AppEvents_id]) ON [PRIMARY]
GO