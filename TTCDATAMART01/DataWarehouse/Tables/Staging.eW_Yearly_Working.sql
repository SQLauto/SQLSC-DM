CREATE TABLE [Staging].[eW_Yearly_Working]
(
[AsOfDate] [date] NULL,
[AsOfYear] [int] NULL,
[AsOfMonth] [int] NOT NULL,
[CountryCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Frequency] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewSeg] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A12mf] [int] NULL,
[FlagEmailable] [int] NULL,
[FlagEmailPref] [int] NULL,
[FlagValidEmail] [tinyint] NULL,
[FlagMail] [int] NULL,
[State] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Region] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Gender] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Education] [varchar] (27) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HouseHoldIncomeBin] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Age] [int] NULL,
[AgeBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategoryPref2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategoryPref] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectPref2_EOY] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[R3OrderSourcePref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[R3FormatMediaPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DSLPurchase] [int] NULL,
[TenureDays] [int] NULL,
[R3PurchWeb] [tinyint] NULL,
[FlagWebLTM18] [tinyint] NULL,
[eWGroup] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTDPurchases] [int] NULL,
[TTB] [int] NULL,
[TTB_Bin] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Recency] [int] NULL,
[LTDAvgOrderBin] [varchar] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DSLPurchBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TenureBin] [varchar] (14) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FlagNearInactive] [tinyint] NULL,
[FlagPrEmailOrder] [tinyint] NULL,
[FlagEngagedCust] [tinyint] NULL,
[FlagBoughtDigitlBfr] [tinyint] NULL,
[SalesBinPriorYr] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseCntBinPriorYr] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlYear] [int] NULL,
[IntlMonth] [int] NULL,
[IntlSubjectPref] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlFormatMediaPref] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlOrderSource] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlPromotionTypeID] [int] NULL,
[IntlPromotionType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlPurchAmount] [money] NULL,
[IntlAvgOrderBin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagPurchYTD] [tinyint] NULL,
[FlagPurchNwCrsYTD] [tinyint] NULL,
[NwCrsNumsYTD] [int] NULL,
[NwCrsBinYTD] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PurchAmountYTD] [money] NULL,
[PurchasesYTD] [int] NULL,
[CourseSalesYTD] [money] NULL,
[UnitsPurchYTD] [int] NULL,
[PartsPurchYTD] [money] NULL,
[EmailContactsYTD] [money] NULL,
[MailContactsYTD] [int] NULL,
[EmailSalesYTD] [int] NULL,
[EmailOrdersYTD] [int] NULL,
[EmailUnitsYTD] [int] NULL,
[WebSalesYTD] [int] NULL,
[WebOrdersYTD] [int] NULL,
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
[TranscriptOrdersYTD] [int] NULL,
[FlagPurchMTD] [tinyint] NULL,
[FlagPurchNwCrsMTD] [tinyint] NULL,
[NwCrsNumsMTD] [int] NULL,
[NwCrsBinMTD] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PurchAmountMTD] [money] NULL,
[PurchasesMTD] [int] NULL,
[CourseSalesMTD] [money] NULL,
[UnitsPurchMTD] [int] NULL,
[PartsPurchMTD] [money] NULL,
[EmailContactsMTD] [money] NULL,
[MailContactsMTD] [int] NULL,
[EmailSalesMTD] [int] NULL,
[EmailOrdersMTD] [int] NULL,
[EmailUnitsMTD] [int] NULL,
[WebSalesMTD] [int] NULL,
[WebOrdersMTD] [int] NULL,
[FlagPurchFY] [tinyint] NULL,
[PurchAmountFY] [money] NULL,
[PurchasesFY] [int] NULL,
[CourseSalesFY] [money] NULL,
[UnitsPurchFY] [int] NULL,
[PartsPurchFY] [money] NULL,
[EmailContactsFY] [money] NULL,
[MailContactsFY] [int] NULL,
[EmailSalesFY] [int] NULL,
[EmailOrdersFY] [int] NULL,
[WebSalesFY] [int] NULL,
[WebOrdersFY] [int] NULL
) ON [PRIMARY]
GO
