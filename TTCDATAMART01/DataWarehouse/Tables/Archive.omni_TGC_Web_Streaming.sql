CREATE TABLE [Archive].[omni_TGC_Web_Streaming]
(
[omni_TGC_Web_Streaming_id] [bigint] NOT NULL IDENTITY(1, 1),
[Date] [date] NULL,
[MarketingCloudVisitorID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MobileDeviceType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MobileDevices] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MediaName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[courseid] [int] NULL,
[LectureNumber] [int] NULL,
[DeviceConnected] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MediaViews] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MediaTimePlayed] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Watched25pct] [int] NULL,
[Watched50pct] [int] NULL,
[Watched75pct] [int] NULL,
[Watched95pct] [int] NULL,
[MediaCompletes] [int] NULL,
[Countrycode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DMlastupdated] [datetime] NULL CONSTRAINT [DF__omni_TGC___DMlas__604DF1AF] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Archive].[omni_TGC_Web_Streaming] ADD CONSTRAINT [PK__omni_TGC__181DDC0D673981B6] PRIMARY KEY CLUSTERED  ([omni_TGC_Web_Streaming_id]) ON [PRIMARY]
GO
