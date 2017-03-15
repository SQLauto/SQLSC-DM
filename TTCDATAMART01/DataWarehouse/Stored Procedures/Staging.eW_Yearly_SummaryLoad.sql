SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create PROCEDURE [Staging].[eW_Yearly_SummaryLoad]
	
AS
	declare 
    	@SQLStatement nvarchar(1000),
    	@CCSTbl varchar(100),
    	@CDCRTbl varchar(100),
    	@StartDateVar varchar(20)
BEGIN
    set nocount on
        
    if object_id('Staging.eW_YTD_FY_YOY_SummaryTemp') is not null drop table Staging.eW_YTD_FY_YOY_SummaryTemp
    
	SELECT  AsOfDate, AsOfYear, AsOfMonth,
		CustomerSegment, Frequency, NewSeg, Name,
		A12mf, FlagEmailable, --FlagEmailPref, FlagValidEmail,
		FlagMail, Gender, SubjectCategoryPref2, --SubjectCategoryPref,
		R3OrderSourcePref, R3FormatMediaPref, 
		LTDAvgOrderBin, DSLPurchBin,
		TTB_Bin, Agebin,  TenureBin, eWGroup,
		Education, HouseHoldIncomeBin, 
		Region, countryCode,
		IntlYear, IntlMonth, IntlSubjectPref,
		IntlFormatMediaPref, IntlOrderSource, 
		IntlPromotionTypeID, IntlPromotionType,
		IntlAvgOrderBin, SubjectPref2_EOY,			-- Added on 9/18/2013  -- PR
		FlagBoughtDigitlBfr, SalesBinPriorYr,CourseCntBinPriorYr,
		FlagEngagedCust, FlagPrEmailOrder,
		--FlagPurchYTD,    -- PR 12/3/2013 changed this to be a measure instead of group by variable as per Amit's request
		NwCrsBinYTD, --Crs995BinYTD,
		-- FlagPurchFY,  -- PR 12/3/2013 changed this to be a measure instead of group by variable as per Amit's request
		count(CustomerID) TotalCustomers,
		sum(PurchAmountYTD) PurchAmountYTD,
		sum(PurchasesYTD) PurchasesYTD,
		sum(UnitsPurchYTD) UnitsPurchYTD,
		sum(PartsPurchYTD) PartsPurchYTD,
		sum(EmailSalesYTD) EmailSalesYTD,
		sum(EmailOrdersYTD) EmailOrdersYTD,
		sum(WebSalesYTD) WebSalesYTD,
		sum(WebOrdersYTD) WebOrdersYTD,	
		sum(MailContactsYTD) MailContactsYTD,
		sum(EmailContactsYTD) EmailContactsYTD,	
		SUM(FlagPurchYTD) BuyersYTD,
		
		sum(PurchAmountFY) PurchAmountFY,
		sum(PurchasesFY) PurchasesFY,
		sum(UnitsPurchFY) UnitsPurchFY,
		sum(PartsPurchFY) PartsPurchFY,
		sum(EmailSalesFY) EmailSalesFY,
		sum(EmailOrdersFY) EmailOrdersFY,
		sum(WebSalesFY) WebSalesFY,
		sum(WebOrdersFY) WebOrdersFY,	
		sum(MailContactsFY) MailContactsFY,
		sum(EmailContactsFY) EmailContactsFY,	
		SUM(FlagPurchFY) BuyersFY,		
			
		SUM(CatalogSalesYTD) as CatalogSalesYTD,
		SUM(CatalogOrdersYTD) as CatalogOrdersYTD,
		SUM(MagalogSalesYTD) as MagalogSalesYTD,
		SUM(MagalogOrdersYTD) as MagalogOrdersYTD,
		SUM(Mag7SalesYTD) as Mag7SalesYTD,
		SUM(Mag7OrdersYTD) as Mag7OrdersYTD,
		SUM(MagazineSalesYTD) as MagazineSalesYTD,
		SUM(MagazineOrdersYTD) as MagazineOrdersYTD,
		SUM(LetterSalesYTD) as LetterSalesYTD,
		SUM(LetterOrdersYTD) as LetterOrdersYTD,
		SUM(MagbackSalesYTD) as MagbackSalesYTD,
		SUM(MagbackOrdersYTD) as MagbackOrdersYTD,
		SUM(ReactivationSalesYTD) as ReactivationSalesYTD,
		SUM(ReactivationOrdersYTD) as ReactivationOrdersYTD,
		SUM(EmailDLRSalesYTD) as EmailDLRSalesYTD,
		SUM(EmailDLROrdersYTD) as EmailDLROrdersYTD,
		SUM(EmailRevGenSalesYTD) as EmailRevGenSalesYTD,
		SUM(EmailRevGenOrdersYTD) as EmailRevGenOrdersYTD,
		SUM(OtherSalesYTD) as OtherSalesYTD,
		SUM(OtherOrdersYTD) as OtherOrdersYTD,
		sum(CDSalesYTD) as CDSalesYTD,
		sum(CDOrdersYTD) as CDOrdersYTD,
		sum(DVDSalesYTD) as DVDSalesYTD,
		sum(DVDOrdersYTD) as DVDOrdersYTD,
		sum(VDLSalesYTD) as VDLSalesYTD,
		sum(VDLOrdersYTD) as VDLOrdersYTD,
		sum(ADLSalesYTD) as ADLSalesYTD,
		sum(ADLOrdersYTD) as ADLOrdersYTD,
		sum(TranscriptSalesYTD) as TranscriptSalesYTD,
		sum(TranscriptOrdersYTD) as TranscriptOrdersYTD
				
	into staging.eW_YTD_FY_YOY_SummaryTemp
	from Datawarehouse.Marketing.eW_YTD_FY_YOY_BaseTable
	group by AsOfDate, AsOfYear, AsOfMonth,
		CustomerSegment, Frequency, NewSeg, Name,
		A12mf, FlagEmailable, --FlagEmailPref, FlagValidEmail,
		FlagMail, Gender, SubjectCategoryPref2, --SubjectCategoryPref,
		R3OrderSourcePref, R3FormatMediaPref, 
		LTDAvgOrderBin, DSLPurchBin,
		TTB_Bin, Agebin,  TenureBin, eWGroup,
		Education, HouseHoldIncomeBin, 
		Region, countrycode,
		IntlYear, IntlMonth, IntlSubjectPref,
		IntlFormatMediaPref, IntlOrderSource, 
		IntlPromotionTypeID, IntlPromotionType,
		IntlAvgOrderBin, SubjectPref2_EOY,  -- Added on 9/18/2013  -- PR
		FlagBoughtDigitlBfr, SalesBinPriorYr, CourseCntBinPriorYr,
		FlagEngagedCust, FlagPrEmailOrder,
		NwCrsBinYTD 

	Truncate table datawarehouse.Marketing.eW_YTD_FY_YOY_Summary	
	
	insert into datawarehouse.Marketing.eW_YTD_FY_YOY_Summary	
	select * from staging.eW_YTD_FY_YOY_SummaryTemp		
			
END
GO
