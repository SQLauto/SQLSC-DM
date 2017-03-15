CREATE TABLE [Staging].[TempDMCustomerDynamic]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TempCustomerDynamic_CustomerID] DEFAULT ((0)),
[OrganizationID] [tinyint] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_OrganizationID] DEFAULT ((0)),
[FlagMailableCollegeBuyerSS] [tinyint] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_FlagMailableCollegeBuyerSS] DEFAULT ((0)),
[Gender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempCustomerDynamic_Gender] DEFAULT ('X'),
[AsOfDate] [date] NOT NULL,
[AsOfMonth] [tinyint] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_AsOfMonth] DEFAULT ((0)),
[AsOfYear] [smallint] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_AsOfYear] DEFAULT ((0)),
[NewSeg] [tinyint] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_NewSeg] DEFAULT ((0)),
[Name] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TempCustomerDynamic_Name] DEFAULT ('X'),
[A12MF] [tinyint] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_A12MF] DEFAULT ((0)),
[ActiveOrSwamp] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TempCustomerDynamic_ActiveOrSwamp] DEFAULT ('X'),
[LTDPurchases] [int] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_NumOfPurchases] DEFAULT ((0)),
[LTDPurchasesBinID] [tinyint] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_LTDPurchasesBinID] DEFAULT ((0)),
[Frequency] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TempCustomerDynamic_Frequency] DEFAULT ('X'),
[DSLPurchase] [int] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_DSLPurchase] DEFAULT ((0)),
[DSLPurchaseBinID] [tinyint] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_DSLPurchaseBinID] DEFAULT ((0)),
[LTDPurchAmount] [money] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_LTDPurchAmount] DEFAULT ((0)),
[LTDAvgOrd] [money] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_LTDAvgAord] DEFAULT ((0)),
[LTDAvgOrderBinID] [tinyint] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_LTDAvgOrderBinID] DEFAULT ((0)),
[LTDFormatMediaCat] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TempCustomerDynamic_LTDFormatMediaCat] DEFAULT ('X'),
[R3FormatMediaPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TempCustomerDynamic_R3FormatMediaPref] DEFAULT ('X'),
[LTDFormatAVCat] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TempCustomerDynamic_LTDFormatAVCat] DEFAULT ('X'),
[R3FormatAVPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TempCustomerDynamic_R3FormatAVPref] DEFAULT ('X'),
[LTDFormatADCat] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TempCustomerDynamic_LTDFormatADCat] DEFAULT ('X'),
[R3FormatADPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TempCustomerDynamic_R3FormatADPref] DEFAULT ('X'),
[LTDSubjectCat] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TempCustomerDynamic_LTDSubjectCat] DEFAULT ('X'),
[R3SubjectPref] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TempCustomerDynamic_R3SubjectPref] DEFAULT ('X'),
[LTDOrderSource] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TempCustomerDynamic_LTDOrderSource] DEFAULT ('X'),
[R3OrderSource] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TempCustomerDynamic_R3OrderSource] DEFAULT ('X'),
[TenureDays] [int] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_TenureDays] DEFAULT ((0)),
[TenureDaysBinID] [tinyint] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_TenureDaysBinID] DEFAULT ((0)),
[LTDCouponsRedm] [int] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_NumOfCouponsRedm] DEFAULT ((0)),
[LTDCouponsRedmBinID] [tinyint] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_LTDCouponsRedmBinID] DEFAULT ((0)),
[DSLCouponRedm] [int] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_DSLCouponRedm] DEFAULT ((0)),
[DSLCouponRedmBinID] [tinyint] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_DSLCouponRedmBinID] DEFAULT ((0)),
[LTDItemsReturned] [int] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_LTDItemsReturned] DEFAULT ((0)),
[LTDReturnsBinID] [tinyint] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_LTDReturnsBinID] DEFAULT ((0)),
[LTDEMResponses] [int] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_NumOfEMResponses] DEFAULT ((0)),
[LTDEMResponsesBinID] [tinyint] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_LTDEMResponsesBinID] DEFAULT ((0)),
[DSLEMResponse] [int] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_DSLEMailResponse] DEFAULT ((0)),
[DSLEMResponseBinID] [tinyint] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_DSLEMResponseBinID] DEFAULT ((0)),
[LTDNewCoursesPurch] [int] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_LTDNewCoursesPurch] DEFAULT ((0)),
[LTDNewCoursePurchBinID] [tinyint] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_LTDNewCoursePurchBinID] DEFAULT ((0)),
[DSLNewCoursePurch] [int] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_DSLNewCoursePurch] DEFAULT ((0)),
[DSLNewCoursePurchBinID] [tinyint] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_DSLNewCoursePurchBinID] DEFAULT ((0)),
[YTDPurchases] [int] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_NumOf1YrPur] DEFAULT ((0)),
[YTDCatalogPurch] [int] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_NumOf1YrCatalogPur] DEFAULT ((0)),
[YTDSwampSpPurch] [int] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_NumOf1YrSwampSpPur] DEFAULT ((0)),
[YTDNLPurch] [int] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_NumOf1YrNLPur] DEFAULT ((0)),
[YTDMagalogPurch] [int] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_NumOf1YrMagalogPur] DEFAULT ((0)),
[YTDContacts] [int] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_NumOf1YrContacts] DEFAULT ((0)),
[YTDContactsBinID] [tinyint] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_YTDContactsBinID] DEFAULT ((0)),
[YTDCatalogContacts] [int] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_NumOf1YrCatalogContacts] DEFAULT ((0)),
[YTDCatalogContactsBinID] [tinyint] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_YTDCatalogContactsBinID] DEFAULT ((0)),
[YTDSwampSpContacts] [int] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_NumOf1YrSwampSpContacts] DEFAULT ((0)),
[YTDSwampSpContactsBinID] [tinyint] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_YTDSwampSpContactsBinID] DEFAULT ((0)),
[YTDNLContacts] [int] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_NumOf1YrNLContacts] DEFAULT ((0)),
[YTDNLContactsBinID] [tinyint] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_YTDNLContactsBinID] DEFAULT ((0)),
[YTDMagalogContacts] [int] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_NumOfMagalogContacts] DEFAULT ((0)),
[YTDMagalogContactsBinID] [tinyint] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_YTDMagalogContactsBinID] DEFAULT ((0)),
[PurchAmountSubsqMth] [money] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_PurchAmountSubsqMth] DEFAULT ((0)),
[PurchasesSubsqMth] [int] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_PurchasesSubsqMth] DEFAULT ((0)),
[CoupnsRedmSubsqMth] [int] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_CoupnsRedmSubsqMth] DEFAULT ((0)),
[NewCoursePurchSubsqMth] [int] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_NewCoursePurchSubsqMth] DEFAULT ((0)),
[EMResponsesSubsqMth] [int] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_EMResponsesSubsqMth] DEFAULT ((0)),
[ContactsSubsqMth] [int] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_ContactsSubsequentMth] DEFAULT ((0)),
[CostContactsSubsqMth] [money] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_CostContactsSubsqMth] DEFAULT ((0)),
[CatalogContactsSubsqMth] [int] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_CatalogContactsSubsequentMth] DEFAULT ((0)),
[CostCatalogContactsSubsqMth] [money] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_CostCatalogContactsSubsqMth] DEFAULT ((0)),
[MagalogContactsSubsqMth] [int] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_MagalogContactsSubsequentMth] DEFAULT ((0)),
[CostMagalogContactsSubsqMth] [money] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_CostMagalogContactsSubsqMth] DEFAULT ((0)),
[NLContactsSubsqMth] [int] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_NLContactsSubsequentMth] DEFAULT ((0)),
[CostNLContactsSubsqMth] [money] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_CostNLContactsSubsqMth] DEFAULT ((0)),
[SwampSpContactsSubsqMth] [int] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_SwampSpContactsSubsequentMth] DEFAULT ((0)),
[CostSwampSpContactsSubsqMth] [money] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_CostSwampSpContactsSubsqMth] DEFAULT ((0)),
[MagazineContactsSubsqMth] [int] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_MagazineContactsSubsqMth] DEFAULT ((0)),
[CostMagazineContactsSubsqMth] [money] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_CostMagazineContactsSubsqMth] DEFAULT ((0)),
[LTDNewCourseSales] [money] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_LTDNewCourseSales] DEFAULT ((0)),
[NewCourseSalesSubsqMth] [money] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_NewCourseSalesSubsqMth] DEFAULT ((0)),
[YTDMagazinePurch] [int] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_YTDMagazinePurch] DEFAULT ((0)),
[YTDMagazineContacts] [int] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_YTDMagazineContacts] DEFAULT ((0)),
[YTDMagazineContactsBinID] [tinyint] NOT NULL CONSTRAINT [DF_TempCustomerDynamic_YTDMagazineContactsBinID] DEFAULT ((0)),
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
[CustomerSegmentFnlID] [int] NULL
) ON [PRIMARY]
GO
