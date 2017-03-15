CREATE TABLE [Marketing].[eW_QTR_YOY_Summary_20151022]
(
[AsOfDate] [date] NULL,
[AsOfYear] [int] NULL,
[AsOfQuarter] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Frequency] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewSeg] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A12mf] [int] NULL,
[CustomerSegment2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegmentFnl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagEmailable] [int] NULL,
[FlagMail] [int] NULL,
[Gender] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategoryPref2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[R3OrderSourcePref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[R3FormatMediaPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTDAvgOrderBin] [varchar] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTDAvgOrderBin2] [varchar] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DSLPurchBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TTB_Bin] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Agebin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TenureBin] [varchar] (14) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[eWGroup] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EducationBin] [varchar] (27) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HouseHoldIncomeBin] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Region] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[countryCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlYear] [int] NULL,
[IntlMonth] [int] NULL,
[IntlSubjectPref] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlFormatMediaPref] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlOrderSource] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlMD_Audience] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlMD_ChannelID] [int] NULL,
[IntlMD_Channel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlMD_PromotionTypeID] [int] NULL,
[IntlMD_PromotionType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlMD_CampaignID] [int] NULL,
[IntlMD_Campaign] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlMD_PriceType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlPromotionTypeID] [int] NULL,
[IntlPromotionType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlAvgOrderBin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagBoughtDigitlBfr] [tinyint] NULL,
[SalesBinPr12Mnth] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseCntBinPr12Mnth] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagEngagedCust] [tinyint] NULL,
[FlagPrEmailOrder] [tinyint] NULL,
[TotalCustomers] [int] NULL,
[PurchAmountQTR] [money] NULL,
[PurchasesQTR] [int] NULL,
[UnitsPurchQTR] [int] NULL,
[PartsPurchQTR] [money] NULL,
[EmailSalesQTR] [int] NULL,
[EmailOrdersQTR] [int] NULL,
[WebSalesQTR] [int] NULL,
[WebOrdersQTR] [int] NULL,
[MailContactsQTR] [int] NULL,
[EmailContactsQTR] [money] NULL,
[BuyersQTR] [int] NULL
) ON [PRIMARY]
GO
