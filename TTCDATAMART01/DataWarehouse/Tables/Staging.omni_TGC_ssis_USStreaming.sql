CREATE TABLE [Staging].[omni_TGC_ssis_USStreaming]
(
[Date] [datetime] NULL,
[MarketingCloudVisitorID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MobileDeviceType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MobileDevices] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MediaName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeviceConnected] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MediaViews] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MediaTimePlayed] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Watched25pct] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Watched50pct] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Watched75pct] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Watched95pct] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MediaCompletes] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
