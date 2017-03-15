CREATE TABLE [Marketing].[CC_Upsell_Report_AdcodE]
(
[ReportDate] [datetime] NULL,
[YearOrdered] [int] NULL,
[MonthOrdered] [int] NULL,
[WeekOrdered] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOrdered] [date] NULL,
[UpSellAdcode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpSellAdcodeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpSellCatalogCode] [int] NULL,
[UpSellCatalogName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_Year] [int] NULL,
[MD_Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_Audience] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_ChannelID] [int] NULL,
[MD_ChannelName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_PromotionTypeID] [int] NULL,
[MD_PromotionType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_CampaignID] [int] NULL,
[MD_CampaignName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_PriceType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderSource] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrencyCode] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CSRID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingCountryCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalUpsell_Sold] [numeric] (38, 4) NULL,
[TotalUpsell_Delivered] [numeric] (38, 4) NULL,
[TotalUpsell] [numeric] (38, 4) NULL,
[TotalSales] [money] NULL,
[UpSellFlag] [bit] NULL
) ON [PRIMARY]
GO
