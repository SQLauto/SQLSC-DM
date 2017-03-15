SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create PROCEDURE [Staging].[LoadDMCustomerDynamic90s]
	@AsOfDate date = null
as
	declare 
    	@CustomerID udtCustomerID = null,
    	@AsOfDateLoc date
begin
	set nocount on
    
    truncate table Staging.TempDMCustomerDynamic
    
    set @AsOfDate = coalesce(@AsOfDate, getdate())
    set @AsOfDateLoc = @AsOfDate

	INSERT INTO Staging.TempDMCustomerDynamic 
    (
    	CustomerID, 
        AsOfDate, 
        AsOfMonth, 
        AsOfYear
    )
	SELECT DISTINCT 
    	oi.CustomerID, 
        @AsOfDateLoc, 
        DATEPART(MM, @AsOfDateLoc), 
        DATEPART(YY, @AsOfDateLoc)
	FROM Marketing.DMPurchaseOrderItems oi (nolock)
   /* join Marketing.DMPurchaseOrders o on o.OrderID = oi.OrderID*/
	WHERE cast(oi.DateOrdered as date) < @AsOfDateLoc 
    
	/* Update Org, Gender, FlagMailableCollegeBuyer*/
	UPDATE TCD
		SET TCD.OrganizationID = DCS.OrganizationID,
			TCD.Gender = DCS.Gender,
			TCD.FlagMailableCollegeBuyerSS = DCS.FlagMailableCollegeBuyer
/*		FROM TempCustomerDynamic TCD INNER JOIN DMCustomerStatic DCS -- PR changed this to get the information from Signature table -- 7/26/2010*/
/*																	 -- That way, we can run the CustomerDyanmic table and then update the static table.*/
		FROM Staging.TempDMCustomerDynamic TCD INNER JOIN 
			(SELECT CustomerID, Gender, 
				CASE WHEN publiclibrary = 1 THEN 1
					WHEN OtherInstitution = 1 THEN 2
					ELSE 0
					END AS OrganizationID,
				CASE WHEN buyertype > 3 and flagmail = 1 THEN 1
					ELSE 0
					END AS FlagMailableCollegebuyer
			FROM Marketing.CampaignCustomerSignature (nolock)) DCS
		ON TCD.CustomerID = DCS.CustomerID

	/* Update LTDPurchAmount, LTDAvgOrd*/
	UPDATE TCD
	SET TCD.LTDPurchAmount = T.FS,
		TCD.LTDAvgOrd = CONVERT(FLOAT, T.FS)/CONVERT(FLOAT, T.O)
	FROM Staging.TempDMCustomerDynamic TCD
    join (SELECT CustomerID, SUM(FinalSales) FS, COUNT(OrderID) O
		FROM Marketing.DMPurchaseOrders (nolock)
		WHERE cast(DateOrdered as date) < @AsOfDateLoc AND
			FinalSales < 1500
		GROUP BY CustomerID) T on TCD.CustomerID = T.CustomerID	

	-- <Order Source>        
	UPDATE Staging.TempDMCustomerDynamic
	SET LTDOrderSource = 'MS' 
	WHERE CustomerID IN
    (
        SELECT CustomerID
        FROM Staging.vwOrders (nolock) 
        GROUP BY CustomerID 
        HAVING COUNT(distinct OrderSource) > 1    
    )  
        
	update cd
	set cd.R3OrderSource = sp.OrderSource
    from Staging.TempDMCustomerDynamic cd
    join Staging.vwCustomerOrderSourcePreferences sp (nolock) on sp.CustomerID = cd.CustomerID
	where 
    	sp.RankNum = 1
    
	update cd
	set cd.LTDOrderSource = sp.OrderSource
    from Staging.TempDMCustomerDynamic cd
    join Staging.vwCustomerOrderSourcePreferences sp (nolock) on sp.CustomerID = cd.CustomerID
	where 
    	sp.RankNum = 1
        and cd.LTDOrderSource = 'X'
	-- </Order Source>                
        
	/* Format Media Calculations*/
	UPDATE Staging.TempDMCustomerDynamic 
	SET LTDFormatMediaCat = 'M' 
	WHERE CustomerID IN 
    (
    	SELECT CustomerID 
        FROM Staging.GetCustomerFormatMedia(@AsOfDateLoc)
		GROUP BY CustomerID
		HAVING COUNT(CustomerID) > 1
	)

	UPDATE  TCD
	SET LTDFormatMediaCat = 'HM'
	FROM Staging.TempDMCustomerDynamic TCD
    join Staging.GetCustomerFormatMedia(@AsOfDateLoc) fm on fm.CustomerID = tcd.CustomerID
	WHERE 	
    	TCD.LTDFormatMediaCat = 'M' 
        AND FM.FormatMedia = 'H'
    
	update cd
	set cd.LTDFormatMediaCat = cp.FormatMedia
    from Staging.TempDMCustomerDynamic cd
    join Staging.vwCustomerFormatMediaPreferences cp (nolock) on cp.CustomerID = cd.CustomerID
	where 
    	cp.RankNum = 1
        and cd.LTDFormatMediaCat = 'X'
        
	update cd
	set cd.R3FormatMediaPref = cp.FormatMedia
    from Staging.TempDMCustomerDynamic cd
    join Staging.vwCustomerFormatMediaPreferences cp (nolock) on cp.CustomerID = cd.CustomerID
	where 
    	cp.RankNum = 1

	/* FormatAV Calculations */
	UPDATE Staging.TempDMCustomerDynamic 
	SET LTDFormatAVCat = 'M' 
	WHERE CustomerID IN 
    (
    	SELECT CustomerID 
        FROM Staging.GetCustomerFormatAV(@AsOfDateLoc)
		GROUP BY CustomerID
		HAVING COUNT(CustomerID) > 1
	)
    
	UPDATE TCD
	SET LTDFormatAVCat = 'HM'
	FROM Staging.TempDMCustomerDynamic TCD
    join Staging.GetCustomerFormatAV(@AsOfDateLoc) fm on fm.CustomerID = tcd.CustomerID
	WHERE 
    	TCD.LTDFormatAVCat = 'M' AND
		FM.FormatAV = 'HS'
        
	update cd
	set cd.LTDFormatAVCat = cp.FormatAV
    from Staging.TempDMCustomerDynamic cd
    join Staging.vwCustomerFormatAVPreferences (nolock) cp on cp.CustomerID = cd.CustomerID
	where 
    	cp.RankNum = 1
        and cd.LTDFormatAVCat = 'X'
        
	update cd
	set cd.R3FormatAVPref = cp.FormatAV
    from Staging.TempDMCustomerDynamic cd
    join Staging.vwCustomerFormatAVPreferences (nolock) cp on cp.CustomerID = cd.CustomerID
	where 
    	cp.RankNum = 1
        
	/* FormatAD Calculations */
	UPDATE Staging.TempDMCustomerDynamic 
	SET LTDFormatADCat = 'M' 
	WHERE CustomerID IN 
    (
    	SELECT CustomerID 
        FROM Staging.GetCustomerFormatAD(@AsOfDateLoc)
		GROUP BY CustomerID
		HAVING COUNT(CustomerID) > 1
	)
    
	UPDATE TCD
	SET LTDFormatADCat = 'HM'
	FROM Staging.TempDMCustomerDynamic TCD
    join Staging.GetCustomerFormatAD(@AsOfDateLoc) fm on fm.CustomerID = tcd.CustomerID
	WHERE 
    	TCD.LTDFormatADCat = 'M' AND
		FM.FormatAD = 'HS'
    
	update cd
	set cd.LTDFormatADCat = cp.FormatAD
    from Staging.TempDMCustomerDynamic cd
    join Staging.vwCustomerFormatADPreferences cp (nolock) on cp.CustomerID = cd.CustomerID
	where 
    	cp.RankNum = 1
        and cd.LTDFormatADCat = 'X'
        
	update cd
	set cd.R3FormatADPref = cp.FormatAD
    from Staging.TempDMCustomerDynamic cd
    join Staging.vwCustomerFormatADPreferences cp (nolock) on cp.CustomerID = cd.CustomerID
	where 
    	cp.RankNum = 1
        
	/* Subject Category Calculations        */

	UPDATE Staging.TempDMCustomerDynamic 
	SET LTDSubjectCat = 'M' 
	WHERE CustomerID IN 
    (
    	SELECT CustomerID 
        FROM Staging.GetCustomerSubjectCategory(@AsOfDateLoc)
		GROUP BY CustomerID
		HAVING COUNT(CustomerID) > 1
	)
    
	UPDATE TCD
	SET LTDSubjectCat = 'HM'
	FROM Staging.TempDMCustomerDynamic TCD
    join Staging.GetCustomerSubjectCategory(@AsOfDateLoc) fm on fm.CustomerID = tcd.CustomerID
	WHERE 
    	TCD.LTDSubjectCat = 'M' AND
		FM.SubjectCategory = 'HS'

	update cd
	set cd.LTDSubjectCat = cp.SubjectCategory
    from Staging.TempDMCustomerDynamic cd
    join Staging.vwCustomerSubjectCategoryPreferences cp (nolock) on cp.CustomerID = cd.CustomerID
	where 
    	cp.RankNum = 1
        and cd.LTDSubjectCat = 'X'
        
	update cd
	set cd.R3SubjectPref = cp.SubjectCategory
    from Staging.TempDMCustomerDynamic cd
    join Staging.vwCustomerSubjectCategoryPreferences cp (nolock) on cp.CustomerID = cd.CustomerID
	where 
    	cp.RankNum = 1
        
    /* Load NoOfCouponsRedeemed */
	UPDATE TCD
	SET LTDCouponsRedm = T.CntCoupons,
		TCD.DSLCouponRedm = DATEDIFF(DD, T.MaxCouponDate, @AsOfDateLoc)
		FROM Staging.TempDMCustomerDynamic TCD INNER JOIN 
		(SELECT OI.CustomerID, COUNT(OI.StockItemID) CntCoupons, MAX(DateOrdered) As MaxCouponDate
		FROM Staging.vwOrders O (nolock) INNER JOIN Staging.vwOrderItems OI (nolock)
			ON O.OrderID = OI.OrderID INNER JOIN Mapping.DMCouponList DL (nolock)
			ON OI.StockItemID = DL.UserStockItemID AND	
			DL.FlagCoupon = 1 WHERE 
			cast(O.DateOrdered as date) < @AsOfDateLoc
			GROUP BY OI.CustomerID) T
			ON TCD.CustomerID = T.CustomerID
    
    /* Load No. Of Returns */
    UPDATE TCD
	SET  LTDItemsReturned = T.CntReturn
	FROM Staging.TempDMCustomerDynamic TCD INNER JOIN
	(
    	SELECT o.CustomerID, COUNT(FlagReturn) As CntReturn
		FROM Marketing.DMPurchaseOrderItems oi (nolock)
		join Staging.vwOrders o (nolock) on o.OrderID = oi.OrderID
		WHERE 	FlagReturn = 1 AND
			cast(o.DateOrdered as date) < @AsOfDateLoc 
		GROUP BY o.CustomerID
    ) T ON TCD.CustomerID = T.CustomerID
    
	/* Load Num of EMailResponses    */
	UPDATE TCD
		SET LTDEMResponses = T.CC,
			DSLEMResponse = DATEDIFF(DD, T.MaxDateOrdered, @AsOfDateLoc)
	FROM Staging.TempDMCustomerDynamic TCD INNER JOIN
	(
    	SELECT CustomerID, COUNT(DPO.CatalogCode) As CC, MAX(cast(DPO.DateOrdered as date)) As MaxDateOrdered
		FROM Marketing.DMPurchaseOrders DPO (nolock) INNER JOIN Mapping.DMPromotionType DPT (nolock)
		ON DPO.CatalogCode = DPT.CatalogCode WHERE
		DPT.Category = 'E-Campaign' AND
		cast(DPO.DateOrdered as date) < @AsOfDateLoc
		GROUP BY CustomerID
    ) T ON 
		TCD.CustomerID = T.CustomerID
        
	/* Load Num Of New Courses Purchased        */
	UPDATE TCD
	SET LTDNewCoursesPurch = T.CntNewCourse,
		LTDNewCourseSales = T.TotalNewCourseSales,  /* PR -- Added new course sales information for cube (11/16/2007)*/
		DSLNewCoursePurch = DATEDIFF(DD, T.MaxDateOrdered, @AsOfDateLoc)
	FROM Staging.TempdmCustomerDynamic TCD INNER JOIN
	(
    	SELECT o.CustomerID, COUNT(FlagNewCourse) As CntNewCourse, MAX(cast(o.DateOrdered as date)) As MaxDateOrdered, 
		SUM(TotalSales) AS TotalNewCourseSales /* PR -- Added new course sales information for cube (11/16/2007)*/
		FROM Marketing.DMPurchaseOrderItems oi (nolock)
        join Marketing.DMPurchaseOrders o (nolock) on o.OrderID = oi.OrderID
		WHERE 	FlagNewCourse = 1 AND
			cast(o.DateOrdered as date) < @AsOfDateLoc AND
			TotalSales < 1500 /* PR -- Added this to for new course sales information (11/16/2007)*/
		GROUP BY o.CustomerID
    ) T ON
	TCD.CustomerID = T.CustomerID

	/* Load YTD Purchase Information    */
	UPDATE TCD
    SET YTDPurchases = T.Cnt1YearContacts
    FROM Staging.TempDMCustomerDynamic TCD INNER JOIN  
    (
        SELECT CustomerID, COUNT(DPO.CatalogCode) As Cnt1YearContacts
        FROM Marketing.DMPurchaseOrders DPO (nolock)
            INNER JOIN 
            Mapping.DMPromotionType DP (nolock) ON DPO.CatalogCode = DP.CatalogCode
            WHERE (cast(DPO.DateOrdered as date) >= DATEADD(YY, -1, @AsOfDateLoc) AND cast(DPO.DateOrdered as date) < @AsOfDateLoc)
            GROUP BY CustomerID
    ) T
    ON TCD.CustomerID = T.CustomerID 
    
	UPDATE TCD
		SET YTDCatalogPurch = T.Cnt1YearCatalogContacts
		FROM Staging.TempDMCustomerDynamic TCD INNER JOIN  
			(
            SELECT CustomerID, COUNT(DPO.CatalogCode) As Cnt1YearCatalogContacts
			FROM Marketing.DMPurchaseOrders DPO (nolock)
				INNER JOIN 
				Mapping.DMPromotionType DP (nolock) ON DPO.CatalogCode = DP.CatalogCode
				WHERE (cast(DPO.DateOrdered as date) >= DATEADD(YY, -1, @AsOfDateLoc) AND cast(DPO.DateOrdered as date) < @AsOfDateLoc)
					AND DP.PromotionType = 'Catalog' GROUP BY CustomerID
                    ) T
		ON TCD.CustomerID = T.CustomerID 

	UPDATE TCD
		SET YTDSwampSpPurch = T.Cnt1YearSwampSpContacts
		FROM Staging.TempDMCustomerDynamic TCD INNER JOIN  
			(
            SELECT CustomerID, COUNT(DPO.CatalogCode) As Cnt1YearSwampSpContacts
			FROM Marketing.DMPurchaseOrders DPO (nolock)
				INNER JOIN 
				Mapping.DMPromotionType DP (nolock) ON DPO.CatalogCode = DP.CatalogCode
				WHERE (cast(DPO.DateOrdered as date) >= DATEADD(YY, -1, @AsOfDateLoc) AND cast(DPO.DateOrdered as date) < @AsOfDateLoc)
					AND DP.PromotionType = 'SwampSpecific' GROUP BY CustomerID
                    ) T
		ON TCD.CustomerID = T.CustomerID 

	UPDATE TCD
		SET YTDNLPurch = T.Cnt1YearNLContacts
		FROM Staging.TempDMCustomerDynamic TCD INNER JOIN  
			(
            SELECT CustomerID, COUNT(DPO.CatalogCode) As Cnt1YearNLContacts
			FROM Marketing.DMPurchaseOrders DPO (nolock)
				INNER JOIN 
				Mapping.DMPromotionType DP (nolock) ON DPO.CatalogCode = DP.CatalogCode
				WHERE (cast(DPO.DateOrdered as date) >= DATEADD(YY, -1, @AsOfDateLoc) AND cast(DPO.DateOrdered as date) < @AsOfDateLoc)
					AND DP.PromotionType = 'Newsletter' GROUP BY CustomerID
                    ) T
		ON TCD.CustomerID = T.CustomerID 

	UPDATE TCD
		SET YTDMagalogPurch = T.Cnt1YearMagalogContacts
		FROM Staging.TempDMCustomerDynamic TCD INNER JOIN  
			(
            SELECT CustomerID, COUNT(DPO.CatalogCode) As Cnt1YearMagalogContacts
			FROM Marketing.DMPurchaseOrders DPO (nolock)
				INNER JOIN 
				Mapping.DMPromotionType DP (nolock) ON DPO.CatalogCode = DP.CatalogCode
				WHERE (cast(DPO.DateOrdered as date) >= DATEADD(YY, -1, @AsOfDateLoc) AND cast(DPO.DateOrdered as date) < @AsOfDateLoc)
					AND DP.PromotionType = 'Magalog' GROUP BY CustomerID
                    ) T
		ON TCD.CustomerID = T.CustomerID 

/* PR - Added for Magazine updates - 11/30/2007 (But was commented until new columns were added to the table)*/
	UPDATE TCD
		SET YTDMagazinePurch = T.Cnt1YearMagazineContacts
		FROM Staging.TempDMCustomerDynamic TCD INNER JOIN  
			(
            SELECT CustomerID, COUNT(DPO.CatalogCode) As Cnt1YearMagazineContacts
			FROM Marketing.DMPurchaseOrders DPO (nolock)
				INNER JOIN 
				Mapping.DMPromotionType DP (nolock) ON DPO.CatalogCode = DP.CatalogCode
				WHERE (cast(DPO.DateOrdered as date) >= DATEADD(YY, -1, @AsOfDateLoc) AND cast(DPO.DateOrdered as date) < @AsOfDateLoc)
					AND DP.PromotionType = 'Magazine' GROUP BY CustomerID
                    ) T
		ON TCD.CustomerID = T.CustomerID 
   
	/* Load YTD Contact Information*/
	UPDATE TCD
		SET YTDContacts = T.Cnt1YearContacts
		FROM Staging.TempDMCustomerDynamic TCD INNER JOIN  
			(
            SELECT CustomerID, COUNT(MH.AdCode) As Cnt1YearContacts
			FROM Archive.MailingHistory MH (nolock)
				INNER JOIN Staging.MktAdCodes MAC (nolock) ON 
				MH.AdCode = MAC.AdCode 
				/*dbo.DMPromotionType DP ON DPO.CatalogCode = DP.CatalogCode*/
				WHERE (MH.StartDate >= DATEADD(YY, -1, @AsOfDateLoc) AND MH.STartDate < @AsOfDateLoc)
				GROUP BY CustomerID
                ) T
		ON TCD.CustomerID = T.CustomerID
    
	UPDATE TCD
		SET YTDCatalogContacts = T.Cnt1YearCatalogContacts
		FROM Staging.TempDMCustomerDynamic TCD INNER JOIN  
			(
            SELECT 	MH.CustomerID, COUNT(MH.AdCode) Cnt1YearCatalogContacts
			FROM 	Archive.MailingHistory MH (nolock) INNER JOIN 
				Staging.MktAdCodes MAC (nolock) ON MH.AdCode = MAC.AdCode 
				INNER JOIN Mapping.DMPromotionType DP (nolock) ON MAC.CatalogCode = DP.CatalogCode 
			WHERE 	DP.PromotionType = 'Catalog' AND 
				(MH.StartDate >= DATEADD(YY, -1, @AsOfDateLoc) AND MH.STartDate < @AsOfDateLoc)
			GROUP BY MH.CustomerID
            ) T
		ON TCD.CustomerID = T.CustomerID

	UPDATE TCD
		SET YTDMagalogContacts = T.Cnt1YearMagalogContacts
		FROM Staging.TempDMCustomerDynamic TCD INNER JOIN  
			(SELECT 	MH.CustomerID, COUNT(MH.AdCode) Cnt1YearMagalogContacts
			FROM 	Archive.MailingHistory MH (nolock) INNER JOIN 
				Staging.MktAdCodes MAC (nolock) ON MH.AdCode = MAC.AdCode 
				INNER JOIN  Mapping.DMPromotionType DP (nolock) ON MAC.CatalogCode = DP.CatalogCode 
			WHERE 	DP.PromotionType = 'Magalog' AND 
				(MH.StartDate >= DATEADD(YY, -1, @AsOfDateLoc) AND MH.STartDate < @AsOfDateLoc)
			GROUP BY MH.CustomerID) T
		ON TCD.CustomerID = T.CustomerID			

	UPDATE TCD
		SET YTDSwampSpContacts = T.Cnt1YearSwampSpContacts
		FROM Staging.TempDMCustomerDynamic TCD INNER JOIN  
			(SELECT 	MH.CustomerID, COUNT(MH.AdCode) Cnt1YearSwampSpContacts
			FROM 	Archive.MailingHistory MH (nolock) INNER JOIN 
				Staging.MktAdCodes MAC (nolock) ON MH.AdCode = MAC.AdCode 
				INNER JOIN Mapping.DMPromotionType DP (nolock) ON MAC.CatalogCode = DP.CatalogCode 
			WHERE 	DP.PromotionType = 'SwampSpecific' AND 
				(MH.StartDate >= DATEADD(YY, -1, @AsOfDateLoc) AND MH.STartDate < @AsOfDateLoc)
			GROUP BY MH.CustomerID) T
		ON TCD.CustomerID = T.CustomerID			

	UPDATE TCD
		SET YTDNLContacts = T.Cnt1YearNLContacts
		FROM Staging.TempDMCustomerDynamic TCD INNER JOIN  
			(SELECT 	MH.CustomerID, COUNT(MH.AdCode) Cnt1YearNLContacts
			FROM 	Archive.MailingHistory MH (nolock) INNER JOIN 
				Staging.MktAdCodes MAC (nolock) ON MH.AdCode = MAC.AdCode 
				INNER JOIN Mapping.DMPromotionType DP (nolock) ON MAC.CatalogCode = DP.CatalogCode 
			WHERE 	DP.PromotionType = 'NewsLetter' AND 
				(MH.StartDate >= DATEADD(YY, -1, @AsOfDateLoc) AND MH.STartDate < @AsOfDateLoc)
			GROUP BY MH.CustomerID) T
		ON TCD.CustomerID = T.CustomerID

/* PR - Added for Magazine updates - 11/30/2007 (But was commented until new columns were added to the table - 12/3/2007)*/
	UPDATE TCD
		SET YTDMagazineContacts = T.Cnt1YearMagazineContacts
		FROM Staging.TempDMCustomerDynamic TCD INNER JOIN  
			(SELECT 	MH.CustomerID, COUNT(MH.AdCode) Cnt1YearMagazineContacts
			FROM 	Archive.MailingHistory MH (nolock) INNER JOIN 
				Staging.MktAdCodes MAC (nolock) ON MH.AdCode = MAC.AdCode 
				INNER JOIN Mapping.DMPromotionType DP (nolock) ON MAC.CatalogCode = DP.CatalogCode 
			WHERE 	DP.PromotionType = 'Magazine' AND 
				(MH.StartDate >= DATEADD(YY, -1, @AsOfDateLoc) AND MH.STartDate < @AsOfDateLoc)
			GROUP BY MH.CustomerID) T
		ON TCD.CustomerID = T.CustomerID	
        
/* Update Total Contact information*/
		UPDATE TCD
			SET TCD.ContactsSubsqMth = T.Cnt1YearCatalogContacts,
			    TCD.CostContactsSubsqMth = T.Cost1YearCatalogContacts /* PR - 10/23/2007*/
			FROM Staging.TempDMCustomerDynamic TCD INNER JOIN  
				(SELECT MH.CustomerID, COUNT(MH.AdCode) Cnt1YearCatalogContacts,
					SUM(MAC.VariableCost) Cost1YearCatalogContacts /* PR - 10/23/2007*/
				FROM 	Archive.MailingHistory MH (nolock) INNER JOIN 
					Staging.MktAdCodes MAC (nolock) ON MH.AdCode = MAC.AdCode 
					INNER JOIN Mapping.DMPromotionType DP (nolock) ON MAC.CatalogCode = DP.CatalogCode 
				WHERE 	MH.FlagHoldout = 0 AND /*DP.PromotionType = 'Catalog' AND */
					(MH.StartDate >= @AsOfDateLoc AND MH.STartDate < 	DATEADD(MM, 1, @AsOfDateLoc))
				GROUP BY MH.CustomerID) T
			ON TCD.CustomerID = T.CustomerID
--			WHERE TCD.AsOfdate = @AsOfDateLoc

/* Update Catalog contacts information*/
		UPDATE TCD
			SET TCD.CatalogContactsSubsqMth = T.Cnt1YearCatalogContacts,
			    TCD.CostCatalogContactsSubsqMth = T.Cost1YearCatalogContacts /* PR - 10/23/2007*/
			FROM Staging.TempDMCustomerDynamic TCD INNER JOIN  
				(SELECT MH.CustomerID, COUNT(MH.AdCode) Cnt1YearCatalogContacts,
					SUM(MAC.VariableCost) Cost1YearCatalogContacts /* PR - 10/23/2007*/
				FROM 	Archive.MailingHistory MH (nolock) INNER JOIN 
					Staging.MktAdCodes MAC (nolock) ON MH.AdCode = MAC.AdCode 
					INNER JOIN Mapping.DMPromotionType DP (nolock) ON MAC.CatalogCode = DP.CatalogCode 
				WHERE 	DP.PromotionType = 'Catalog' AND MH.FlagHoldout = 0 AND 
					(MH.StartDate >= @AsOfDateLoc AND MH.STartDate < 	DATEADD(MM, 1, @AsOfDateLoc))
				GROUP BY MH.CustomerID) T
			ON TCD.CustomerID = T.CustomerID
--			WHERE TCD.AsOfdate = @AsOfDateLoc

/* Update Newsletter contacts information*/
		UPDATE TCD
			SET TCD.NLContactsSubsqMth = T.Cnt1YearCatalogContacts,
			    TCD.CostNLContactsSubsqMth = T.Cost1YearCatalogContacts /* PR - 10/23/2007*/
			FROM Staging.TempDMCustomerDynamic TCD INNER JOIN  
				(SELECT MH.CustomerID, COUNT(MH.AdCode) Cnt1YearCatalogContacts,
					SUM(MAC.VariableCost) Cost1YearCatalogContacts /* PR - 10/23/2007*/
				FROM 	Archive.MailingHistory MH (nolock) INNER JOIN 
					Staging.MktAdCodes MAC (nolock) ON MH.AdCode = MAC.AdCode 
					INNER JOIN Mapping.DMPromotionType DP (nolock) ON MAC.CatalogCode = DP.CatalogCode 
				WHERE 	DP.PromotionType = 'NewsLetter' AND MH.FlagHoldout = 0 AND 
					(MH.StartDate >= @AsOfDateLoc AND MH.STartDate < 	DATEADD(MM, 1, @AsOfDateLoc))
				GROUP BY MH.CustomerID) T
			ON TCD.CustomerID = T.CustomerID
--			WHERE TCD.AsOfdate = @AsOfDateLoc

/* Update Magalog contacts information*/
		UPDATE TCD
			SET TCD.MagalogContactsSubsqMth = T.Cnt1YearCatalogContacts,
			    TCD.CostMagalogContactsSubsqMth = T.Cost1YearCatalogContacts /* PR - 10/23/2007*/
			FROM Staging.TempDMCustomerDynamic TCD INNER JOIN  
				(SELECT MH.CustomerID, COUNT(MH.AdCode) Cnt1YearCatalogContacts,
					SUM(MAC.VariableCost) Cost1YearCatalogContacts /* PR - 10/23/2007*/
				FROM 	Archive.MailingHistory MH (nolock) INNER JOIN 
					Staging.MktAdCodes MAC (nolock) ON MH.AdCode = MAC.AdCode 
					INNER JOIN Mapping.DMPromotionType DP (nolock) ON MAC.CatalogCode = DP.CatalogCode 
				WHERE 	DP.PromotionType = 'Magalog' AND MH.FlagHoldout = 0 AND 
					(MH.StartDate >= @AsOfDateLoc AND MH.STartDate < 	DATEADD(MM, 1, @AsOfDateLoc))
				GROUP BY MH.CustomerID) T
			ON TCD.CustomerID = T.CustomerID
--			WHERE TCD.AsOfdate = @AsOfDateLoc

/* Update Swamp specific contacts information*/
		UPDATE TCD
			SET TCD.SwampSpContactsSubsqMth = T.Cnt1YearCatalogContacts,
			    TCD.CostSwampSpContactsSubsqMth = T.Cost1YearCatalogContacts /* PR - 10/23/2007*/
			FROM  Staging.TempDMCustomerDynamic TCD INNER JOIN  
				(SELECT MH.CustomerID, COUNT(MH.AdCode) Cnt1YearCatalogContacts,
					SUM(MAC.VariableCost) Cost1YearCatalogContacts /* PR - 10/23/2007*/
				FROM 	Archive.MailingHistory MH (nolock) INNER JOIN 
					Staging.MktAdCodes MAC (nolock) ON MH.AdCode = MAC.AdCode 
					INNER JOIN Mapping.DMPromotionType DP (nolock) ON MAC.CatalogCode = DP.CatalogCode 
				WHERE 	DP.PromotionType = 'SwampSpecific' AND MH.FlagHoldout = 0 AND 
					(MH.StartDate >= @AsOfDateLoc AND MH.STartDate < 	DATEADD(MM, 1, @AsOfDateLoc))
				GROUP BY MH.CustomerID) T
			ON TCD.CustomerID = T.CustomerID
--			WHERE TCD.AsOfdate = @AsOfDateLoc

/* Update Magazine contacts information*/
		UPDATE TCD
			SET TCD.MagazineContactsSubsqMth = T.Cnt1YearCatalogContacts,
			    TCD.CostMagazineContactsSubsqMth = T.Cost1YearCatalogContacts /* PR - 10/23/2007*/
			FROM Staging.TempDMCustomerDynamic TCD INNER JOIN  
				(SELECT MH.CustomerID, COUNT(MH.AdCode) Cnt1YearCatalogContacts,
					SUM(MAC.VariableCost) Cost1YearCatalogContacts /* PR - 10/23/2007*/
				FROM 	Archive.MailingHistory MH (nolock) INNER JOIN 
					Staging.MktAdCodes MAC (nolock) ON MH.AdCode = MAC.AdCode 
					INNER JOIN Mapping.DMPromotionType DP (nolock) ON MAC.CatalogCode = DP.CatalogCode 
				WHERE 	DP.PromotionType = 'Magazine' AND MH.FlagHoldout = 0 AND 
					(MH.StartDate >= @AsOfDateLoc AND MH.STartDate < 	DATEADD(MM, 1, @AsOfDateLoc))
				GROUP BY MH.CustomerID) T
			ON TCD.CustomerID = T.CustomerID
--			WHERE TCD.AsOfdate = @AsOfDateLoc
        
	/* Load RFM Information    */
   	EXECUTE Staging.LoadRFMData @AsOfDateLoc    
    
	UPDATE TCD
	SET 	TCD.[Name] = RN.[Name],
		TCD.A12MF = RDS.a12mF,
		TCD.NewSeg = RN.NewSeg,
		TCD.ActiveOrSwamp = 
			CASE 
				WHEN RN.NewSeg BETWEEN 1 AND 10 THEN 1
				WHEN RN.NewSeg BETWEEN 13 AND 15 THEN 1
				ELSE 0
			END
	FROM 	Staging.TempDMCustomerDynamic TCD INNER JOIN Marketing.RFM_DATA_SPECIAL RDS (nolock) ON
		 TCD.CustomerID = RDS.CustomerID  INNER JOIN Mapping.RFMInfo RI (nolock)
		ON RDS.Concatenated = RI.Concatenated INNER JOIN Mapping.RFMnewsegs RN (nolock)
		ON RI.NewSeg = RN.NewSeg

	/* Load Information about DSLPurchase and NumOfPurchases*/
	UPDATE TCD
		SET LTDPurchases = T.SN,
			Frequency = 
			CASE WHEN T.SN = 1 THEN 'F1'
				WHEN T.SN > 1 THEN 'F2'
			END,
			DSLPurchase = DATEDIFF(DD, T.DO, @AsOfDateLoc)
		FROM Staging.TempDMCustomerDynamic TCD, (SELECT CustomerID, MAX(SequenceNum) AS SN, 
						MAX(cast(DateOrdered as date)) As DO  FROM Marketing.DMPurchaseOrders (nolock) 
					WHERE cast(DateOrdered as date) < @AsOfDateLoc
						GROUP BY CustomerID) T
		WHERE TCD.CustomerID = T.CustomerID
        
    /* Load PurchAmountSubsqMth, PurchasesSubsqMth*/
	UPDATE TCD
		SET TCD.PurchAmountSubsqMth = isnull(FinalSales,0),
			TCD.PurchasesSubsqMth = isnull(CntOrders,0)
			FROM Staging.TempDMCustomerDynamic TCD INNER JOIN 
	(
		SELECT DPO.CustomerID, COUNT(DPO.OrderID) As CntOrders, 
			SUM(FinalSales) As FinalSales
			FROM Marketing.DMPurchaseOrders DPO (nolock)
			WHERE 	cast(DPO.DateOrdered as date) >= @AsOfDateLoc AND cast(DPO.DateOrdered as date) < DATEADD(MM, 1, @AsOfDateLoc) 
			AND FinalSales < 1500
			GROUP BY DPO.CustomerID
	) t ON TCD.CustomerID = T.CustomerID 

	/* Preethi Ramanujam - 8/12/2009*/
	/* Add Total Parts and hours purchased in the subsequent month to the table*/
	/* Preethi Ramanujam - 3/8/2011 - Added total units subsequent month.*/
	
	/* Add Total Parts and hours purchased in the subsequent month to the table*/
	UPDATE TCD
	SET TCD.PartsPurchSubsqMth = isnull(CP.TotalCourseParts,0),
		TCD.HoursPurchSubsqMth	= isnull(CP.TotalCourseHours,0),
		TCD.UnitsPurchSubsqMth = isnull(CP.TotalQuantity,0) /* added on 3/8/2011 - Preethi Ramanujam*/
	FROM Staging.TempDMCustomerDynamic TCD INNER JOIN
	(
    	SELECT dpo.CustomerID, SUM(DMC.CourseParts * TotalQuantity) TotalCourseParts, 
			SUM(DMC.CourseHours * TotalQuantity) TotalCourseHours,
			SUM(TotalQuantity) TotalQuantity
		FROM Marketing.DMPurchaseOrders DPO (nolock)
        JOIN Marketing.DMPurchaseOrderItems OI (nolock) ON dpo.OrderID = OI.OrderID JOIN
			Mapping.DMCourse DMC (nolock) ON DMC.Courseid = OI.CourseID
		WHERE 
        	OI.StockItemID like '[PD][ACDVM]%'
        	and cast(DPO.DateOrdered as date) >= @AsOfDateLoc 
            AND cast(DPO.DateOrdered as date) < DATEADD(MM, 1, @AsOfDateLoc)
	AND FinalSales < 1500 
		GROUP BY dpo.CustomerID)CP ON TCD.Customerid = CP.CustomerID
    
    
	/* CoupnsRedmSubsqMth*/
	UPDATE TCD
		SET 	TCD.CoupnsRedmSubsqMth = isnull(CntOrders,0)
			FROM Staging.TempDMCustomerDynamic TCD INNER JOIN 
            (
	SELECT DPO.CustomerID, COUNT(DPO.OrderID) As CntOrders
	FROM Staging.vwOrders DPO (nolock) WHERE DPO.FlagCouponRedm = 1 AND
	cast(DPO.DateOrdered as date) >= @AsOfDateLoc AND cast(DPO.DateOrdered as date) < DATEADD(MM, 1, @AsOfDateLoc) 
	GROUP BY DPO.CustomerID
            ) T
			ON TCD.CustomerID = T.CustomerID 	

	/* count and sum of orders: NewCoursePurchSubsqMth, NewCourseSalesSubsqMth*/
	UPDATE TCD
		SET TCD.NewCoursePurchSubsqMth = isnull(CntOrders,0),
		    TCD.NewCourseSalesSubsqMth = isnull(SumNetOrderAmount,0) /* PR - 12/3/2007 - added new course amount information for the house spending cube*/
			FROM Staging.TempDMCustomerDynamic TCD INNER JOIN 
	(
	SELECT O.CustomerID, COUNT(O.OrderID) As CntOrders, SUM(DPO.TotalSales) AS SumNetOrderAmount
				FROM Marketing.DMPurchaseOrderItems DPO (nolock)
                join Marketing.DMPurchaseOrders o (nolock) on o.OrderID = dpo.OrderID
                WHERE DPO.FlagNewCourse = 1 
				AND DPO.TotalSales BETWEEN 10 and 1500 /* PR - 12/3/2007 - added amount information*/
				AND cast(DPO.DateOrdered as date) >= @AsOfDateLoc AND cast(DPO.DateOrdered as date) < DATEADD(MM, 1, @AsOfDateLoc) 
				GROUP BY O.CustomerID	
    ) t            
	ON TCD.CustomerID = T.CustomerID	
	
    /* Load EMResponsesSubsqMth        */
	UPDATE TCD
		SET EMResponsesSubsqMth = ISNULL(T.CC,0)
	FROM Staging.TempDMCustomerDynamic TCD INNER JOIN 
    (
	SELECT CustomerID, COUNT(DPO.CatalogCode) As CC
	FROM Marketing.DMPurchaseOrders DPO (nolock) INNER JOIN Mapping.DMPromotionType DPT (nolock)
		ON DPO.CatalogCode = DPT.CatalogCode WHERE
		DPT.Category = 'E-Campaign' AND
		cast(DPO.DateOrdered as date) >= @AsOfDateLoc AND cast(DPO.DateOrdered as date) < DATEADD(MM, 1, @AsOfDateLoc) 
		GROUP BY CustomerID	
    ) T
	ON TCD.CustomerID = T.CustomerID
    
	/* Load TenureDays*/
	UPDATE TCD
		SET TenureDays = DATEDIFF(DD, cast(DPO.DateOrdered as date), @AsOfDateLoc)
		FROM Staging.TempDMCustomerDynamic TCD INNER JOIN Marketing.DMPurchaseOrders DPO (nolock)	
			ON TCD.CustomerID = DPO.CustomerID AND
			DPO.SequenceNum = 1

--	EXECUTE Staging.spUpdateContactInfo @AsOfDateLoc    
    
	/* PR - 2/23/2009*/
	/* Update FlagEmailable and Mailable in the table.*/
	UPDATE A
	SET A.FlagEmailPref = isnull(B.FlagEmailPref,2), 
		A.FlagEmailValid = isnull(B.FlagValidEmail,2), 
		A.FlagEmailable = isnull(B.FlagEmailable,2), 
		A.FlagMailPref = isnull(B.FlagMailPref,2), 
		A.FlagValidUSMailable = isnull(B.FlagValidRegion,2), 
		A.FlagMailable = isnull(B.FlagMailable,2),
		A.R3PurchWeb = ISNULL(B.R3PurchWeb,2),
		A.CountryCode = B.CountryCodeCube
	FROM Staging.TempDMCustomerDynamic A JOIN
		(SELECT *
		FROM Marketing.DMCustomerMailEmailFlags (nolock)
		WHERE cast(AsOfDate as date) = @AsOfDateLoc)B ON A.CustomerID = B.customerID
        
	/* Update Subsequent Email Contacts for the month        */
	UPDATE A
	SET A.EmailContactsSubsqMth = B.EmailContactsSubsqMth
	FROM Staging.TempDMCustomerDynamic A JOIN
		(SELECT CustomerID, Count(Adcode) EmailContactsSubsqMth
		FROM Archive.EmailHistory (nolock)
		WHERE cast(StartDate as date) BETWEEN @AsOfDateLoc AND DateAdd(month,1,@AsOfDateLoc)
		GROUP BY CustomerID)B ON A.Customerid = B.CustomerID

	/* Update Bin Information    */
	EXECUTE Staging.spUpdateBinInfo @AsOfDateLoc      
    
    select top 1 @CustomerID = CustomerID from Marketing.DMCustomerDynamic (nolock) where AsOfDate = @AsOfDateLoc
    
    if isnull(@CustomerID, 0) <> 0 delete from Marketing.DMCustomerDynamic where AsOfDate = @AsOfDateLoc
	insert into Marketing.DMCustomerDynamic    
    select * from Staging.TempDMCustomerDynamic (nolock)    
    truncate table Staging.TempDMCustomerDynamic    
    
end
GO
