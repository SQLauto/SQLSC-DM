SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE    PROCEDURE [Staging].[spUpdateBinInfo] /*'1/1/2004'*/
	@AsOfDate DATETIME
AS

/* PR - 11/30/2007 - Added to include MagazineContactBinID*/
	
	UPDATE Staging.TempDMCustomerDynamic
	SET LTDAvgOrderBinID = 
		CASE 	WHEN LTDAvgOrd < 100 THEN 1
			WHEN LTDAvgOrd BETWEEN 100 AND 220 THEN 2
			WHEN LTDAvgOrd > 220 THEN 3
		END
	WHERE AsOfDate = @AsOfDate

	UPDATE DMC
	SET DMC.DSLCouponRedmBinID = BD.BinID
	FROM Staging.TempDMCustomerDynamic DMC, MarketingCubes.dbo.BinDSLCouponRedeemed BD	
	WHERE DMC.DSLCouponRedm BETWEEN BD.MinLevel AND BD.MaxLevel 
	AND DMC.AsOfDate = @AsOfdate
    
	UPDATE DMC
	SET DMC.DSLEMResponseBinID = BD.BinID
	FROM Staging.TempDMCustomerDynamic DMC, MarketingCubes.dbo.BinDSLEMResponse BD	
	WHERE DMC.DSLEMResponse BETWEEN BD.MinLevel AND BD.MaxLevel
	AND DMC.AsOfDate = @AsOfdate
	
	UPDATE DMC
	SET DMC.DSLNewCoursePurchBinID = BD.BinID
	FROM Staging.TempDMCustomerDynamic DMC, MarketingCubes.dbo.BinDSLNewCoursePurchased BD	
	WHERE DMC.DSLNewCoursePurch BETWEEN BD.MinLevel AND BD.MaxLevel
	AND DMC.AsOfDate = @AsOfdate
	
	UPDATE DMC
	SET DMC.DSLPurchaseBinID = BD.BinID
	FROM Staging.TempDMCustomerDynamic DMC, MarketingCubes.dbo.BinDSLPurchases BD	
	WHERE DMC.DSLPurchase BETWEEN BD.MinLevel AND BD.MaxLevel
	AND DMC.AsOfDate = @AsOfdate
	
	UPDATE DMC
	SET DMC.LTDCouponsRedmBinID = BD.BinID
	FROM Staging.TempDMCustomerDynamic DMC, MarketingCubes.dbo.BinLTDCouponsRedeemed BD	
	WHERE DMC.LTDCouponsRedm BETWEEN BD.MinLevel AND BD.MaxLevel
	AND DMC.AsOfDate = @AsOfdate
	
	UPDATE DMC
	SET DMC.LTDEMResponsesBinID = BD.BinID
	FROM Staging.TempDMCustomerDynamic DMC, MarketingCubes.dbo.BinLTDEMResponses BD	
	WHERE DMC.LTDEMResponses BETWEEN BD.MinLevel AND BD.MaxLevel
	AND DMC.AsOfDate = @AsOfdate
	
	UPDATE DMC
	SET DMC.LTDNewCoursePurchBinID = BD.BinID
	FROM Staging.TempDMCustomerDynamic DMC, MarketingCubes.dbo.BinLTDNewCoursePurchased BD	
	WHERE DMC.LTDNewCoursesPurch BETWEEN BD.MinLevel AND BD.MaxLevel
	AND DMC.AsOfDate = @AsOfdate
	
	UPDATE DMC
	SET DMC.LTDPurchasesBinID = BD.BinID
	FROM Staging.TempDMCustomerDynamic DMC, MarketingCubes.dbo.BinLTDPurchases BD	
	WHERE DMC.LTDPurchases BETWEEN BD.MinLevel AND BD.MaxLevel
	AND DMC.AsOfDate = @AsOfdate
	
	UPDATE DMC
	SET DMC.LTDReturnsBinID = BD.BinID
	FROM Staging.TempDMCustomerDynamic DMC, MarketingCubes.dbo.BinLTDReturns BD	
	WHERE DMC.LTDItemsReturned BETWEEN BD.MinLevel AND BD.MaxLevel
	AND DMC.AsOfDate = @AsOfdate
	
	UPDATE DMC
	SET DMC.TenureDaysBinID = BD.BinID
	FROM Staging.TempDMCustomerDynamic DMC, MarketingCubes.dbo.BinTenureDays BD	
	WHERE DMC.TenureDays BETWEEN BD.MinLevel AND BD.MaxLevel
	AND DMC.AsOfDate = @AsOfdate
	
	UPDATE DMC
	SET DMC.YTDCatalogContactsBinID = BD.BinID
	FROM Staging.TempDMCustomerDynamic DMC, MarketingCubes.dbo.BinYTDCatalogContacts BD	
	WHERE DMC.YTDCatalogContacts BETWEEN BD.MinLevel AND BD.MaxLevel
	AND DMC.AsOfDate = @AsOfdate
	
	UPDATE DMC
	SET DMC.YTDContactsBinID = BD.BinID
	FROM Staging.TempDMCustomerDynamic DMC, MarketingCubes.dbo.BinYTDContacts BD	
	WHERE DMC.YTDContacts BETWEEN BD.MinLevel AND BD.MaxLevel
	AND DMC.AsOfDate = @AsOfdate
	
	UPDATE DMC
	SET DMC.YTDMagalogContactsBinID = BD.BinID
	FROM Staging.TempDMCustomerDynamic DMC, MarketingCubes.dbo.BinYTDMagalogContacts BD	
	WHERE DMC.YTDMagalogContacts BETWEEN BD.MinLevel AND BD.MaxLevel
	AND DMC.AsOfDate = @AsOfdate
	
	UPDATE DMC
	SET DMC.YTDSwampSpContactsBinID = BD.BinID
	FROM Staging.TempDMCustomerDynamic DMC, MarketingCubes.dbo.BinYTDSwampSpContacts BD	
	WHERE DMC.YTDSwampSpContacts BETWEEN BD.MinLevel AND BD.MaxLevel
	AND DMC.AsOfDate = @AsOfdate

/* PR - 11/30/2007 - Added to include MagazineContactBinID. */
	UPDATE DMC
	SET DMC.YTDMagazineContactsBinID = BD.BinID
	FROM Staging.TempDMCustomerDynamic DMC, MarketingCubes.dbo.BinYTDMagazineContacts BD	
	WHERE DMC.YTDMagazineContacts BETWEEN BD.MinLevel AND BD.MaxLevel
	AND DMC.AsOfDate = @AsOfdate
GO
