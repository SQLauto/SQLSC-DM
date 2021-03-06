CREATE TABLE [Staging].[TempEcom_SalesByPromotion]
(
[ReportDate] [datetime] NOT NULL,
[YearOrdered] [int] NULL,
[MonthOrdered] [int] NULL,
[WeekNum] [int] NULL,
[WeeksSinceOrder] [int] NULL,
[WeekOf] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CatalogCode] [int] NOT NULL,
[CatalogName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Adcode] [int] NOT NULL,
[AdcodeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PromotionTypeID] [smallint] NULL,
[PromotionType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_Audience] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_Year] [int] NULL,
[MD_CampaignID] [int] NULL,
[MD_CampaignDesc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_ChannelID] [int] NULL,
[MD_ChannelDesc] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_PromotionTypeID] [int] NULL,
[MD_PromotionType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_PriceType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrencyCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerType] [varchar] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerCount] [int] NULL,
[MinDate] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MaxDate] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalSales] [money] NULL,
[TotalOrders] [int] NULL
) ON [PRIMARY]
GO
