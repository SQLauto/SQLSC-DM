SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Staging].[LoadDMPurchaseOrders]
as
begin
    set nocount on
    
    truncate table Staging.TempDMPurchaseOrders

	truncate table Staging.ValidPurchaseOrderItems
    insert into Staging.ValidPurchaseOrderItems
    select *
	from Staging.vwValidPurchaseOrderItems (nolock)
    
	insert into Staging.TempDMPurchaseOrders
	(
		CustomerID, 
		DateOrdered,
		OrderID,
		FlagLegacy,
		OrderSource,
		AdCode,
		NetOrderAmount,
		ShippingCharge,
        DiscountAmount,
		Tax,
		MinShipDate,
		MaxShipDate,
		OrderShipDays,
		FlagSplitShipment,
        FlagCouponRedm,
        CatalogCode,
        PromotionType,
        BillingCountryCode,
        FlagLowPriceLeader,
        FlagEmailOrder,
        WebOrderID,
        DaysSinceLastPurchase,
        FinalSales,
        TotalCourseSales,
        TotalTranscriptSales,
        NextPurchaseOrderAmount,
        PriorPurchaseOrderAmount,
        PriorSales,
        PriorAOS,
        CSRID,
		CSRID_Actual,
        TotalTranscriptQuantity,
        TotalTranscriptParts,
		FlagDVDatCDProspect,
        StatusCode,
        CurrencyCode,
        SalesTypeID,
        Age,
        DownstreamDays,
    	FlagHasCLRCourse,
    	TotalCLRCourseSales,
        TotalCLRCourseUnits,
        TotalCLRCourseParts,
    	FlagHasOtherCourse,
    	TotalOtherCourseSales,
        TotalOtherCourseUnits,
        TotalOtherCourseParts,
		TotalCourseSalesWthSets, 
		TotalCourseQuantityWthSets, 
		TotalCoursePartsWthSets, 
		TotalCLRCourseSalesWthSets, 
		TotalCLRCourseUnitsWthSets, 
		TotalCLRCoursePartsWthSets, 
		TotalOtherCourseSalesWthSets, 
		TotalOtherCourseUnitsWthSets, 
		TotalOtherCoursePartsWthSets,
		StandardSalePriceCourseWthSets,
		StdSalePriceCLRCourseWthSets,
		StdSalePriceOtherCourseWthSets,
		GiftFlag,
		ShipRegion,
		ShipCountryCode,
		BillingRegion,
		Coupon,
		CouponDesc
	)    
	select 
		o.CustomerID, 
		o.DateOrdered, 
		o.OrderID,
		o.FlagLegacy,
		isnull(o.OrderSource, 'X'),
		o.AdCode,
		isnull(o.NetOrderAmount, 0),
        case 
        	when isnull(o.DiscountAmount, 0) > 0 then isnull(o.ShippingCharge, 0) + isnull(o.DiscountAmount, 0)
            else isnull(o.ShippingCharge, 0)
        end as ShippingCharge,
        case 
        	when isnull(o.DiscountAmount, 0) > 0 then 0
            else isnull(o.DiscountAmount, 0)
        end as DiscountAmount,
		o.TotalReadyTaxCost,
		o.MinShipDate,
		o.MaxShipDate,
		ISNULL(DATEDIFF(DD, O.DateOrdered, O.MaxShipDate), 0) - 2 * ISNULL(DATEDIFF(WK, O.DateOrdered, O.MaxShipDate), 0),
		case
			when CONVERT(VARCHAR(10), o.MaxShipDate, 101) <> CONVERT(VARCHAR(10), o.MinShipDate, 101) and o.MinShipDate IS NOT null then 1
			else 0
		end,
        isnull(FlagCouponRedm, 0),
        ac.CatalogCode,
        pt.DimPromotionID,
        o.BillingCountryCode,
        case
            when pt.PromotionType like '%Buffet%' then 1
            else 0
        end,
        case
            when pt.PromotionType like '%E-campaign%' then 1
            else 0
        end,
        o.WebOrder_ID,
        0,
        0 as FinalSales,
        0,
        0,
        0,
        0,
        0,
        0,
        r.CSRID,
        o.CSRID,
        0,
        0,
        0,
        StatusCode,
        CurrencyCode,
        o.SalesTypeID,
		datediff(month, co.DateOfBirth, o.DateOrdered)/12,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,0,0,0,0,0,0,0,0,0,0,0,o.GiftFlag,o.ShipRegion,o.ShipCountryCode,o.BillingRegion,DMC.Coupon,DMC.CouponDesc
	from Staging.vwOrders o (nolock) 
    join (select distinct OrderID from Staging.ValidPurchaseOrderItems (nolock)) as ValidOrders on ValidOrders.OrderID = o.OrderID    
    left join Staging.MktAdCodes ac (nolock) on o.AdCode = ac.AdCode
    left join Mapping.DMPromotionType pt (nolock) on pt.CatalogCode = ac.CatalogCode
    left join Mapping.DMCSRID r (nolock) on r.LoginName = o.CSRID
    left join Mapping.CustomerOverlay_WD co (nolock) on o.CustomerID = co.CustomerID
    -- left join Mapping.CustomerOverLay co (nolock) on o.CustomerID = co.CustomerID -- PR -- 8/20/2014 -- Point the demographics to Web Decisions Table
    left join (
				select DM.orderid,DM.Coupon,DM.CouponDesc 
				from Marketing.DMPurchaseOrderCoupons Dm
				inner join (Select orderID,MAX(coupon)coupon 
							from Marketing.DMPurchaseOrderCoupons
							group by orderID) DMG 
				on DMG.orderid = DM.orderID and DMG.coupon= DM.Coupon
				)DMC 
				on DMC.orderid = O.Orderid 

    
    
    
	;with OrderSequence(OrderID, SequenceNum)
    as
    (
        SELECT 
            po.OrderID,
        	RANK() OVER (PARTITION BY po.CustomerID ORDER BY po.DateOrdered, po.OrderID) SequenceNum
        FROM Staging.TempDMPurchaseOrders po (nolock) 
    )
    update po
    set 
    	po.SequenceNum = os.SequenceNum,
    	po.FrequencyPrior = 
        	CASE 
            	WHEN os.SequenceNum = 1 then 'F0'
				WHEN os.SequenceNum = 2 then 'F1'
				WHEN os.SequenceNum >= 3 then 'F2'
			END,
		po.PriorOrders = os.SequenceNum - 1
    from Staging.TempDMPurchaseOrders po
    join OrderSequence os (nolock) on os.OrderID = po.OrderID

	UPDATE MO1
	SET DownStreamDays = DATEDIFF(DD, MO.DateOrdered, MO1.DateOrdered)
	FROM Staging.TempDMPurchaseOrders MO1 
	JOIN Staging.TempDMPurchaseOrders MO (nolock) on MO.CustomerID = MO1.CustomerID 
	where 
		MO.SequenceNum = 1 
		AND MO1.SequenceNum > 1

	UPDATE MO
	SET MO.TotalCourseParts = T.TP,
		MO.TotalCourseQuantity = T.TQ,
		MO.TotalCourseSales = T.TS,
        mo.StandardSalePriceAllCourses = t.StandardSalePriceAllCourses
    FROM Staging.TempDMPurchaseOrders MO, 	
    (SELECT OrderID, SUM(TotalParts) As TP, SUM(TotalQuantity)As TQ, 
    SUM(TotalSales) As TS, sum(oi.TotalStandardSalePrice) as StandardSalePriceAllCourses 
    FROM Marketing.DMPurchaseOrderItems oi (nolock) 
    WHERE FormatMedia <> 'T' 
    GROUP BY OrderID) T	
    WHERE 
        MO.OrderID = T.OrderID
        
-- Add with sets information
	UPDATE MO
	SET MO.TotalCoursePartsWthSets = T.TP,
		MO.TotalCourseQuantityWthSets = T.TQ,
		MO.TotalCourseSalesWthSets = T.TS,
        mo.StandardSalePriceCourseWthSets = t.StandardSalePriceAllCourses		
    FROM Staging.TempDMPurchaseOrders MO, 	
    (SELECT OrderID, SUM(TotalParts) As TP, SUM(TotalQuantity)As TQ, 
    SUM(TotalSales) As TS, sum(oi.TotalStandardSalePrice) as StandardSalePriceAllCourses 
    -- select oi.*
    FROM Marketing.DMPurchaseOrderItems oi (nolock) 
    WHERE FormatMedia <> 'T' 
    and BundleID > 0
    GROUP BY OrderID) T	
    WHERE 
        MO.OrderID = T.OrderID    

	UPDATE MO
	SET MO.TotalTranscriptParts = T.TP,
		MO.TotalTranscriptQuantity = T.TQ,
		MO.TotalTranscriptSales = T.TS
    FROM Staging.TempDMPurchaseOrders MO, 	
    (SELECT OrderID, SUM(TotalParts) As TP, SUM(TotalQuantity)As TQ, 
    SUM(TotalSales) As TS
    FROM Marketing.DMPurchaseOrderItems (nolock) 
    WHERE FormatMedia = 'T' 
	and left(stockitemid,2) = 'PT'
    GROUP BY OrderID) T	
    WHERE 
        MO.OrderID = T.OrderID	
    
    update MO 
    SET FinalSales = NetOrderAMount + isnull(SumTotalSales, 0)
    FROM Staging.TempDMPurchaseOrders MO 
    left JOIN 
    (
        SELECT 
            OrderID, 
            SUM(TotalSales) as SumTotalSales
        FROM Marketing.DMPurchaseOrderItems (nolock) 
        WHERE 
            FlagPaymentRejected = 1 
        GROUP BY OrderID
    ) T ON MO.OrderID = T.OrderID

/* ADDED BY AP TO CALCULATE DAYS SINCE LAST PURCHASE: ADDED ON 8/31/2006*/
    UPDATE PO
    SET PO.DaysSinceLastPurchase = isnull(PO.DownStreamDays - NPO.DownStreamDays, 0)
    from Staging.TempDMPurchaseOrders po 
    join
    (
        select customerid, sequencenum, npsequencenum = sequencenum + 1, downstreamdays
        from Staging.TempDMPurchaseOrders po (nolock) 
    ) npo on po.customerid = npo.customerid and po.sequencenum = npo.npsequencenum
    
/* Include next purchase information 	-- Preethi Ramanujam	6/30/2008*/
	UPDATE dmpo1
	SET dmpo1.NextPurchaseOrderID = dmpo2.Orderid,
		dmpo1.NextPurchaseOrderDate = dmpo2.DateOrdered,
		dmpo1.NextPurchaseOrderAmount = dmpo2.NetOrderAmount,
		dmpo1.NextPurchaseOrderSource = dmpo2.OrderSource,
		dmpo1.NextPurchaseAdcode = dmpo2.Adcode
	FROM Staging.TempDMPurchaseOrders dmpo1 JOIN
		(SELECT CustomerID, OrderID, (SequenceNum-1)SequenceNum, 
			NetOrderAmount,OrderSource,DateOrdered, Adcode
		FROM Staging.TempDMPurchaseOrders (nolock) )dmpo2 on dmpo1.customerid = dmpo2.customerID
					AND dmpo1.SequenceNum = dmpo2.SequenceNum
    
/* Include Prior purchase information 	-- Preethi Ramanujam	1/27/2009*/
	UPDATE dmpo1
	SET dmpo1.PriorPurchaseOrderID = dmpo2.Orderid,
		dmpo1.PriorPurchaseOrderDate = dmpo2.DateOrdered,
		dmpo1.PriorPurchaseOrderAmount = dmpo2.NetOrderAmount,
		dmpo1.PriorPurchaseOrderSource = dmpo2.OrderSource,
		dmpo1.PriorPurchaseAdcode = dmpo2.Adcode
	FROM Staging.TempDMPurchaseOrders dmpo1 JOIN
		(SELECT CustomerID, OrderID, (SequenceNum+1)SequenceNum, 
			NetOrderAmount,OrderSource,DateOrdered, Adcode
		FROM Staging.TempDMPurchaseOrders (nolock) )dmpo2 on dmpo1.customerid = dmpo2.customerID
					AND dmpo1.SequenceNum = dmpo2.SequenceNum
    
	UPDATE Staging.TempDMPurchaseOrders 
    SET 
    -- PR -- 5/28/2014 -- Update along with new segments. Moved to after NewSEgPrior updates
	 --   CustomerSegmentPrior = 
		--CASE 
  --      	WHEN SequenceNum = 1 then 'New' 
		--	WHEN SequenceNum > 1 and DaysSinceLastPurchase <= 365 then 'Active'
		--	WHEN SequenceNum > 1 and DaysSinceLastPurchase between 365 and 548 and FrequencyPrior = 'F2' then 'Active'
		--	ELSE 'Swamp'
		--END,			
    	--AgeBin = 
     --   	CASE 
     --       	WHEN Age < 35 then '34-'
     --           WHEN Age between 35 and 44 then '35-44'
     --           WHEN Age between 45 and 54 then '45-54'
     --           WHEN Age between 55 and 64 then '55-64'
     --           WHEN Age between 65 and 79 then '65-79'
     --           WHEN Age >= 80 then '80+'
     --       	ELSE ''
     --       END
		/*Bin Changes Preethi 20160831*/
		AgeBin	= 			CASE WHEN Age <= 34  then '1: < 35'
										WHEN Age between 35 and 44 then '2: 35-44'
										WHEN Age between 45 and 54 then '3: 45-54'
										WHEN Age between 55 and 64 then '4: 55-64'
										WHEN Age between 65 and 74 then '5: 65-74'
										WHEN Age >= 75 then '6: >= 75'
										--When b.Customerid is not null and b.DateOfBirth  is NULL then '7: No Overlay Available' 
										ELSE '8: Unknown'
									END 
        
    update po
    set 
    	po.PriorSales =
        (
            select isnull(sum(po2.NetOrderAmount), 0)
            from Staging.TempDMPurchaseOrders po2 (nolock)
            where 
                po2.CustomerID = po.CustomerID
                and po2.SequenceNum < po.SequenceNum 
        ),
        po.Prior12MonthOrders = 
        (
            select 
                count(po2.OrderID)
            from Staging.TempDMPurchaseOrders po2 (nolock)
            where 
                po2.CustomerID = po.CustomerID
                and po2.SequenceNum < po.SequenceNum 
            --    and po2.DateOrdered between DATEADD(month, -12, po.DateOrdered) and po.DateOrdered  -- PR 5/28/2014 To avoid issue with 0 a12mf, match to recency calculations
				and po2.DateOrdered between DATEADD(DAY, -365, cast(po.DateOrdered as date)) and po.DateOrdered  -- PR 5/28/2014 To avoid issue with 0 a12mf, match to recency calculations
	    ),
        po.Prior6MonthOrders = 
        (
            select 
                count(po2.OrderID)
            from Staging.TempDMPurchaseOrders po2 (nolock)
            where 
                po2.CustomerID = po.CustomerID
                and po2.SequenceNum < po.SequenceNum 
              --  and po2.DateOrdered between DATEADD(month, -6, po.DateOrdered) and po.DateOrdered -- PR 5/28/2014 To avoid issue with 0 a12mf, match to recency calculations
              and po2.DateOrdered between DATEADD(DAY, -183, cast(po.DateOrdered as date)) and po.DateOrdered -- PR 5/28/2014 To avoid issue with 0 a12mf, match to recency calculations
        )
    from Staging.TempDMPurchaseOrders po
        
	update Staging.TempDMPurchaseOrders
	set 
    	PriorAOS = PriorSales/PriorOrders,
		MonetaryValuePrior = 
        	Case 
            	when (PriorSales/PriorOrders) > 220 then 'M3'
				when (PriorSales/PriorOrders) > 100 then 'M2'
				when (PriorSales/PriorOrders) > 0 then 'M1'
				else 'M0'
			end
	where 
    	PriorOrders > 0
        
    update po
    set po.RecencyPrior = rd.Recency
    from Staging.TempDMPurchaseOrders po 
    join Mapping.RecencyDays rd (nolock) on 
        case 
            when po.DaysSinceLastPurchase > 4383 then 4383
            else po.DaysSinceLastPurchase
        end = rd.DaysOld
    
    update po
    set po.ConcatenatedPrior = rtrim(ltrim(RecencyPrior)) + FrequencyPrior + MonetaryValuePrior
    from Staging.TempDMPurchaseOrders po
    
    update po
    set 
        po.NewsegPrior = i.NewSeg,
        po.NamePrior = ns.[Name]
    from Staging.TempDMPurchaseOrders po 
    join Mapping.RFMInfo i (nolock) on po.ConcatenatedPrior = i.Concatenated
    join Mapping.RFMNewSegs ns (nolock) on i.NewSeg = ns.NewSeg
    
    UPDATE po
    SET po.A12MFPrior = 
        case 
            when po.Prior12MonthOrders > 1 then 2
            when po.Prior12MonthOrders = 1 then 1
            else 0
        end
    from Staging.TempDMPurchaseOrders po
    WHERE 
    	po.NewSegPrior in (8, 9, 10)
    
    UPDATE po
    SET po.A12MFPrior = 
        case 
            when po.Prior6MonthOrders > 2 then 3
            when po.Prior6MonthOrders = 2 then 2
            when po.Prior6MonthOrders = 1 then 1
            else 0
        end
    from Staging.TempDMPurchaseOrders po
    WHERE 
    	po.NewSegPrior in (3, 4, 5)
        
	-- PR 5/28/2014 Update CustomerSegmentPrior and two new variables CustomerSegment2Prior and FnlPrior
    update a
    set a.CustomerSegmentPrior = case when SequenceNum = 1 then 'NoPriorPurchase'
										else b.CustomerSegment
									end,
		a.CustomerSegment2Prior = case when SequenceNum = 1 then 'NoPriorPurchase'
										else b.CustomerSegment2
									end,
		a.customersegmentfnlPrior = case when SequenceNum = 1 then 'NoPriorPurchase'
										else b.CustomerSegmentFnl
									end
	from Staging.TempDMPurchaseOrders a left join
		(select distinct NewSeg, CustomerSegment2, CustomerSegmentFnl, CustomerSegment
		 from DataWarehouse.Mapping.RFMComboLookup
		 where NewSeg is not null) b on a.NewsegPrior = b.NewSeg
        
	--digital only or physical only order?
    ;with cteDigital(OrderID) as
    (
        select distinct poi.OrderID
        from Staging.ValidPurchaseOrderItems poi (nolock)
        where 
            left(poi.StockItemID, 2) in ('DV', 'DA', 'DT')  -- Added Digital and physical Transcripts for the flag based on Joe's request -- PR -- 3/07/2017 ** xxx **
		except            
        select distinct poi.OrderID
        from Staging.ValidPurchaseOrderItems poi (nolock)
        where 
            left(poi.StockItemID, 2) in ('PD', 'PC', 'PV', 'PA', 'PM', 'LA', 'LC', 'LD', 'LV','PT')		-- PR -- 3/07/2017 ** xxx **
    )
    update po
    set po.FlagDigitalPhysical = 'Digital Only'
    from Staging.TempDMPurchaseOrders po
    join cteDigital cte on cte.OrderID = po.OrderID

    ;with ctePhysical(OrderID) as
    (
        select distinct poi.OrderID
        from Staging.ValidPurchaseOrderItems poi (nolock)
        where 
            left(poi.StockItemID, 2) in ('PD', 'PC', 'PV', 'PA', 'PM', 'LA', 'LC', 'LD', 'LV', 'PT')		-- PR -- 3/07/2017 ** xxx **
		except            
        select distinct poi.OrderID
        from Staging.ValidPurchaseOrderItems poi (nolock)
        where 
            left(poi.StockItemID, 2) in ('DV', 'DA', 'DT')		-- PR -- 3/07/2017 ** xxx **
    )
    update po
    set po.FlagDigitalPhysical = 'Physical Only'
    from Staging.TempDMPurchaseOrders po
    join ctePhysical cte on cte.OrderID = po.OrderID
    
    ;with cteBoth(OrderID) as
    (
        select distinct poi.OrderID
        from Staging.ValidPurchaseOrderItems poi (nolock)
        where 
            left(poi.StockItemID, 2) in ('PD', 'PC', 'PV', 'PA', 'PM', 'LA', 'LC', 'LD', 'LV','PT')		-- PR -- 3/07/2017 ** xxx **
		intersect
        select distinct poi.OrderID
        from Staging.ValidPurchaseOrderItems poi (nolock)
        where 
            left(poi.StockItemID, 2) in ('DV', 'DA', 'DT')		-- PR -- 3/07/2017 ** xxx **
    )
    update po
    set po.FlagDigitalPhysical = 'Both'
    from Staging.TempDMPurchaseOrders po
    join cteBoth cte on cte.OrderID = po.OrderID
    
    update po
    set po.FlagDigitalPhysical = 'None'
    from Staging.TempDMPurchaseOrders po
    where isnull(po.FlagDigitalPhysical, '') = ''

	--audio only or video only order?        
    ;with cteVideo(OrderID) as
    (
        select distinct poi.OrderID
        from Staging.ValidPurchaseOrderItems poi (nolock)
        where 
            left(poi.StockItemID, 2) in ('PD', 'DV', 'PV', 'LD', 'LV')
		except
        select distinct poi.OrderID
        from Staging.ValidPurchaseOrderItems poi (nolock)
        where 
            left(poi.StockItemID, 2) in ('PC', 'DA', 'PA', 'LA', 'LC')
    )
    update po
    set po.FlagAudioVideo = 'Video Only'
    from Staging.TempDMPurchaseOrders po
    join cteVideo cte on cte.OrderID = po.OrderID

    ;with cteAudio(OrderID) as
    (
        select distinct poi.OrderID
        from Staging.ValidPurchaseOrderItems poi (nolock)
        where 
            left(poi.StockItemID, 2) in ('PC', 'DA', 'PA', 'LA', 'LC')
		except            
        select distinct poi.OrderID
        from Staging.ValidPurchaseOrderItems poi (nolock)
        where 
	        left(poi.StockItemID, 2) in ('PD', 'DV', 'PV', 'LD', 'LV')
    )
    update po
    set po.FlagAudioVideo = 'Audio Only'
    from Staging.TempDMPurchaseOrders po
    join cteAudio cte on cte.OrderID = po.OrderID
    
    ;with cteBoth(OrderID) as
    (
        select distinct poi.OrderID
        from Staging.ValidPurchaseOrderItems poi (nolock)
        where 
            left(poi.StockItemID, 2) in ('PC', 'DA', 'PA', 'LA', 'LC')
		intersect            
        select distinct poi.OrderID
        from Staging.ValidPurchaseOrderItems poi (nolock)
        where 
	        left(poi.StockItemID, 2) in ('PD', 'DV', 'PV', 'LD', 'LV')
    )
    update po
    set po.FlagAudioVideo = 'Both'
    from Staging.TempDMPurchaseOrders po
    join cteBoth cte on cte.OrderID = po.OrderID
    
    update po
    set po.FlagAudioVideo = 'None'
    from Staging.TempDMPurchaseOrders po
    where isnull(po.FlagAudioVideo, '') = ''
    
    ;with cteCLRCourseStats(OrderID, TotalCLRCourseSales, TotalCLRCourseUnits, TotalCLRCourseParts, StandardSalePriceClrCourses) as
    (
    	select 
        	oi.OrderID,
            sum(oi.TotalSales),
            sum(oi.TotalQuantity),
            sum(oi.TotalParts),
            sum(oi.TotalStandardSalePrice)
        from Marketing.DMPurchaseOrderItems oi (nolock)
        where 
        	oi.FlagCLRCourse = 1
            and oi.FormatMedia <> 'T'
        group by oi.OrderID
    )
    update po set
    	po.FlagHasCLRCourse = 1,
    	po.TotalCLRCourseSales = cte.TotalCLRCourseSales,
        po.TotalCLRCourseUnits = cte.TotalCLRCourseUnits,
        po.TotalCLRCourseParts = cte.TotalCLRCourseParts,
        po.StandardSalePriceClrCourses = cte.StandardSalePriceClrCourses
    from Staging.TempDMPurchaseOrders po
    join cteCLRCourseStats cte on po.OrderID = cte.OrderID
    
	-- Add clearance Sets information
	

   ;with cteCourseSets(OrderID, TotalCLRCourseSales, TotalCLRCourseUnits, TotalCLRCourseParts, StandardSalePriceClrCourses) as
    (
    	select 
        	oi.OrderID,
            sum(oi.TotalSales),
            sum(oi.TotalQuantity),
            sum(oi.TotalParts),
            sum(oi.TotalStandardSalePrice)
        from Marketing.DMPurchaseOrderItems oi (nolock)
        where 
        	oi.FlagCLRCourse = 1
            and oi.FormatMedia <> 'T'
            and oi.BundleID > 0
        group by oi.OrderID
    )
    update po set
    	po.TotalCLRCourseSalesWthSets = cte.TotalCLRCourseSales,
        po.TotalCLRCourseUnitsWthSets = cte.TotalCLRCourseUnits,
        po.TotalCLRCoursePartsWthSets = cte.TotalCLRCourseParts,
        po.StdSalePriceCLRCourseWthSets = cte.StandardSalePriceClrCourses
    from Staging.TempDMPurchaseOrders po
    join cteCourseSets cte on po.OrderID = cte.OrderID
        
    ----------------------------------------------------
    
    
    ;with cteOtherCourseStats(OrderID, TotalOtherCourseSales, TotalOtherCourseUnits, TotalOtherCourseParts, StandardSalePriceOtherCourses) as
    (
    	select 
        	oi.OrderID,
            sum(oi.TotalSales),
            sum(oi.TotalQuantity),
            sum(oi.TotalParts),
            sum(oi.TotalStandardSalePrice)
        from Marketing.DMPurchaseOrderItems oi (nolock)
        where 
        	oi.FlagCLRCourse = 0
            and oi.FormatMedia <> 'T'
        group by oi.OrderID
    )
    update po set
    	po.FlagHasOtherCourse = 1,
    	po.TotalOtherCourseSales = cte.TotalOtherCourseSales,
        po.TotalOtherCourseUnits = cte.TotalOtherCourseUnits,
        po.TotalOtherCourseParts = cte.TotalOtherCourseParts,
        po.StandardSalePriceOtherCourses = cte.StandardSalePriceOtherCourses
    from Staging.TempDMPurchaseOrders po
    join cteOtherCourseStats cte on po.OrderID = cte.OrderID
    ----------------------------------------------------    
    
	-- Add Other Sets information

    
    ;with cteOtherCourseSets (OrderID, TotalOtherCourseSales, TotalOtherCourseUnits, TotalOtherCourseParts, StandardSalePriceOtherCourses) as
    (
    	select 
        	oi.OrderID,
            sum(oi.TotalSales),
            sum(oi.TotalQuantity),
            sum(oi.TotalParts),
            sum(oi.TotalStandardSalePrice)
        from Marketing.DMPurchaseOrderItems oi (nolock)
        where 
        	oi.FlagCLRCourse = 0
            and oi.FormatMedia <> 'T'
            and oi.BundleID > 0
        group by oi.OrderID
    )
    update po set
    	po.TotalOtherCourseSalesWthSets = cte.TotalOtherCourseSales,
        po.TotalOtherCourseUnitsWthSets = cte.TotalOtherCourseUnits,
        po.TotalOtherCoursePartsWthSets = cte.TotalOtherCourseParts,
        po.StdSalePriceOtherCourseWthSets = cte.StandardSalePriceOtherCourses
    from Staging.TempDMPurchaseOrders po
    join cteOtherCourseSets cte on po.OrderID = cte.OrderID
    ----------------------------------------------------
    
    -- update FlagEmailOrder using marketing channel
    -- If promotion type update is delayed, it should still be updated
    update a
    set a.FlagEmailOrder = 1
    from Staging.TempDMPurchaseOrders a join
		(select *
		from staging.mktCatalogCodes
		where DaxMktChannel = 6)b on a.CatalogCode = b.CatalogCode
    
     /*temp fix for DAX discount amount */
     update a
		set a.DiscountAmount = b.TotalCoupons + b.OtherCharges
		from Staging.TempDMPurchaseOrders a join
			DAXImports..DAX_OrderExport b on a.orderid = b.orderid
    
	/* PR 12/30/2016 - added Level2 prior information and digitial and physical sales */ 
        	

	-- Update Prior Level2 information
	update a
	set a.PriorL2PurchaseOrderID = b.PriorPurchaseOrderID,
		a.CustomerSegmentPriorL2 = b.CustomerSegmentPrior,
		a.FrequencyPriorL2 = b.FrequencyPrior,
		a.NewsegPriorL2 = b.NewsegPrior,
		a.NamePriorL2 = b.NamePrior,
		a.A12mfPriorL2 = b.A12mfPrior,
		a.CustomerSegment2PriorL2 = b.CustomerSegment2Prior,
		a.CustomerSegmentFnlPriorL2 = b.CustomerSegmentFnlPrior
	from Staging.TempDMPurchaseOrders a
	join Staging.TempDMPurchaseOrders b on a.CustomerID = b.CustomerID
									and a.SequenceNum = b.SequenceNum + 1


	-- Update digital course information

	UPDATE MO
	SET MO.TotalDigitalCourseParts = T.TP,
		MO.TotalDigitalCourseUnits = T.TQ,
		MO.TotalDigitalCourseSales = T.TS
    FROM Staging.TempDMPurchaseOrders MO, 	
    (SELECT OrderID, SUM(TotalParts) As TP, SUM(TotalQuantity)As TQ, 
    SUM(TotalSales) As TS
    FROM Staging.ValidPurchaseOrderItems (nolock) 
    WHERE left(StockItemID,2) in ('DA','DV','DT') -- Added Digital Transcript in sales and units for digital
    GROUP BY OrderID) T	
    WHERE 
        MO.OrderID = T.OrderID	

		
	-- Update Physical course information

	UPDATE MO
	SET MO.TotalPhysicalCourseParts = T.TP,
		MO.TotalPhysicalCourseUnits = T.TQ,
		MO.TotalPhysicalCourseSales = T.TS
    FROM Staging.TempDMPurchaseOrders MO, 	
    (SELECT OrderID, SUM(TotalParts) As TP, SUM(TotalQuantity)As TQ, 
    SUM(TotalSales) As TS
    FROM Staging.ValidPurchaseOrderItems (nolock) 
    WHERE left(StockItemID,2) in ('PA','PV','PT','PD','PC','PM','LA','LV','LD','LC') -- Added Digital Transcript in sales and units for digital -- FormatMedia in ('D','C','A','V','M')
    GROUP BY OrderID) T	
    WHERE 
        MO.OrderID = T.OrderID	

	-- Update Digital transcript information

	UPDATE MO
	SET MO.TotalDigitalTranscriptParts = T.TP,
		MO.TotalDigitalTranscriptQuantity = T.TQ,
		MO.TotalDigitalTranscriptSales = T.TS
    FROM Staging.TempDMPurchaseOrders MO, 	
    (SELECT OrderID, SUM(TotalParts) As TP, SUM(TotalQuantity)As TQ, 
    SUM(TotalSales) As TS
    FROM Staging.ValidPurchaseOrderItems (nolock) 
    WHERE FormatMedia in ('T')
	and left(stockitemid,2) = 'DT'
    GROUP BY OrderID) T	
    WHERE 
        MO.OrderID = T.OrderID	


	truncate table Marketing.DMPurchaseOrders
    
	insert into Marketing.DMPurchaseOrders
    select * from Staging.TempDMPurchaseOrders (nolock)
    
	truncate table Staging.TempDMPurchaseOrders
END


GO
