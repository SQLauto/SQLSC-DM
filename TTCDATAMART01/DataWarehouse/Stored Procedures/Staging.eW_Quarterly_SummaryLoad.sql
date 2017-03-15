SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Staging].[eW_Quarterly_SummaryLoad]
	
AS

/*
--Name: [Staging].[eW_Quarterly_SummaryLoad]
--Purpose: Creates summary table for quarterly cohort analysis
--Parameters: None
--Update Inforamtion: 
--		New			Preethi Ramanujam			8/5/2014
--
*/	

	declare 
    	@SQLStatement nvarchar(1000),
    	@CCSTbl varchar(100),
    	@CDCRTbl varchar(100),
    	@StartDateVar varchar(20)
BEGIN
    set nocount on
        
    if object_id('Staging.eW_Quarterly_YOY_SummaryTemp') is not null drop table Staging.eW_Quarterly_YOY_SummaryTemp
    
	SELECT  AsOfDate, AsOfYear, AsOfQuarter,
		CustomerSegment, Frequency, NewSeg, Name,
		A12mf, CustomerSegment2, CustomerSegmentFnl,
		FlagEmailable, 
		FlagMail, Gender, SubjectCategoryPref2, 
		R3OrderSourcePref, R3FormatMediaPref, 
		LTDAvgOrderBin, LTDAvgOrderBin2, DSLPurchBin,
		TTB_Bin, Agebin,  TenureBin, eWGroup,
		EducationBin, HouseHoldIncomeBin, 
		Region, countryCode,
		
		IntlYear, IntlMonth, IntlSubjectPref,
		IntlFormatMediaPref, IntlOrderSource, 
		IntlMD_Audience,
		IntlMD_ChannelID, IntlMD_Channel,
		IntlMD_PromotionTypeID, IntlMD_PromotionType,
		IntlMD_CampaignID, IntlMD_Campaign,
		IntlMD_PriceType,
		IntlPromotionTypeID, IntlPromotionType,
		IntlAvgOrderBin, 
		
		FlagBoughtDigitlBfr, SalesBinPr12Mnth, 
		CourseCntBinPr12Mnth,
		FlagEngagedCust, FlagPrEmailOrder,
		
		count(CustomerID) TotalCustomers,
		sum(PurchAmountQTR) PurchAmountQTR,
		sum(PurchasesQTR) PurchasesQTR,
		sum(UnitsPurchQTR) UnitsPurchQTR,
		sum(PartsPurchQTR) PartsPurchQTR,
		sum(EmailSalesQTR) EmailSalesQTR,
		sum(EmailOrdersQTR) EmailOrdersQTR,
		sum(WebSalesQTR) WebSalesQTR,
		sum(WebOrdersQTR) WebOrdersQTR,	
		sum(MailContactsQTR) MailContactsQTR,
		sum(EmailContactsQTR) EmailContactsQTR,	
		SUM(FlagPurchQTR) BuyersQTR
				
	into staging.eW_Quarterly_YOY_SummaryTemp
	from Datawarehouse.Marketing.eW_QTR_BaseTable
	group by AsOfDate, AsOfYear, AsOfQuarter,
		CustomerSegment, Frequency, NewSeg, Name,
		A12mf, CustomerSegment2, CustomerSegmentFnl,
		FlagEmailable, 
		FlagMail, Gender, SubjectCategoryPref2, 
		R3OrderSourcePref, R3FormatMediaPref, 
		LTDAvgOrderBin, LTDAvgOrderBin2, DSLPurchBin,
		TTB_Bin, Agebin,  TenureBin, eWGroup,
		EducationBin, HouseHoldIncomeBin, 
		Region, countryCode,
		
		IntlYear, IntlMonth, IntlSubjectPref,
		IntlFormatMediaPref, IntlOrderSource, 
		IntlMD_Audience,
		IntlMD_ChannelID, IntlMD_Channel,
		IntlMD_PromotionTypeID, IntlMD_PromotionType,
		IntlMD_CampaignID, IntlMD_Campaign,
		IntlMD_PriceType,
		IntlPromotionTypeID, IntlPromotionType,
		IntlAvgOrderBin, 
		
		FlagBoughtDigitlBfr, SalesBinPr12Mnth, 
		CourseCntBinPr12Mnth,
		FlagEngagedCust, FlagPrEmailOrder
		
			
	Truncate table datawarehouse.Marketing.eW_QTR_YOY_Summary	
	
	insert into datawarehouse.Marketing.eW_QTR_YOY_Summary	
	select * from staging.eW_Quarterly_YOY_SummaryTemp		
	
    if object_id('Staging.eW_Quarterly_YOY_SummaryTemp') is not null drop table Staging.eW_Quarterly_YOY_SummaryTemp
			
END
GO
