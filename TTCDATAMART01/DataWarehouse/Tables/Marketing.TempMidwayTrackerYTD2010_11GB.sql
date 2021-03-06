CREATE TABLE [Marketing].[TempMidwayTrackerYTD2010_11GB]
(
[AsOfDate] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AsOfYear] [int] NOT NULL,
[AsOfMonth] [int] NOT NULL,
[CustomerID] [int] NOT NULL,
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
[Education] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HouseHoldIncomeBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Age] [int] NULL,
[AgeBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategoryPref2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategoryPref] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
[FlagPurchCrs995YTD] [tinyint] NULL,
[Crs995NumsYTD] [int] NULL,
[Crs995BinYTD] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
[FlagPurchCrs995MTD] [tinyint] NULL,
[Crs995NumsMTD] [int] NULL,
[Crs995BinMTD] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
[WebOrdersFY] [int] NULL,
[FlagPurchJAN] [tinyint] NULL,
[FlagPurchNwCrsJAN] [tinyint] NULL,
[NwCrsNumsJAN] [int] NULL,
[NwCrsBinJAN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PurchAmountJAN] [money] NULL,
[PurchasesJAN] [int] NULL,
[CourseSalesJAN] [money] NULL,
[UnitsPurchJAN] [int] NULL,
[PartsPurchJAN] [money] NULL,
[EmailContactsJAN] [money] NULL,
[MailContactsJAN] [int] NULL,
[EmailSalesJAN] [int] NULL,
[EmailUnitsJAN] [int] NULL,
[FlagPurchCrs995JAN] [tinyint] NULL,
[Crs995NumsJAN] [int] NULL,
[Crs995BinJAN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagPurchFEB] [tinyint] NULL,
[FlagPurchNwCrsFEB] [tinyint] NULL,
[NwCrsNumsFEB] [int] NULL,
[NwCrsBinFEB] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PurchAmountFEB] [money] NULL,
[PurchasesFEB] [int] NULL,
[CourseSalesFEB] [money] NULL,
[UnitsPurchFEB] [int] NULL,
[PartsPurchFEB] [money] NULL,
[EmailContactsFEB] [money] NULL,
[MailContactsFEB] [int] NULL,
[EmailSalesFEB] [int] NULL,
[EmailUnitsFEB] [int] NULL,
[FlagPurchCrs995FEB] [tinyint] NULL,
[Crs995NumsFEB] [int] NULL,
[Crs995BinFEB] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagPurchMAR] [tinyint] NULL,
[FlagPurchNwCrsMAR] [tinyint] NULL,
[NwCrsNumsMAR] [int] NULL,
[NwCrsBinMAR] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PurchAmountMAR] [money] NULL,
[PurchasesMAR] [int] NULL,
[CourseSalesMAR] [money] NULL,
[UnitsPurchMAR] [int] NULL,
[PartsPurchMAR] [money] NULL,
[EmailContactsMAR] [money] NULL,
[MailContactsMAR] [int] NULL,
[EmailSalesMAR] [int] NULL,
[EmailUnitsMAR] [int] NULL,
[FlagPurchCrs995MAR] [tinyint] NULL,
[Crs995NumsMAR] [int] NULL,
[Crs995BinMAR] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagPurchAPR] [tinyint] NULL,
[FlagPurchNwCrsAPR] [tinyint] NULL,
[NwCrsNumsAPR] [int] NULL,
[NwCrsBinAPR] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PurchAmountAPR] [money] NULL,
[PurchasesAPR] [int] NULL,
[CourseSalesAPR] [money] NULL,
[UnitsPurchAPR] [int] NULL,
[PartsPurchAPR] [money] NULL,
[EmailContactsAPR] [money] NULL,
[MailContactsAPR] [int] NULL,
[EmailSalesAPR] [int] NULL,
[EmailUnitsAPR] [int] NULL,
[FlagPurchCrs995APR] [tinyint] NULL,
[Crs995NumsAPR] [int] NULL,
[Crs995BinAPR] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagPurchMAY] [tinyint] NULL,
[FlagPurchNwCrsMAY] [tinyint] NULL,
[NwCrsNumsMAY] [int] NULL,
[NwCrsBinMAY] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PurchAmountMAY] [money] NULL,
[PurchasesMAY] [int] NULL,
[CourseSalesMAY] [money] NULL,
[UnitsPurchMAY] [int] NULL,
[PartsPurchMAY] [money] NULL,
[EmailContactsMAY] [money] NULL,
[MailContactsMAY] [int] NULL,
[EmailSalesMAY] [int] NULL,
[EmailUnitsMAY] [int] NULL,
[FlagPurchCrs995MAY] [tinyint] NULL,
[Crs995NumsMAY] [int] NULL,
[Crs995BinMAY] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagPurchJUN] [tinyint] NULL,
[FlagPurchNwCrsJUN] [tinyint] NULL,
[NwCrsNumsJUN] [int] NULL,
[NwCrsBinJUN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PurchAmountJUN] [money] NULL,
[PurchasesJUN] [int] NULL,
[CourseSalesJUN] [money] NULL,
[UnitsPurchJUN] [int] NULL,
[PartsPurchJUN] [money] NULL,
[EmailContactsJUN] [money] NULL,
[MailContactsJUN] [int] NULL,
[EmailSalesJUN] [int] NULL,
[EmailUnitsJUN] [int] NULL,
[FlagPurchCrs995JUN] [tinyint] NULL,
[Crs995NumsJUN] [int] NULL,
[Crs995BinJUN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagPurchJUL] [tinyint] NULL,
[FlagPurchNwCrsJUL] [tinyint] NULL,
[NwCrsNumsJUL] [int] NULL,
[NwCrsBinJUL] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PurchAmountJUL] [money] NULL,
[PurchasesJUL] [int] NULL,
[CourseSalesJUL] [money] NULL,
[UnitsPurchJUL] [int] NULL,
[PartsPurchJUL] [money] NULL,
[EmailContactsJUL] [money] NULL,
[MailContactsJUL] [int] NULL,
[EmailSalesJUL] [int] NULL,
[EmailUnitsJUL] [int] NULL,
[FlagPurchCrs995JUL] [tinyint] NULL,
[Crs995NumsJUL] [int] NULL,
[Crs995BinJUL] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagPurchAUG] [tinyint] NULL,
[FlagPurchNwCrsAUG] [tinyint] NULL,
[NwCrsNumsAUG] [int] NULL,
[NwCrsBinAUG] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PurchAmountAUG] [money] NULL,
[PurchasesAUG] [int] NULL,
[CourseSalesAUG] [money] NULL,
[UnitsPurchAUG] [int] NULL,
[PartsPurchAUG] [money] NULL,
[EmailContactsAUG] [money] NULL,
[MailContactsAUG] [int] NULL,
[EmailSalesAUG] [int] NULL,
[EmailUnitsAUG] [int] NULL,
[FlagPurchCrs995AUG] [tinyint] NULL,
[Crs995NumsAUG] [int] NULL,
[Crs995BinAUG] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagPurchSEP] [tinyint] NULL,
[FlagPurchNwCrsSEP] [tinyint] NULL,
[NwCrsNumsSEP] [int] NULL,
[NwCrsBinSEP] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PurchAmountSEP] [money] NULL,
[PurchasesSEP] [int] NULL,
[CourseSalesSEP] [money] NULL,
[UnitsPurchSEP] [int] NULL,
[PartsPurchSEP] [money] NULL,
[EmailContactsSEP] [money] NULL,
[MailContactsSEP] [int] NULL,
[EmailSalesSEP] [int] NULL,
[EmailUnitsSEP] [int] NULL,
[FlagPurchCrs995SEP] [tinyint] NULL,
[Crs995NumsSEP] [int] NULL,
[Crs995BinSEP] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagPurchOCT] [tinyint] NULL,
[FlagPurchNwCrsOCT] [tinyint] NULL,
[NwCrsNumsOCT] [int] NULL,
[NwCrsBinOCT] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PurchAmountOCT] [money] NULL,
[PurchasesOCT] [int] NULL,
[CourseSalesOCT] [money] NULL,
[UnitsPurchOCT] [int] NULL,
[PartsPurchOCT] [money] NULL,
[EmailContactsOCT] [money] NULL,
[MailContactsOCT] [int] NULL,
[EmailSalesOCT] [int] NULL,
[EmailUnitsOCT] [int] NULL,
[FlagPurchCrs995OCT] [tinyint] NULL,
[Crs995NumsOCT] [int] NULL,
[Crs995BinOCT] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagPurchNOV] [tinyint] NULL,
[FlagPurchNwCrsNOV] [tinyint] NULL,
[NwCrsNumsNOV] [int] NULL,
[NwCrsBinNOV] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PurchAmountNOV] [money] NULL,
[PurchasesNOV] [int] NULL,
[CourseSalesNOV] [money] NULL,
[UnitsPurchNOV] [int] NULL,
[PartsPurchNOV] [money] NULL,
[EmailContactsNOV] [money] NULL,
[MailContactsNOV] [int] NULL,
[EmailSalesNOV] [int] NULL,
[EmailUnitsNOV] [int] NULL,
[FlagPurchCrs995NOV] [tinyint] NULL,
[Crs995NumsNOV] [int] NULL,
[Crs995BinNOV] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagPurchDEC] [tinyint] NULL,
[FlagPurchNwCrsDEC] [tinyint] NULL,
[NwCrsNumsDEC] [int] NULL,
[NwCrsBinDEC] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PurchAmountDEC] [money] NULL,
[PurchasesDEC] [int] NULL,
[CourseSalesDEC] [money] NULL,
[UnitsPurchDEC] [int] NULL,
[PartsPurchDEC] [money] NULL,
[EmailContactsDEC] [money] NULL,
[MailContactsDEC] [int] NULL,
[EmailSalesDEC] [int] NULL,
[EmailUnitsDEC] [int] NULL,
[FlagPurchCrs995DEC] [tinyint] NULL,
[Crs995NumsDEC] [int] NULL,
[Crs995BinDEC] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
