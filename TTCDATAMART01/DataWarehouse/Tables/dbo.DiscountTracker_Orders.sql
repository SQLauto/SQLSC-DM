CREATE TABLE [dbo].[DiscountTracker_Orders]
(
[A00_DateOrdered] [date] NULL,
[A01_YearOrdered] [int] NULL,
[A02_MonthOrdered] [int] NULL,
[A03_QuarterOrdered] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A04_WeekOfOrder] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A05_WeekOrderedNum] [int] NULL,
[A06_Adcode] [int] NULL,
[A07_AdcodeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[A08_Offer] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A09_CatalogCode] [int] NULL,
[A10_CatalogName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A11_PromotionTypeID] [smallint] NULL,
[A12_PromotionType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A13_MD_Channel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A14_MD_PromotionType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A15_MD_CampaignName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A16_MD_PriceType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A17_OrderSource] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A18_CurrencyCode] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A19_BillingCountryCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A20_FlagEmailOrder] [tinyint] NULL,
[A21_SequenceNum] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A22_CSRID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A23_FlagDigitalPhysical] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A24_FlagAudioVideo] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B01_OrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[B02_NetOrderAmount] [money] NULL,
[B03_ShippingCharge] [money] NULL,
[B04_DiscountAmount] [money] NULL,
[B05_Tax] [money] NULL,
[B06_TranscriptSales] [money] NULL,
[C01_TotalCourseSales] [money] NULL,
[C02_TotalCourseQuantity] [int] NULL,
[C03_TotalCourseParts] [money] NULL,
[C04_StdSalePrice] [money] NULL,
[C05_PriceDiscount_CrsLvl] [money] NULL,
[C06_FlagPriceDiscount_CrsLvl] [int] NOT NULL,
[D01_FlagHasCLRCourse] [bit] NULL,
[D02_TotalCLRCourseSales] [money] NULL,
[D03_TotalCLRCourseUnits] [int] NULL,
[D04_TotalCLRCourseParts] [money] NULL,
[D05_StdSalePriceCLRCourse] [money] NULL,
[D06_PriceDiscount_CLRCrsLvl] [money] NULL,
[D07_FlagPriceDiscount_CLRCrsLvl] [int] NOT NULL,
[E01_FlagHasOtherCourse] [bit] NULL,
[E02_TotalOtherCourseSales] [money] NULL,
[E03_TotalOtherCourseUnits] [int] NULL,
[E04_TotalOtherCourseParts] [money] NULL,
[E05_StdSalePriceOtherCourse] [money] NULL,
[E06_PriceDiscount_OtherCrsLvl] [money] NULL,
[E07_FlagPriceDiscount_OtherCrsLvl] [int] NOT NULL,
[F01_CustomerSegmentPrior] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[F02_FrequencyPrior] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[F03_NewsegPrior] [int] NULL,
[F04_NamePrior] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[F05_A12mfPrior] [int] NOT NULL,
[F06_MonetaryValuePrior] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[F07_PriorOrders] [int] NULL,
[F08_PriorOrdersBin] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[F09_PriorAOS] [money] NULL,
[F10_PriorAOSBin] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[F11_DaysSinceLastPurchase] [int] NULL,
[F12_DSLBin] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[G00_FlagHasCoupon] [int] NOT NULL,
[G01_Cpn_ID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[G02_Cpn_Desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[G03_Cpn_Code] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[G04_Cpn_Campaign] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[G05_Cpn_Measure1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[G06_Cpn_Amount1] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[G07_Cpn_Threshold1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[G08_Cpn_ThresholdMeasure1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[G09_Cpn_Measure2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[G10_Cpn_Amount2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H00_IntlPurchaseOrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H01_IntlPromotionType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H02_IntlAcqsnYear] [int] NULL,
[H03_IntlAcqsnMonth] [int] NULL,
[H04_IntlPurchaseDate] [datetime] NULL,
[H05_IntlOrderSource] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H06_IntlPurchAmount] [money] NULL,
[H07_IntlAOSBin] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H08_IntlFormatMediaPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H09_IntlSubjectPref] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H10_IntlFlagDigitalPhysical] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[I01_AgeBin] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[I02_Gender] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[I03_HouseHoldIncomeBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[I04_Education] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Z01_TotalDigitalSales] [money] NULL,
[Z02_TotalPhysicalSales] [money] NULL,
[Z03_TotalPhysicalShippingDerived] [money] NULL,
[Z04_TotalShippingDiscount] [money] NULL,
[Z05_SpecialShipping_CatCodeDrvn] [tinyint] NULL,
[Z06_SpecialShippingcharge_CatcodeDrvn] [money] NULL
) ON [PRIMARY]
GO
