CREATE TABLE [Archive].[EmailOrders_Summary]
(
[UniqueCustomers] [int] NULL,
[Customers] [int] NULL,
[Adcode] [int] NULL,
[StartDate] [datetime] NULL,
[Sends] [int] NULL,
[OpenCounter] [int] NOT NULL,
[ClickCounter] [int] NOT NULL,
[Opens] [int] NULL,
[Clicks] [int] NULL,
[OpenDate] [date] NULL,
[ClickDate] [date] NULL,
[Orders] [int] NULL,
[DateOrdered] [date] NULL,
[NetOrderAmount] [money] NULL,
[OrderSource] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagDigitalPhysical] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OpenTime] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClickTime] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdcodeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdCodeExpirationDate] [datetime] NULL,
[MD_CampaignName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegmentFnl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailOffer] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[campaignName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CatalogCode] [int] NULL,
[catalogname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Flag_DoublePunch] [int] NULL,
[FrequencyByCampiagn] [int] NULL,
[PriorRunDate] [datetime] NULL,
[DMlastupdated] [datetime] NULL
) ON [YearRangePartitionScheme] ([StartDate])
GO
CREATE CLUSTERED INDEX [IX_EmailOrders_Summary_Startdate] ON [Archive].[EmailOrders_Summary] ([StartDate]) ON [YearRangePartitionScheme] ([StartDate])
GO
