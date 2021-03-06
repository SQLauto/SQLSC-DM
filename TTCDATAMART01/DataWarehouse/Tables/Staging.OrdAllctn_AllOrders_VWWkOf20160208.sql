CREATE TABLE [Staging].[OrdAllctn_AllOrders_VWWkOf20160208]
(
[FromDate] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToDate] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ForecastWeek] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[YearOrdered] [int] NULL,
[NetOrderAmount] [money] NULL,
[MonthOrdered] [int] NULL,
[WeekOfOrder] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagCountry] [int] NOT NULL,
[DateOrdered] [date] NULL,
[OrderSource] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDate] [datetime] NULL,
[StopDate] [datetime] NULL,
[WeekDiff] [int] NULL,
[FlagUnsourcedOrder] [int] NOT NULL,
[AdCode] [int] NULL,
[AdcodeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CatalogCode] [int] NULL,
[CatalogName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PromotionTypeID] [smallint] NULL,
[PromotionType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_CountryID] [int] NULL,
[MD_Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_AudienceID] [int] NULL,
[MD_Audience] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_ChannelID] [int] NULL,
[MD_Channel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_PromotionTypeID] [int] NULL,
[MD_PromotionType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_CampaignID] [int] NULL,
[MD_CampaignName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_Year] [int] NULL,
[MD_PriceTypeID] [int] NULL,
[MD_PriceType] [varchar] (81) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Asn_CountryID] [int] NULL,
[Asn_Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Asn_AudienceID] [int] NULL,
[Asn_Audience] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Asn_ChannelID] [int] NULL,
[Asn_Channel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Asn_PromotionTypeID] [int] NULL,
[Asn_PromotionType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Asn_CampaignID] [int] NULL,
[Asn_CampaignName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Asn_Year] [int] NULL,
[Asn_PriceTypeID] [int] NULL,
[Asn_PriceType] [varchar] (81) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Asn_CatalogCode] [int] NULL,
[Asn_CatalogName] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Coupon] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CouponDesc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AssignedCode] [int] NULL,
[AssignedName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagRecvdCampaign] [tinyint] NULL,
[CouponPriorityCode] [int] NULL,
[CouponCatalogCode] [int] NULL,
[CouponCatalogCodeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CouponAdCodeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AssignReason] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CrsMatchCatalogCode] [int] NULL,
[CrsMatchCatalogName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SequenceNum] [int] NULL,
[FlagNewCustomer] [int] NOT NULL,
[NamePrior] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagDigitalPhysical] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrencyCode] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingCountryCode] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CD_Sales] [money] NULL,
[CD_Parts] [money] NULL,
[DVD_Sales] [money] NULL,
[DVD_Parts] [money] NULL,
[DownloadA_Sales] [money] NULL,
[DownloadA_Parts] [money] NULL,
[DownloadV_Sales] [money] NULL,
[DownloadV_Parts] [money] NULL,
[Transcript_Sales] [money] NULL,
[Transcript_Parts] [money] NULL,
[ExchangeRate] [numeric] (5, 4) NOT NULL,
[NetOrderAmountDllrs] [money] NULL,
[CD_SalesDllrs] [money] NULL,
[DVD_SalesDllrs] [money] NULL,
[DownloadA_SalesDllrs] [money] NULL,
[DownloadV_SalesDllrs] [money] NULL,
[Transcript_SalesDllrs] [money] NULL,
[Tax] [money] NULL,
[TaxDllrs] [money] NULL
) ON [PRIMARY]
GO
