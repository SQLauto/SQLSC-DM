SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[LoadDMCustomerReactivationStaticNew]    
AS    
BEGIN    
 set nocount on    
        
    truncate table Staging.TempDMCustomerReActivationStaticNew    
        
    insert into Staging.TempDMCustomerReActivationStaticNew     
    (    
		CustomerKey,
		CustomerID,     
        CustomerSinceDate,    
		IntlCoursesBin,    
        FlagEMailable,    
        FlagDRTV    
    )    
    select  distinct   
     MO.CustomerKey,
     C.CustomerID,     
        ISNULL(C.CustomerSince, '1/1/1900'),    
        'X',     
        0,    
        0    
    from Staging.Customers C (nolock)    
    inner join Marketing.DMCustomerReActivation MO (nolock)     
    ON c.CustomerID = MO.CustomerID     
        
    UPDATE MCS    
    SET MCS.CustomerSinceDateID = MDO.DateID    
    FROM Staging.TempDMCustomerReActivationStaticNew MCS     
    INNER JOIN DimDate MDO (nolock)    
    ON CONVERT(DATETIME, CONVERT(VARCHAR(10), MCS.CustomerSinceDate , 101))= MDO.[Date]    
        
 /* Update Initial purchase information*/    
    UPDATE MS    
    SET     
     MS.ReActivationOrderID = MO.OrderID,    
        MS.ReActivationAdCode = isnull(MO.AdCode, 0),    
        MS.IntlOrderSource = MO.OrderSource,    
        MS.IntlPurchAmount =     
        CASE     
            WHEN MO.NetOrderAmount <= 1500 THEN MO.NetOrderAmount    
            ELSE 1500    
        END,    
        MS.IntlAvgOrderBin =     
        CASE     
         WHEN MO.NetOrderAmount < 100 THEN 'M1'    
            WHEN MO.NetOrderAmount BETWEEN 100 AND 220 THEN 'M2'    
            WHEN MO.NetOrderAmount > 220 THEN 'M3'    
        END,    
        MS.ReActivationDate = MO.DateOrdered,    
        MS.FlagIntlCouponRedm = MO.FlagCouponRedm,    
  ms.IntlPromotionTypeID = isnull(MO.PromotionType, 0),    
  Ms.IntlParts = isnull(mO.TotalCourseParts, 0),    
        Ms.FlagIntlPurchTran =    
        case    
         when mO.TotalTranscriptSales > 0 then 1    
            else Ms.FlagIntlPurchTran    
        end,    
        ms.IntlNumOfCOurses = isnull(mo.TotalCourseQuantity, 0),    
        ms.IntlCoursesBin =     
        case     
         when mo.TotalCourseQuantity = 1 then '1 Course'    
         when mo.TotalCourseQuantity = 2 then '2 Course'    
         when mo.TotalCourseQuantity = 3 then '3 Course'    
         when mo.TotalCourseQuantity = 4 then '4 Course'    
         when mo.TotalCourseQuantity > 4 then '5+ Course'    
            else 'None'                                                    
        end    
    FROM Staging.TempDMCustomerReActivationStaticNew MS    
    JOIN Marketing.DMCustomerReActivationOrders MO (nolock) ON MS.CustomerKey = MO.CustomerKey    
    WHERE MO.SequenceNum = 1    
        
/*    
    UPDATE MCS    
    SET IntlPromotionType = isnull(MO.PromotionType, 0)    
    FROM Staging.TempDMCustomerReActivationStaticNew MCS INNER JOIN Marketing.DMCustomerReActivationOrders MO (nolock)    
    ON MCS.CustomerID = MO.CustomerID    
    where mo.SequenceNum = 1    
        
    UPDATE DMC    
    SET DMC.IntlParts = isnull(DPO.TotalCourseParts, 0)    
    FROM Staging.TempDMCustomerReActivationStaticNew DMC INNER JOIN  Marketing.DMCustomerReActivationOrders DPO    
    ON DMC.CustomerID = DPO.CustomerID    
    where dpo.SequenceNum = 1        
    
    UPDATE  DMC    
    SET  DMC.FlagIntlPurchTran = 1    
    FROM Staging.TempDMCustomerReActivationStaticNew DMC INNER JOIN Marketing.DMCustomerReActivationOrders DPO    
        ON DMC.CustomerID = DPO.CustomerID     
    WHERE  DPO.SequenceNum = 1 AND    
        DPO.TotalTranscriptSales > 0    
        
*/        
    
    UPDATE MCS    
    SET MCS.ReActivationDateID = MDO.DateID    
    FROM Staging.TempDMCustomerReActivationStaticNew MCS     
    INNER JOIN DimDate MDO (nolock)    
    ON CONVERT(DATETIME, CONVERT(VARCHAR(10), MCS.ReActivationDate, 101)) =  MDO.[Date]    
    
 /* Update Format Media information*/    
    UPDATE Staging.TempDMCustomerReActivationStaticNew SET     
    IntlFormatMediaCat = 'M'     
    WHERE ReActivationOrderID IN     
    (    
        SELECT OrderID     
		FROM Staging.GetOrderFormatMediaPreferencesReActivation(1)    
        GROUP BY OrderID    
        HAVING count(OrderID) > 1    
    )      
               
    UPDATE MCS     
    SET  IntlFormatMediaCat = MOI.FormatMedia,    
        IntlFormatMediaPref = MOI.FormatMedia    
    FROM  Staging.TempDMCustomerReActivationStaticNew MCS     
    INNER JOIN Marketing.DMPurchaseOrderItems MOI (nolock)    
        ON MCS.ReActivationOrderID = MOI.OrderID    
    WHERE    
        MCS.IntlFormatMediaCat = 'X'    
        AND MOI.FormatMedia <> 'T' /*  Added to correct the flaw in people who*/    
                            /* bought both T and regular Media.*/    
    
    UPDATE MCS    
    SET MCS.FlagMediaPrefTied = 1    
    FROM Staging.TempDMCustomerReActivationStaticNew mcs    
    where     
     mcs.IntlFormatMediaCat = 'M'    
     and MCS.ReActivationOrderID in    
        (    
            select v.OrderID    
            from Staging.GetOrderFormatMediaPreferencesReActivation(1) v    
            join Staging.GetOrderFormatMediaPreferencesReActivation(1) v2    
            on v.OrderID = v2.OrderID and v.SumTotalParts = v2.SumTotalParts and v.FormatMedia <> v2.FormatMedia    
            where v.RankNum <= 2    
        )    
    
    UPDATE cs    
    SET IntlFormatMediaPref = v.FormatMedia    
    FROM Staging.TempDMCustomerReActivationStaticNew cs    
    join Staging.GetOrderFormatMediaPreferencesReActivation(1) v     
    on cs.ReActivationOrderID = v.OrderID    
    where     
     v.RankNum = 1    
        and cs.IntlFormatMediaCat = 'M'            
        
 /* AV*/    
    UPDATE Staging.TempDMCustomerReActivationStaticNew SET     
    IntlFormatAVCat = 'M' WHERE     
    ReActivationOrderID IN     
    (    
        select v.OrderID    
        from Staging.GetOrderFormatAVPreferencesReActivation(1) v    
        group by v.OrderID    
        having count(v.OrderID) > 1    
    )    
        
 /* Update FromratAVCat/Pref*/    
    UPDATE MCS     
    SET  IntlFormatAVCat = MOI.FormatAV,    
        IntlFormatAVPref = MOI.FormatAV    
    FROM  Staging.TempDMCustomerReActivationStaticNew MCS     
    INNER JOIN Marketing.DMpurchaseOrderItems MOI (nolock)    
        ON MCS.ReActivationOrderID = MOI.OrderID    
    WHERE    
        MCS.IntlFormatAVCat = 'X' AND    
        MOI.FormatAV <> 'P' /**/    
        
    UPDATE  MCS     
    SET  IntlFormatAVCat = MOI.FormatAV,    
        IntlFormatAVPref = MOI.FormatAV    
    FROM  Staging.TempDMCustomerReActivationStaticNew MCS     
    INNER JOIN Marketing.DMpurchaseOrderItems MOI (nolock)    
    ON  MCS.ReActivationOrderID = MOI.OrderID    
    WHERE      
        MCS.IntlFormatAVCat = 'X' AND    
        MOI.FormatAV = 'P' /* Added to correct the flaw in people who*/    
                            /* bought both T and regular Media.*/    
    
  /* Next block of code added to fix Customers who purchased both */    
  /* T and regular Media  */    
    
    UPDATE MCS    
    SET MCS.FlagFormatAVPrefTied = 1    
    FROM Staging.TempDMCustomerReActivationStaticNew mcs    
    where     
     mcs.IntlFormatAVCat = 'M'    
     and MCS.ReActivationOrderID in    
        (    
            select v.OrderID    
            from Staging.GetOrderFormatAVPreferencesReActivation(1) v    
            join Staging.GetOrderFormatAVPreferencesReActivation(1) v2    
            on v.OrderID = v2.OrderID and v.SumTotalParts = v2.SumTotalParts and v.FormatAV <> v2.FormatAV    
            where v.RankNum <= 2    
        )    
    
    UPDATE cs    
    SET IntlFormatAVPref = v.FormatAV    
    FROM Staging.TempDMCustomerReActivationStaticNew cs    
    join Staging.GetOrderFormatAVPreferencesReActivation(1) v     
    on cs.ReActivationOrderID = v.OrderID    
    where     
     v.RankNum = 1    
        and cs.IntlFormatAVCat = 'M'     
        
    /*AD*/    
    UPDATE Staging.TempDMCustomerReActivationStaticNew SET     
    IntlFormatADCat = 'M' WHERE     
    ReActivationOrderID IN     
    (    
        select v.OrderID    
        from Staging.GetOrderFormatADPreferencesReActivation(1) v    
        group by v.OrderID    
        having count(v.OrderID) > 1    
    )    
    
  UPDATE MCS     
        SET IntlFormatADCat = MOI.FormatAD,    
            IntlFormatADPref = MOI.FormatAD    
        FROM Staging.TempDMCustomerReActivationStaticNew MCS     
        INNER JOIN Marketing.DMpurchaseOrderItems MOI (nolock)    
        ON  MCS.ReActivationOrderID = MOI.OrderID    
        WHERE     
            MCS.IntlFormatADCat = 'X' AND    
    /* Next block of code added to fix Flaw in logic for T and Regular Format Media Customers*/    
            MOI.FormatAD <> 'P'       
      
    UPDATE MCS     
    SET IntlFormatADCat = MOI.FormatAD,    
        IntlFormatADPref = MOI.FormatAD    
    FROM Staging.TempDMCustomerReActivationStaticNew MCS     
    INNER JOIN Marketing.DMpurchaseOrderItems MOI (nolock)    
    ON  MCS.ReActivationOrderID = MOI.OrderID    
    WHERE     
        MCS.IntlFormatADCat = 'X' AND    
        MOI.FormatAD = 'P'     
    
    UPDATE MCS    
    SET MCS.FlagFormatADPrefTied = 1    
    FROM Staging.TempDMCustomerReActivationStaticNew mcs    
    where     
     mcs.IntlFormatADCat = 'M'    
     and MCS.ReActivationOrderID in    
        (    
            select v.OrderID    
            from Staging.GetOrderFormatADPreferencesReActivation(1) v    
            join Staging.GetOrderFormatADPreferencesReActivation(1) v2    
            on v.OrderID = v2.OrderID and v.SumTotalParts = v2.SumTotalParts and v.FormatAD <> v2.FormatAD    
            where v.RankNum <= 2    
        )    
    
    UPDATE cs    
    SET IntlFormatADPref = v.FormatAD    
    FROM Staging.TempDMCustomerReActivationStaticNew cs    
    join Staging.GetOrderFormatADPreferencesReActivation(1) v     
    on cs.ReActivationOrderID = v.OrderID    
    where     
     v.RankNum = 1    
        and cs.IntlFormatADCat = 'M'    
    
 /*SubjectCategory*/    
    UPDATE cs    
    SET cs.IntlSubjectCat = 'M'     
    from Staging.TempDMCustomerReActivationStaticNew cs        
    WHERE ReActivationOrderID IN     
    (    
        select v.OrderID    
        from Staging.GetOrderSubjectCategoryPreferencesReActivation(1) v    
        group by v.OrderID    
        having count(v.OrderID) > 1    
    )    
    
    UPDATE MCS     
    SET     
     IntlSubjectCat = isnull(MOI.SubjectCategory, 'X'),    
        IntlSubjectPref = isnull(MOI.SubjectCategory, 'X'),    
        InitialPurchaseSubjectPreference2 = isnull(MOI.SubjectCategory2, 'X')    
    FROM Staging.TempDMCustomerReActivationStaticNew MCS     
    INNER JOIN Marketing.DMpurchaseOrderItems MOI (nolock)     
    ON MCS.ReActivationOrderID = MOI.OrderID    
    WHERE     
        MCS.IntlSubjectCat = 'X'     
        and MOI.FormatMedia <> 'T'       
        
    UPDATE MCS    
    SET MCS.FlagIntlSubjectPrefTied = 1    
    FROM Staging.TempDMCustomerReActivationStaticNew mcs    
    where     
     mcs.IntlSubjectCat = 'M'    
     and MCS.ReActivationOrderID in    
        (    
            select v.OrderID    
            from Staging.GetOrderSubjectCategoryPreferencesReActivation(1) v    
            join Staging.GetOrderSubjectCategoryPreferencesReActivation(1) v2    
            on v.OrderID = v2.OrderID and v.SumTotalParts = v2.SumTotalParts and v.SubjectCategory <> v2.SubjectCategory    
            where v.RankNum <= 2    
        )    
    
    update cs    
    set cs.IntlSubjectPref = v.SubjectCategory
	from Staging.TempDMCustomerReActivationStaticNew cs    
    join Staging.GetOrderSubjectCategoryPreferencesReActivation(1) v     
    on cs.ReActivationOrderID = v.OrderID    
    where   
     v.RankNum = 1    
        and cs.IntlSubjectCat = 'M'    
            
    update cs    
    set cs.InitialPurchaseSubjectPreference2 = v.SubjectCategory2    
    from Staging.TempDMCustomerReActivationStaticNew cs    
    join Staging.GetOrderSubjectCategory2PreferencesReActivation(1) v     
    on cs.ReActivationOrderID = v.OrderID    
    where     
     v.RankNum = 1    
        and cs.IntlSubjectCat = 'M'    
            
    
    /* Update Initial back orderID*/    
     
    --UPDATE  MCO    
    --SET  FlagIntlBackOrder = 1,    
    --        FirstBackOrderID = MCO.ReActivationOrderID    
    --FROM  Staging.TempDMCustomerReActivationStaticNew MCO     
    --INNER JOIN Marketing.DMpurchaseOrders O (nolock)    
    --    ON MCO.ReActivationOrderID = O.OrderID     
    --WHERE  O.OrderShipDays > 2    
      
    --UPDATE  MCO    
    --SET  FirstBackOrderID = T.OrderID    
    --FROM  Staging.TempDMCustomerReActivationStaticNew MCO, (       
    --    SELECT  CustomerID, MIN(OrderID) OrderID from Marketing.DMpurchaseOrders (nolock)    
    --    WHERE OrderShipDays > 2     
    --    GROUP BY CustomerID) T    
    --WHERE  MCO.CustomerID = T.CustomerID AND MCO.FirstBackOrderID = '0'    
    
    /* Update Initial ReturnDate*/    
    UPDATE  MCO    
    SET  MCO.FirstReturnDate = T.ReturnDate    
    FROM  Staging.TempDMCustomerReActivationStaticNew MCO, (    
            SELECT o.CustomerID, MIN(o.DateOrdered) As ReturnDate    
            FROM Marketing.DMpurchaseOrderItems oi (nolock)    
            join Staging.vwOrders o (nolock) on o.OrderID = oi.OrderID    
            WHERE FlagReturn = 1    
            GROUP BY o.CustomerID) T    
    WHERE  MCO.CustomerID = T.CustomerID     
    
    /* Update FirstCouponRedmDate*/    
    UPDATE  MCO    
    SET  MCO.FirstCouponRedmDate = T.CouponDate    
    FROM  Staging.TempDMCustomerReActivationStaticNew MCO, (    
            SELECT CustomerID, MIN(DateOrdered) As CouponDate    
            FROM Staging.vwOrders (nolock) WHERE FlagCouponRedm = 1    
            GROUP BY CustomerID) T    
    WHERE  MCO.CustomerID = T.CustomerID     
    
    /* Update FirstInquirerDate*/    
    UPDATE  MCS    
    SET  MCS.FirstInquirerDate = MCS.CustomerSinceDate    
 FROM  Staging.TempDMCustomerReActivationStaticNew MCS    
    WHERE  CONVERT(DATETIME, CONVERT(VARCHAR(10), MCS.CustomerSinceDate, 101)) < CONVERT(DATETIME, CONVERT(VARCHAR(10), MCS.ReActivationDate, 101))    
    
 /* Update EmailAddress, State, Buyer type, Email Preferences*/    
    UPDATE  MCS    
    SET      
        MCS.FirstEMailAddress = C.Email,    
        MCS.FirstState = c.State,    
        MCS.FirstBuyerType = C.BuyerType    
    FROM Staging.TempDMCustomerReActivationStaticNew MCS     
    INNER JOIN Staging.Customers C (nolock) ON MCS.CustomerID = C.CustomerID    
        
    UPDATE MCS    
    SET MCS.FlagFirstEMailPref = 1    
    FROM Staging.TempDMCustomerReActivationStaticNew MCS INNER JOIN Staging.AccountPreferences (nolock) AP    
        ON MCS.CustomerID = AP.CustomerID     
    WHERE AP.PreferenceID = 'OfferEmail'     
        
    UPDATE MCS    
    SET MCS.FlagFirstEMailPref = isnull(cse.EmailPreferenceValue, 0)    
    FROM Staging.TempDMCustomerReActivationStaticNew MCS     
    JOIN Marketing.DMCustomerStaticEmail cse (nolock) ON MCS.CustomerID = cse.CustomerID     
        
    UPDATE MCS    
    SET MCS.FlagFirstMailPref = 1    
    FROM Staging.TempDMCustomerReActivationStaticNew MCS INNER JOIN Staging.AccountPreferences (nolock) AP    
        ON MCS.CustomerID = AP.CustomerID     
    WHERE AP.PreferenceID = 'Offermail'     
        
    UPDATE MCS    
    SET MCS.FlagFirstMailPref = isnull(cse.MailPreferenceValue, 0)    
    FROM Staging.TempDMCustomerReActivationStaticNew MCS     
    JOIN Marketing.DMCustomerStaticEmail cse (nolock) ON MCS.CustomerID = cse.CustomerID     
 
    UPDATE Staging.TempDMCustomerReActivationStaticNew    
    SET FirstCreateDate = GETDATE()    
        
    UPDATE MCS    
    SET MCS.FirstEMResponseDate = T.MinDateOrdered    
    FROM Staging.TempDMCustomerReActivationStaticNew MCS INNER JOIN     
    (SELECT CustomerID, MIN(DateOrdered) MinDateOrdered FROM     
    Marketing.DMCustomerReActivationOrders O (nolock) INNER JOIN    
    Mapping.DMPromotionType MPT (nolock) ON O.CatalogCode = MPT.CatalogCode WHERE    
    MPT.Category = 'E-campaign' GROUP BY O.CustomerID) T     
    ON MCS.CustomerID = T.CustomerID    
        
    UPDATE MCS    
    SET OrganizationID =     
        CASE      
            WHEN c.CustGroup = 'Library' THEN 1 /* Public Library*/    
            WHEN c.CustGroup = 'Organiz' THEN 2 /* Non Public Library Institute*/    
        ELSE 0 /* Non Institute*/    
        END    
    FROM Staging.TempDMCustomerReActivationStaticNew MCS     
    JOIN Staging.CUSTOMERS C (nolock) ON MCS.CUSTOMERID = C.CUSTOMERID    
        
 /* Update intial promotion type, gender, numhits, dwelltype*/    
    
    UPDATE Staging.TempDMCustomerReActivationStaticNew     
    SET DMIntlCustomerType = 11    
    WHERE INtlSubjectCat <> 'X' AND INtlSubjectCat <> 'HS'    
        
    UPDATE DCS    
    SET DCS.FirstRegion = DR.RegionID    
    FROM Staging.TempDMCustomerReActivationStaticNew DCS INNER JOIN Mapping.DMRegion DR (nolock)    
    ON DCS.FirstState = DR.State    
        
    UPDATE DCS    
    SET     
--     DCS.Gender = DI.Gender, 5/3/12/SK: changed to use Gender from CustomerOverLay rather than DMMPInput     
--  dcs.Gender = isnull(co.Gender, 'X'),  -- PR -- 8/20/2014 -- Update demographics from WebDecisions table    
  dcs.Gender = isnull(left(co.Gender,1), 'X'),    
        DCS.ReliabilityCode = DI.DwellType,    
  DCS.NumOfHits = DI.NumHitsCategory            
    FROM Staging.TempDMCustomerReActivationStaticNew DCS     
    JOIN Mapping.DMMPInput DI (nolock) ON DCS.CustomerID = DI.Customerid    
--    join Mapping.CustomerOverLay co (nolock) on co.CustomerID = dcs.CustomerID  -- PR -- 8/20/2014 -- Update demographics from WebDecisions table    
    join Mapping.CustomerOverlay_WD co (nolock) on co.CustomerID = dcs.CustomerID      
    
/*        
    UPDATE DCS    
    SET DCS.NumOfHits = DH.NumHitsCategory    
    FROM Staging.TempDMCustomerReActivationStaticNew DCS INNER JOIN Mapping.DMMPINput DH    
    ON DCS.CustomerID = DH.Customerid    
        
    UPDATE DCS    
    SET DCS.ReliabilityCode = DH.DWELLTYPE    
    FROM Staging.TempDMCustomerReActivationStaticNew DCS INNER JOIN Mapping.DMMPINput DH    
    ON DCS.CustomerID = DH.Customerid    
*/        
    
    UPDATE Staging.TempDMCustomerReActivationStaticNew     
    SET FlagMailableCollegebuyer = 1    
    WHERE CustomerID IN (SELECT CustomerID FROM Staging.vwValidCustomers (nolock))    
    
    UPDATE Staging.TempDMCustomerReActivationStaticNew    
    SET FlagEMailable = 1     
    --WHERE CustomerID IN (SELECT CustomerID FROM Staging.vwEmailableCustomers (nolock))    
	WHERE CustomerID IN (SELECT CustomerID FROM Marketing.Vw_EPC_EmailPull )  
        
    UPDATE Staging.TempDMCustomerReActivationStaticNew    
    SET FlagMailable = 1     
    WHERE CustomerID IN (SELECT CustomerID FROM Staging.vwMailableCustomers (nolock))    
        
    UPDATE  DCS    
    SET DCS.IntlPartsBin = BI.IntlPartsBin    
    FROM Staging.TempDMCustomerReActivationStaticNew DCS, MarketingCubes.dbo.BinINtlParts BI    
    WHERE DCS.IntlParts BETWEEN BI.MinIntlParts AND BI.MaxIntlParts    
        
/*------------------------------------------------------------------------------*/    
 /*  Code added here to add Second Purchase Parameters    
   Author: J Gorti    
  Date:- 08/10/2005    
      
 */        
        
    UPDATE  DMC    
    SET  DMC.SPFlag = 1,    
        DMC.SPPromotionType = isnull(DPO.PromotionType, 0),    
        DMC.SPFlagCoupon = DPO.FlagCouponRedm,    
        DMC.DSDays = DPO.DownStreamDays,    
   DMC.SPFlag3Mth =     
            CASE WHEN DPO.DownStreamDays < 90 THEN 1    
            ELSE 0    
            END,    
        DMC.SPFlag6Mth =     
            CASE WHEN DPO.DownStreamDays < 180 THEN 1    
            ELSE 0    
            END,    
        DMC.SPFlag12Mth =     
            CASE WHEN DPO.DownStreamDays < 365 THEN 1    
            ELSE 0    
            END,    
        DMC.SPOrderSource = DPO.OrderSource,    
        DMC.SPAmount = isnull(DPO.TotalCourseSales, 0),    
        DMC.SPAdcode = isnull(DPO.AdCode, 0),    
        DMC.SPOrderID = DPO.OrderID,    
        DMC.SPDate = DPO.DateOrdered    
    FROM Staging.TempDMCustomerReActivationStaticNew DMC     
    INNER JOIN Marketing.DMCustomerReActivationOrders DPO (nolock)     
    ON DMC.CustomerKey = DPO.CustomerKey     
    WHERE DPO.SequenceNum = 2    
    
    UPDATE MCS    
    SET MCS.SPDateID = MDO.DateID    
    FROM Staging.TempDMCustomerReActivationStaticNew MCS     
    INNER JOIN DimDate MDO (nolock)    
    ON CONVERT(DATETIME, CONVERT(VARCHAR(10), MCS.SPDate, 101)) =  MDO.[Date]    
    
 /*   
    UPDATE Staging.TempDMCustomerReActivationStaticNew SET     
    SPFormatAV = 'M' WHERE     
    CustomerID IN     
    (    
        select v.CustomerID    
        from Staging.GetOrderFormatAVPreferences(2) v    
        group by v.CustomerID    
        having count(v.CustomerID) > 1    
    )    
    
    UPDATE  DMC    
    SET  DMC.SPFormatAV = F.FormatAV     
    FROM  Staging.TempDMCustomerReActivationStaticNew DMC INNER JOIN Staging.GetOrderFormatAVPreferences(2) F ON     
        DMC.CustomerID = F.CustomerID    
    WHERE DMC.SPFormatAV = 'X'     
    
    UPDATE Staging.TempDMCustomerReActivationStaticNew SET     
    SPFormatAD = 'M' WHERE     
    CustomerID IN     
    (    
        select v.CustomerID    
        from Staging.GetOrderFormatADPreferences(2) v    
        group by v.CustomerID    
        having count(v.CustomerID) > 1    
    )    
    
    UPDATE  DMC    
    SET  DMC.SPFormatAD = F.FormatAD     
    FROM  Staging.TempDMCustomerReActivationStaticNew DMC INNER JOIN Staging.GetOrderFormatADPreferences(2) F ON     
        DMC.CustomerID = F.CustomerID    
    WHERE DMC.SPFormatAD = 'X'     
    
    UPDATE Staging.TempDMCustomerReActivationStaticNew SET     
    SPFormatMedia = 'M' WHERE     
    CustomerID IN     
    (    
        select v.CustomerID    
        from Staging.GetOrderFormatMediaPreferences(2) v    
        group by v.CustomerID    
        having count(v.CustomerID) > 1    
    )    
    
    UPDATE  DMC    
    SET  DMC.SPFormatMedia = F.FormatMedia    
    FROM  Staging.TempDMCustomerReActivationStaticNew DMC INNER JOIN Staging.GetOrderFormatMediaPreferences(2) F ON     
        DMC.CustomerID = F.CustomerID    
    WHERE DMC.SPFormatMedia = 'X'     
    
    UPDATE TempDMCustomerReActivationStaticNew SET     
        SPFormatMedia = 'T',    
        SPFormatAD = 'P',     
        SPFormatAV = 'P'    
    WHERE CustomerID IN     
    (SELECT DISTINCT DPO.CustomerID from Marketing.DMCustomerReActivationOrders DPO (nolock)     
        where    
            DPO.SequenceNum = 2 and DPO.CustomerID IN     
    (SELECT CustomerID FROM TempDMCustomerReActivationStaticNew (nolock) where     
        SPFormatMedia = 'X'))    
    
 /* secondary purchase information */    
    UPDATE Staging.TempDMCustomerReActivationStaticNew SET     
    SPSubjectCat = 'M' WHERE     
    CustomerID IN     
    (    
        select v.CustomerID    
        from Staging.GetOrderSubjectCategoryPreferences(2) v    
        group by v.CustomerID    
        having count(v.CustomerID) > 1    
    )    
        
    UPDATE  DMC    
    SET  DMC.SPSubjectCat = F.SubjectCategory    
    FROM  Staging.TempDMCustomerReActivationStaticNew DMC INNER JOIN Staging.GetOrderSubjectCategoryPreferences(2) F ON     
        DMC.CustomerID = F.CustomerID    
    WHERE DMC.SPSubjectCat = 'X'     
        
    update cs    
    set cs.SPSubjectPref = v.SubjectCategory    
    from Staging.TempDMCustomerReActivationStaticNew cs    
    join Staging.GetOrderSubjectCategoryPreferences(2) v on cs.CustomerID = v.CustomerID    
    where     
     v.RankNum = 1    
        and cs.SPSubjectCat = 'M'    
            
    update cs    
    set cs.SPSubjectPref = cs.SPSubjectCat    
    from Staging.TempDMCustomerReActivationStaticNew cs    
    where     
     cs.SPSubjectPref = 'X'    
            
    update cs    
    set cs.SecondaryPurchaseSubjectPreference2 = v.SubjectCategory2    
    from Staging.TempDMCustomerReActivationStaticNew cs    
    join Staging.GetOrderSubjectCategory2Preferences(2) v on cs.CustomerID = v.CustomerID    
    where     
     v.RankNum = 1    
        and cs.SPSubjectCat = 'M'    
    
    UPDATE  DMC    
    SET  DMC.SPFlagTran = 1    
    FROM Staging.TempDMCustomerReActivationStaticNew DMC INNER JOIN Marketing.DMCustomerReActivationOrders DPO (nolock)    
        ON DMC.CustomerID = DPO.CustomerID     
    WHERE  DPO.SequenceNum = 2 AND    
        DPO.TotalTranscriptSales > 0    
*/    
  UPDATE DMC    
    SET DMC.CountryCode = CCS.CountryCode    
    FROM Staging.TempDMCustomerReActivationStaticNew DMC JOIN    
        Marketing.CampaignCustomerSignature CCS (nolock) ON DMC.CustomerID = CCS.CustomerID    
/*            
 update cs    
    set cs.FlagDRTV = 1    
    from Staging.TempDMCustomerReActivationStaticNew cs    
    join Staging.MktAdCodes ac (nolock) on cs.ReActivationAdCode = ac.AdCode    
    join Staging.MktCatalogCodes cc (nolock) on cc.CatalogCode = ac.CatalogCode    
    where     
     cs.ReActivationDate >= '3/1/2012'    
        and cc.DaxMktChannel = 5    
*/    
 if object_id('Marketing.DMCustomerReActivationStaticNew') is not null     
 drop table Marketing.DMCustomerReActivationStaticNew    
    
 select *    
    into Marketing.DMCustomerReActivationStaticNew    
    from Staging.TempDMCustomerReActivationStaticNew (nolock)    
        
    --truncate table Staging.TempDMCustomerReActivationStaticNew    

CREATE NONCLUSTERED INDEX [IX_DMCustomerReActivationStaticNew]
ON [Marketing].[DMCustomerReActivationStaticNew] ([CustomerKey],[CustomerID])



 if object_id('Marketing.DMCustomerReActivationStaticNewMin') is not null     
 drop table Marketing.DMCustomerReActivationStaticNewMin   


select Customerid, count(*) as NumOfReActivations, min(CustomerKey) CustomerKey 
into datawarehouse.Marketing.DMCustomerReActivationStaticNewMin
from datawarehouse.Marketing.DMCustomerReActivationStaticNew
group by Customerid 


end 
GO
