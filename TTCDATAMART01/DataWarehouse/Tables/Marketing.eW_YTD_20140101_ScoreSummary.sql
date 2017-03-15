CREATE TABLE [Marketing].[eW_YTD_20140101_ScoreSummary]
(
[AsOfDate] [date] NULL,
[AsOfYear] [int] NULL,
[AsOfMonth] [int] NOT NULL,
[CustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Frequency] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewSeg] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A12mf] [int] NULL,
[FlagEmailable] [int] NULL,
[FlagMail] [int] NULL,
[Gender] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategoryPref2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[R3OrderSourcePref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[R3FormatMediaPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTDAvgOrderBin] [varchar] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DSLPurchBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TTB_Bin] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Agebin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TenureBin] [varchar] (14) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[eWGroup] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Education] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HouseHoldIncomeBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Region] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[countryCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlYear] [int] NULL,
[IntlMonth] [int] NULL,
[IntlSubjectPref] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlFormatMediaPref] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlOrderSource] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlPromotionTypeID] [int] NULL,
[IntlPromotionType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlAvgOrderBin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectPref2_EOY] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagBoughtDigitlBfr] [tinyint] NULL,
[SalesBinPriorYr] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseCntBinPriorYr] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagEngagedCust] [tinyint] NULL,
[FlagPrEmailOrder] [tinyint] NULL,
[NwCrsBinYTD] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Decile] [int] NULL,
[DemiDecile] [int] NULL,
[Decile2] [int] NULL,
[DemiDecile2] [int] NULL,
[TotalCustomers] [int] NULL,
[PurchAmountYTD] [money] NULL,
[PurchasesYTD] [int] NULL,
[UnitsPurchYTD] [int] NULL,
[PartsPurchYTD] [money] NULL,
[EmailSalesYTD] [int] NULL,
[EmailOrdersYTD] [int] NULL,
[WebSalesYTD] [int] NULL,
[WebOrdersYTD] [int] NULL,
[MailContactsYTD] [int] NULL,
[EmailContactsYTD] [money] NULL,
[BuyersYTD] [int] NULL,
[PurchAmountFY] [money] NULL,
[PurchasesFY] [int] NULL,
[UnitsPurchFY] [int] NULL,
[PartsPurchFY] [money] NULL,
[EmailSalesFY] [int] NULL,
[EmailOrdersFY] [int] NULL,
[WebSalesFY] [int] NULL,
[WebOrdersFY] [int] NULL,
[MailContactsFY] [int] NULL,
[EmailContactsFY] [money] NULL,
[BuyersFY] [int] NULL,
[CatalogSalesYTD] [money] NULL,
[CatalogOrdersYTD] [int] NULL,
[MagalogSalesYTD] [money] NULL,
[MagalogOrdersYTD] [int] NULL,
[Mag7SalesYTD] [money] NULL,
[Mag7OrdersYTD] [int] NULL,
[MagazineSalesYTD] [money] NULL,
[MagazineOrdersYTD] [int] NULL,
[LetterSalesYTD] [money] NULL,
[LetterOrdersYTD] [int] NULL,
[MagbackSalesYTD] [money] NULL,
[MagbackOrdersYTD] [int] NULL,
[ReactivationSalesYTD] [money] NULL,
[ReactivationOrdersYTD] [int] NULL,
[EmailDLRSalesYTD] [money] NULL,
[EmailDLROrdersYTD] [int] NULL,
[EmailRevGenSalesYTD] [money] NULL,
[EmailRevGenOrdersYTD] [int] NULL,
[OtherSalesYTD] [money] NULL,
[OtherOrdersYTD] [int] NULL,
[CDSalesYTD] [money] NULL,
[CDOrdersYTD] [int] NULL,
[DVDSalesYTD] [money] NULL,
[DVDOrdersYTD] [int] NULL,
[VDLSalesYTD] [money] NULL,
[VDLOrdersYTD] [int] NULL,
[ADLSalesYTD] [money] NULL,
[ADLOrdersYTD] [int] NULL,
[TranscriptSalesYTD] [money] NULL,
[TranscriptOrdersYTD] [int] NULL
) ON [PRIMARY]
GO
