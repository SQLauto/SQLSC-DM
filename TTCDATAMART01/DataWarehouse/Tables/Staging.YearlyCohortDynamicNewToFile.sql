CREATE TABLE [Staging].[YearlyCohortDynamicNewToFile]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrganizationID] [tinyint] NOT NULL,
[FlagMailableCollegeBuyerSS] [tinyint] NOT NULL,
[Gender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AsOfDate] [date] NOT NULL,
[AsOfMonth] [tinyint] NOT NULL,
[AsOfYear] [smallint] NOT NULL,
[NewSeg] [tinyint] NOT NULL,
[Name] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[A12MF] [tinyint] NOT NULL,
[ActiveOrSwamp] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LTDPurchases] [int] NOT NULL,
[LTDPurchasesBinID] [tinyint] NOT NULL,
[Frequency] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DSLPurchase] [int] NOT NULL,
[DSLPurchaseBinID] [tinyint] NOT NULL,
[LTDPurchAmount] [money] NOT NULL,
[LTDAvgOrd] [money] NOT NULL,
[LTDAvgOrderBinID] [tinyint] NOT NULL,
[LTDFormatMediaCat] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[R3FormatMediaPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LTDFormatAVCat] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[R3FormatAVPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LTDFormatADCat] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[R3FormatADPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LTDSubjectCat] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[R3SubjectPref] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LTDOrderSource] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[R3OrderSource] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TenureDays] [int] NOT NULL,
[TenureDaysBinID] [tinyint] NOT NULL,
[LTDCouponsRedm] [int] NOT NULL,
[LTDCouponsRedmBinID] [tinyint] NOT NULL,
[DSLCouponRedm] [int] NOT NULL,
[DSLCouponRedmBinID] [tinyint] NOT NULL,
[LTDItemsReturned] [int] NOT NULL,
[LTDReturnsBinID] [tinyint] NOT NULL,
[LTDEMResponses] [int] NOT NULL,
[LTDEMResponsesBinID] [tinyint] NOT NULL,
[DSLEMResponse] [int] NOT NULL,
[DSLEMResponseBinID] [tinyint] NOT NULL,
[LTDNewCoursesPurch] [int] NOT NULL,
[LTDNewCoursePurchBinID] [tinyint] NOT NULL,
[DSLNewCoursePurch] [int] NOT NULL,
[DSLNewCoursePurchBinID] [tinyint] NOT NULL,
[YTDPurchases] [int] NOT NULL,
[YTDCatalogPurch] [int] NOT NULL,
[YTDSwampSpPurch] [int] NOT NULL,
[YTDNLPurch] [int] NOT NULL,
[YTDMagalogPurch] [int] NOT NULL,
[YTDContacts] [int] NOT NULL,
[YTDContactsBinID] [tinyint] NOT NULL,
[YTDCatalogContacts] [int] NOT NULL,
[YTDCatalogContactsBinID] [tinyint] NOT NULL,
[YTDSwampSpContacts] [int] NOT NULL,
[YTDSwampSpContactsBinID] [tinyint] NOT NULL,
[YTDNLContacts] [int] NOT NULL,
[YTDNLContactsBinID] [tinyint] NOT NULL,
[YTDMagalogContacts] [int] NOT NULL,
[YTDMagalogContactsBinID] [tinyint] NOT NULL,
[PurchAmountSubsqMth] [money] NOT NULL,
[PurchasesSubsqMth] [int] NOT NULL,
[CoupnsRedmSubsqMth] [int] NOT NULL,
[NewCoursePurchSubsqMth] [int] NOT NULL,
[EMResponsesSubsqMth] [int] NOT NULL,
[ContactsSubsqMth] [int] NOT NULL,
[CostContactsSubsqMth] [money] NOT NULL,
[CatalogContactsSubsqMth] [int] NOT NULL,
[CostCatalogContactsSubsqMth] [money] NOT NULL,
[MagalogContactsSubsqMth] [int] NOT NULL,
[CostMagalogContactsSubsqMth] [money] NOT NULL,
[NLContactsSubsqMth] [int] NOT NULL,
[CostNLContactsSubsqMth] [money] NULL,
[SwampSpContactsSubsqMth] [int] NOT NULL,
[CostSwampSpContactsSubsqMth] [money] NULL,
[MagazineContactsSubsqMth] [int] NOT NULL,
[CostMagazineContactsSubsqMth] [money] NULL,
[LTDNewCourseSales] [money] NULL,
[NewCourseSalesSubsqMth] [money] NULL,
[YTDMagazinePurch] [int] NULL,
[YTDMagazineContacts] [int] NULL,
[YTDMagazineContactsBinID] [tinyint] NULL,
[FlagEmailPref] [tinyint] NULL,
[FlagEmailValid] [tinyint] NULL,
[FlagEmailable] [tinyint] NULL,
[EmailContactsSubsqMth] [int] NULL,
[FlagMailPref] [tinyint] NULL,
[FlagValidUSMailable] [tinyint] NULL,
[FlagMailable] [tinyint] NULL,
[ContactsWelcomePackage] [int] NULL,
[CountryCode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[R3PurchWeb] [tinyint] NULL,
[PartsPurchSubsqMth] [dbo].[udtCourseParts] NULL,
[HoursPurchSubsqMth] [money] NULL,
[UnitsPurchSubsqMth] [int] NULL,
[CustomerSegment2ID] [int] NULL,
[CustomerSegmentFnlID] [int] NULL,
[AsofdatePrior] [date] NULL,
[AsofdateNext] [date] NULL
) ON [PRIMARY]
GO
