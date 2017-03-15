SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



  
CREATE PROCEDURE [Staging].[LoadDMCustomerStaticNew]  
AS  
BEGIN  
 set nocount on  
      
    truncate table Staging.TempDMCustomerStaticNew  
      
    insert into Staging.TempDMCustomerStaticNew   
    (  
     CustomerID,   
        CustomerSinceDate,  
  IntlCoursesBin,  
        FlagEMailable,  
        FlagDRTV  
    )  
    select   
     C.CustomerID,   
        ISNULL(C.CustomerSince, '1/1/1900'),  
        'X',   
        0,  
        0  
    from Staging.Customers C (nolock)  
      
    UPDATE MCS  
    SET MCS.CustomerSinceDateID = MDO.DateID  
    FROM Staging.TempDMCustomerStaticNew MCS   
    INNER JOIN DimDate MDO (nolock)  
    ON CONVERT(DATETIME, CONVERT(VARCHAR(10), MCS.CustomerSinceDate , 101))= MDO.[Date]  
      
 /* Update Initial purchase information*/  
    UPDATE MS  
    SET   
     MS.IntlPurchaseOrderID = MO.OrderID,  
        MS.IntlPurchaseAdCode = isnull(MO.AdCode, 0),  
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
        MS.IntlPurchaseDate = MO.DateOrdered,  
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
    FROM Staging.TempDMCustomerStaticNew MS  
    JOIN Marketing.DMPurchaseOrders MO (nolock) ON MS.CustomerID = MO.CustomerID  
    WHERE MO.SequenceNum = 1  
      
/*  
    UPDATE MCS  
    SET IntlPromotionType = isnull(MO.PromotionType, 0)  
    FROM Staging.TempDMCustomerStaticNew MCS INNER JOIN Marketing.DMPurchaseOrders MO (nolock)  
    ON MCS.CustomerID = MO.CustomerID  
    where mo.SequenceNum = 1  
      
    UPDATE DMC  
    SET DMC.IntlParts = isnull(DPO.TotalCourseParts, 0)  
    FROM Staging.TempDMCustomerStaticNew DMC INNER JOIN  Marketing.DMPurchaseOrders DPO  
    ON DMC.CustomerID = DPO.CustomerID  
    where dpo.SequenceNum = 1      
  
    UPDATE  DMC  
    SET  DMC.FlagIntlPurchTran = 1  
    FROM Staging.TempDMCustomerStaticNew DMC INNER JOIN Marketing.DMPurchaseOrders DPO  
        ON DMC.CustomerID = DPO.CustomerID   
    WHERE  DPO.SequenceNum = 1 AND  
        DPO.TotalTranscriptSales > 0  
      
*/      
  
    UPDATE MCS  
    SET MCS.IntlPurchaseDateID = MDO.DateID  
    FROM Staging.TempDMCustomerStaticNew MCS   
    INNER JOIN DimDate MDO (nolock)  
    ON CONVERT(DATETIME, CONVERT(VARCHAR(10), MCS.IntlPurchaseDate, 101)) =  MDO.[Date]  
  
 /* Update Format Media information*/  
    UPDATE Staging.TempDMCustomerStaticNew SET   
    IntlFormatMediaCat = 'M'   
    WHERE IntlPurchaseOrderID IN   
    (  
        SELECT OrderID   
        FROM Staging.GetOrderFormatMediaPreferences(1)  
        GROUP BY OrderID  
        HAVING count(OrderID) > 1  
    )    
             
    UPDATE MCS   
    SET  IntlFormatMediaCat = MOI.FormatMedia,  
        IntlFormatMediaPref = MOI.FormatMedia  
    FROM  Staging.TempDMCustomerStaticNew MCS   
    INNER JOIN Marketing.DMPurchaseOrderItems MOI (nolock)  
        ON MCS.IntlPurchaseOrderID = MOI.OrderID  
    WHERE  
        MCS.IntlFormatMediaCat = 'X'  
        AND MOI.FormatMedia <> 'T' /*  Added to correct the flaw in people who*/  
                            /* bought both T and regular Media.*/  
  
    UPDATE MCS  
    SET MCS.FlagMediaPrefTied = 1  
    FROM Staging.TempDMCustomerStaticNew mcs  
    where   
     mcs.IntlFormatMediaCat = 'M'  
     and MCS.IntlPurchaseOrderID in  
        (  
            select v.OrderID  
            from Staging.GetOrderFormatMediaPreferences(1) v  
            join Staging.GetOrderFormatMediaPreferences(1) v2  
            on v.OrderID = v2.OrderID and v.SumTotalParts = v2.SumTotalParts and v.FormatMedia <> v2.FormatMedia  
            where v.RankNum <= 2  
        )  
  
    UPDATE cs  
    SET IntlFormatMediaPref = v.FormatMedia  
    FROM Staging.TempDMCustomerStaticNew cs  
    join Staging.GetOrderFormatMediaPreferences(1) v   
    on cs.IntlPurchaseOrderID = v.OrderID  
    where   
     v.RankNum = 1  
        and cs.IntlFormatMediaCat = 'M'          
      
 /* AV*/  
    UPDATE Staging.TempDMCustomerStaticNew SET   
    IntlFormatAVCat = 'M' WHERE   
    IntlPurchaseOrderID IN   
    (  
        select v.OrderID  
        from Staging.GetOrderFormatAVPreferences(1) v  
        group by v.OrderID  
        having count(v.OrderID) > 1  
    )  
      
 /* Update FromratAVCat/Pref*/  
    UPDATE MCS   
    SET  IntlFormatAVCat = MOI.FormatAV,  
        IntlFormatAVPref = MOI.FormatAV  
    FROM  Staging.TempDMCustomerStaticNew MCS   
    INNER JOIN Marketing.DMpurchaseOrderItems MOI (nolock)  
        ON MCS.IntlPurchaseOrderID = MOI.OrderID  
    WHERE  
        MCS.IntlFormatAVCat = 'X' AND  
        MOI.FormatAV <> 'P' /**/  
      
    UPDATE  MCS   
    SET  IntlFormatAVCat = MOI.FormatAV,  
        IntlFormatAVPref = MOI.FormatAV  
    FROM  Staging.TempDMCustomerStaticNew MCS   
    INNER JOIN Marketing.DMpurchaseOrderItems MOI (nolock)  
    ON  MCS.IntlPurchaseOrderID = MOI.OrderID  
    WHERE    
        MCS.IntlFormatAVCat = 'X' AND  
        MOI.FormatAV = 'P' /* Added to correct the flaw in people who*/  
                            /* bought both T and regular Media.*/  
  
  /* Next block of code added to fix Customers who purchased both */  
  /* T and regular Media  */  
  
    UPDATE MCS  
    SET MCS.FlagFormatAVPrefTied = 1  
    FROM Staging.TempDMCustomerStaticNew mcs  
    where   
     mcs.IntlFormatAVCat = 'M'  
     and MCS.IntlPurchaseOrderID in  
        (  
            select v.OrderID  
            from Staging.GetOrderFormatAVPreferences(1) v  
            join Staging.GetOrderFormatAVPreferences(1) v2  
            on v.OrderID = v2.OrderID and v.SumTotalParts = v2.SumTotalParts and v.FormatAV <> v2.FormatAV  
            where v.RankNum <= 2  
        )  
  
    UPDATE cs  
    SET IntlFormatAVPref = v.FormatAV  
    FROM Staging.TempDMCustomerStaticNew cs  
    join Staging.GetOrderFormatAVPreferences(1) v   
    on cs.IntlPurchaseOrderID = v.OrderID  
    where   
     v.RankNum = 1  
        and cs.IntlFormatAVCat = 'M'   
      
      
 /* PD*/  
    UPDATE Staging.TempDMCustomerStaticNew SET   
    IntlFormatPDCat = 'M' WHERE   
    IntlPurchaseOrderID IN   
    (  
        select v.OrderID  
        from Staging.GetOrderFormatPDPreferences(1) v  
        group by v.OrderID  
        having count(v.OrderID) > 1  
    )  
      
 /* Update FromratPDCat/Pref*/  
    UPDATE MCS   
    SET  IntlFormatPDCat = MOI.FormatPD,  
        IntlFormatPDPref = MOI.FormatPD  
    FROM  Staging.TempDMCustomerStaticNew MCS   
    INNER JOIN Staging.GetOrderFormatPDPreferences(1) MOI 
        ON MCS.IntlPurchaseOrderID = MOI.OrderID  
    WHERE  
        MCS.IntlFormatPDCat = 'X' AND  MOI.RankNum = 1

      
 
    UPDATE MCS  
    SET MCS.FlagFormatPDPrefTied = 1  
    FROM Staging.TempDMCustomerStaticNew mcs  
    where   
     mcs.IntlFormatPDCat = 'M'  
     and MCS.IntlPurchaseOrderID in  
        (  
            select v.OrderID  
            from Staging.GetOrderFormatPDPreferences(1) v  
            join Staging.GetOrderFormatPDPreferences(1) v2  
            on v.OrderID = v2.OrderID and v.SumTotalParts = v2.SumTotalParts and v.FormatPD <> v2.FormatPD  
            where v.RankNum <= 2  
        )  
  
    UPDATE cs  
    SET IntlFormatPDPref = v.FormatPD  
    FROM Staging.TempDMCustomerStaticNew cs  
    join Staging.GetOrderFormatPDPreferences(1) v   
    on cs.IntlPurchaseOrderID = v.OrderID  
    where   
     v.RankNum = 1  
        and cs.IntlFormatPDCat = 'M'   
        

 /* End PD*/        
      
      
    /*AD*/  
    UPDATE Staging.TempDMCustomerStaticNew SET   
    IntlFormatADCat = 'M' WHERE   
    IntlPurchaseOrderID IN   
    (  
        select v.OrderID  
        from Staging.GetOrderFormatADPreferences(1) v  
        group by v.OrderID  
        having count(v.OrderID) > 1  
    )  
  
    UPDATE MCS   
        SET IntlFormatADCat = MOI.FormatAD,  
            IntlFormatADPref = MOI.FormatAD  
        FROM Staging.TempDMCustomerStaticNew MCS   
        INNER JOIN Marketing.DMpurchaseOrderItems MOI (nolock)  
        ON  MCS.IntlPurchaseOrderID = MOI.OrderID  
        WHERE   
            MCS.IntlFormatADCat = 'X' AND  
    /* Next block of code added to fix Flaw in logic for T and Regular Format Media Customers*/  
            MOI.FormatAD <> 'P'     
    
    UPDATE MCS   
    SET IntlFormatADCat = MOI.FormatAD,  
        IntlFormatADPref = MOI.FormatAD  
    FROM Staging.TempDMCustomerStaticNew MCS   
    INNER JOIN Marketing.DMpurchaseOrderItems MOI (nolock)  
    ON  MCS.IntlPurchaseOrderID = MOI.OrderID  
    WHERE   
        MCS.IntlFormatADCat = 'X' AND  
        MOI.FormatAD = 'P'   
  
    UPDATE MCS  
    SET MCS.FlagFormatADPrefTied = 1  
    FROM Staging.TempDMCustomerStaticNew mcs  
    where   
     mcs.IntlFormatADCat = 'M'  
     and MCS.IntlPurchaseOrderID in  
        (  
            select v.OrderID  
            from Staging.GetOrderFormatADPreferences(1) v  
            join Staging.GetOrderFormatADPreferences(1) v2  
            on v.OrderID = v2.OrderID and v.SumTotalParts = v2.SumTotalParts and v.FormatAD <> v2.FormatAD  
            where v.RankNum <= 2  
        )  
  
    UPDATE cs  
    SET IntlFormatADPref = v.FormatAD  
    FROM Staging.TempDMCustomerStaticNew cs  
    join Staging.GetOrderFormatADPreferences(1) v   
    on cs.IntlPurchaseOrderID = v.OrderID  
    where   
     v.RankNum = 1  
        and cs.IntlFormatADCat = 'M'  
  
  
  
  
 /*SubjectCategory*/  
    UPDATE cs  
    SET cs.IntlSubjectCat = 'M'   
    from Staging.TempDMCustomerStaticNew cs      
    WHERE IntlPurchaseOrderID IN   
    (  
        select v.OrderID  
        from Staging.GetOrderSubjectCategoryPreferences(1) v  
        group by v.OrderID  
        having count(v.OrderID) > 1  
    )  
  
    UPDATE MCS   
    SET   
     IntlSubjectCat = isnull(MOI.SubjectCategory, 'X'),  
        IntlSubjectPref = isnull(MOI.SubjectCategory, 'X')  
       /* ,InitialPurchaseSubjectPreference2 = isnull(MOI.SubjectCategory2, 'X')  */
    FROM Staging.TempDMCustomerStaticNew MCS   
    INNER JOIN Marketing.DMpurchaseOrderItems MOI (nolock)   
    ON MCS.IntlPurchaseOrderID = MOI.OrderID  
    WHERE   
        MCS.IntlSubjectCat = 'X'   
        and MOI.FormatMedia <> 'T'     
      
    UPDATE MCS  
    SET MCS.FlagIntlSubjectPrefTied = 1  
    FROM Staging.TempDMCustomerStaticNew mcs  
    where   
     mcs.IntlSubjectCat = 'M'  
     and MCS.IntlPurchaseOrderID in  
        (  
            select v.OrderID  
            from Staging.GetOrderSubjectCategoryPreferences(1) v  
            join Staging.GetOrderSubjectCategoryPreferences(1) v2  
            on v.OrderID = v2.OrderID and v.SumTotalParts = v2.SumTotalParts and v.SubjectCategory <> v2.SubjectCategory  
            where v.RankNum <= 2  
        )  
  
    update cs  
    set cs.IntlSubjectPref = v.SubjectCategory  
    from Staging.TempDMCustomerStaticNew cs  
    join Staging.GetOrderSubjectCategoryPreferences(1) v   
    on cs.IntlPurchaseOrderID = v.OrderID  
    where   
     v.RankNum = 1  
        and cs.IntlSubjectCat = 'M'  
          
    /*
    update cs  
    set cs.InitialPurchaseSubjectPreference2 = v.SubjectCategory2  
    from Staging.TempDMCustomerStaticNew cs  
    join Staging.GetOrderSubjectCategory2Preferences(1) v   
    on cs.IntlPurchaseOrderID = v.OrderID  
    where   
     v.RankNum = 1  
        and cs.IntlSubjectCat = 'M'  
    */    
  
  
   /* SubjectCategory 2 */  

    UPDATE cs  
    SET cs.InitialPurchaseSubjectCategory2 = 'M'   
    from Staging.TempDMCustomerStaticNew cs      
    WHERE IntlPurchaseOrderID IN   
    (  
        select v.OrderID  
        from Staging.GetOrderSubjectCategory2Preferences_1(1) v  
        group by v.OrderID  
        having count(v.OrderID) > 1  
    )  
  
    UPDATE MCS   
    SET   
     InitialPurchaseSubjectPreference2 = isnull(MOI.SubjectCategory2, 'X'),  
     InitialPurchaseSubjectCategory2 = isnull(MOI.SubjectCategory2, 'X')  
    FROM Staging.TempDMCustomerStaticNew MCS   
    INNER JOIN Staging.GetOrderSubjectCategory2Preferences_1(1) MOI   
    ON MCS.IntlPurchaseOrderID = MOI.OrderID  
    WHERE   
        MCS.InitialPurchaseSubjectCategory2 = 'X'   
        and MOI.RankNum = 1
      
    UPDATE MCS  
    SET MCS.FlagInitialPurchaseSubjectPreference2Tied = 1  
    FROM Staging.TempDMCustomerStaticNew mcs  
    where   
     mcs.InitialPurchaseSubjectCategory2 = 'M'  
     and MCS.IntlPurchaseOrderID in  
        (  
            select v.OrderID  
            from Staging.GetOrderSubjectCategory2Preferences_1(1) v  
            join Staging.GetOrderSubjectCategory2Preferences_1(1) v2  
            on v.OrderID = v2.OrderID and v.SumTotalParts = v2.SumTotalParts and v.SubjectCategory2 <> v2.SubjectCategory2 
            where v.RankNum <= 2  
        )  
  
    update cs  
    set cs.InitialPurchaseSubjectPreference2 = v.SubjectCategory2  
    from Staging.TempDMCustomerStaticNew cs  
    join Staging.GetOrderSubjectCategory2Preferences_1(1) v   
    on cs.IntlPurchaseOrderID = v.OrderID  
    where   
     v.RankNum = 1  and cs.InitialPurchaseSubjectCategory2 = 'M'  
        
   /* End SubjectCategory 2 */  
   


   /* Second Purchase SubjectCategory 2 */  

    UPDATE cs  
    SET cs.SecondaryPurchaseSubjectCategory2 = 'M'   
    from Staging.TempDMCustomerStaticNew cs      
    WHERE SPOrderID IN   
    (  
        select v.OrderID  
        from Staging.GetOrderSubjectCategory2Preferences_1(2) v  
        group by v.OrderID  
        having count(v.OrderID) > 1  
    )  
  
    UPDATE MCS   
    SET   
     SecondaryPurchaseSubjectCategory2 = isnull(MOI.SubjectCategory2, 'X'),  
     SecondaryPurchaseSubjectpreference2 = isnull(MOI.SubjectCategory2, 'X')  
    FROM Staging.TempDMCustomerStaticNew MCS   
    INNER JOIN Staging.GetOrderSubjectCategory2Preferences_1(2) MOI   
    ON MCS.SPOrderID = MOI.OrderID  
    WHERE   
        MCS.SecondaryPurchaseSubjectCategory2 = 'X'   
        and MOI.RankNum = 1
      
    --UPDATE MCS  
    --SET MCS.FlagInitialPurchaseSubjectPreference2Tied = 1  
    --FROM Staging.TempDMCustomerStaticNew mcs  
    --where   
    -- mcs.SecondaryPurchaseSubjectCategory2 = 'M'  
    -- and MCS.SPOrderID in  
    --    (  
    --        select v.OrderID  
    --        from Staging.GetOrderSubjectCategory2Preferences_1(2) v  
    --        join Staging.GetOrderSubjectCategory2Preferences_1(2) v2  
    --        on v.OrderID = v2.OrderID and v.SumTotalParts = v2.SumTotalParts and v.SubjectCategory2 <> v2.SubjectCategory2 
    --        where v.RankNum <= 2  
    --    )  

    update cs  
    set cs.SecondaryPurchaseSubjectPreference2 = v.SubjectCategory2  
    from Staging.TempDMCustomerStaticNew cs  
    join Staging.GetOrderSubjectCategory2Preferences_1(2) v   
    on cs.SPOrderID = v.OrderID  
    where   
     v.RankNum = 1  and cs.SecondaryPurchaseSubjectCategory2 = 'M'  
        
   /* End Second Purchase SubjectCategory 2 */      
  
  
  
    /* Update Initial back orderID*/  
   
    UPDATE  MCO  
    SET  FlagIntlBackOrder = 1,  
            FirstBackOrderID = MCO.IntlPurchaseOrderID  
    FROM  Staging.TempDMCustomerStaticNew MCO   
    INNER JOIN Marketing.DMpurchaseOrders O (nolock)  
        ON MCO.IntlPurchaseOrderID = O.OrderID   
    WHERE  O.OrderShipDays > 2  
    
    UPDATE  MCO  
    SET  FirstBackOrderID = T.OrderID  
    FROM  Staging.TempDMCustomerStaticNew MCO, (     
        SELECT  CustomerID, MIN(OrderID) OrderID from Marketing.DMpurchaseOrders (nolock)  
        WHERE OrderShipDays > 2   
        GROUP BY CustomerID) T  
    WHERE  MCO.CustomerID = T.CustomerID AND MCO.FirstBackOrderID = '0'  
  
    /* Update Initial ReturnDate*/  
    UPDATE  MCO  
    SET  MCO.FirstReturnDate = T.ReturnDate  
    FROM  Staging.TempDMCustomerStaticNew MCO, (  
            SELECT o.CustomerID, MIN(o.DateOrdered) As ReturnDate  
            FROM Marketing.DMpurchaseOrderItems oi (nolock)  
            join Staging.vwOrders o (nolock) on o.OrderID = oi.OrderID  
            WHERE FlagReturn = 1  
            GROUP BY o.CustomerID) T  
    WHERE  MCO.CustomerID = T.CustomerID   
  
    /* Update FirstCouponRedmDate*/  
    UPDATE  MCO  
    SET  MCO.FirstCouponRedmDate = T.CouponDate  
    FROM  Staging.TempDMCustomerStaticNew MCO, (  
            SELECT CustomerID, MIN(DateOrdered) As CouponDate  
            FROM Staging.vwOrders (nolock) WHERE FlagCouponRedm = 1  
            GROUP BY CustomerID) T  
    WHERE  MCO.CustomerID = T.CustomerID   
  
    /* Update FirstInquirerDate*/  
    UPDATE  MCS  
    SET  MCS.FirstInquirerDate = MCS.CustomerSinceDate  
	FROM  Staging.TempDMCustomerStaticNew MCS  
    WHERE  CONVERT(DATETIME, CONVERT(VARCHAR(10), MCS.CustomerSinceDate, 101)) < CONVERT(DATETIME, CONVERT(VARCHAR(10), MCS.IntlPurchaseDate, 101))  
  
  
    UPDATE  MCS  
    SET  MCS.FlagFirstInquirer = 1  
	FROM  Staging.TempDMCustomerStaticNew MCS  
	where MCS.FirstInquirerDate < MCS.IntlPurchaseDate
  
  
 /* Update EmailAddress, State, Buyer type, Email Preferences*/  
    UPDATE  MCS  
    SET    
        MCS.FirstEMailAddress = C.Email,  
        MCS.FirstState = c.State,  
        MCS.FirstBuyerType = C.BuyerType  
    FROM Staging.TempDMCustomerStaticNew MCS   
    INNER JOIN Staging.Customers C (nolock) ON MCS.CustomerID = C.CustomerID  
      
    UPDATE MCS  
    SET MCS.FlagFirstEMailPref = 1  
    FROM Staging.TempDMCustomerStaticNew MCS INNER JOIN Staging.AccountPreferences (nolock) AP  
        ON MCS.CustomerID = AP.CustomerID   
    WHERE AP.PreferenceID = 'OfferEmail'   
      
    UPDATE MCS  
    SET MCS.FlagFirstEMailPref = isnull(cse.EmailPreferenceValue, 0)  
    FROM Staging.TempDMCustomerStaticNew MCS   
    JOIN Marketing.DMCustomerStaticEmail cse (nolock) ON MCS.CustomerID = cse.CustomerID   
      
    UPDATE MCS  
    SET MCS.FlagFirstMailPref = 1  
    FROM Staging.TempDMCustomerStaticNew MCS INNER JOIN Staging.AccountPreferences (nolock) AP  
        ON MCS.CustomerID = AP.CustomerID   
    WHERE AP.PreferenceID = 'Offermail'   
      
    UPDATE MCS  
    SET MCS.FlagFirstMailPref = isnull(cse.MailPreferenceValue, 0)  
    FROM Staging.TempDMCustomerStaticNew MCS   
    JOIN Marketing.DMCustomerStaticEmail cse (nolock) ON MCS.CustomerID = cse.CustomerID   
      
    UPDATE Staging.TempDMCustomerStaticNew  
    SET FirstCreateDate = GETDATE()  
      
    UPDATE MCS  
    SET MCS.FirstEMResponseDate = T.MinDateOrdered  
    FROM Staging.TempDMCustomerStaticNew MCS INNER JOIN   
    (SELECT CustomerID, MIN(DateOrdered) MinDateOrdered FROM   
    Marketing.DMpurchaseOrders O (nolock) INNER JOIN  
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
    FROM Staging.TempDMCustomerStaticNew MCS   
    JOIN Staging.CUSTOMERS C (nolock) ON MCS.CUSTOMERID = C.CUSTOMERID  
      
 /* Update intial promotion type, gender, numhits, dwelltype*/  
  
    UPDATE Staging.TempDMCustomerStaticNew   
    SET DMIntlCustomerType = 11  
    WHERE INtlSubjectCat <> 'X' AND INtlSubjectCat <> 'HS'  
      
    UPDATE DCS  
    SET DCS.FirstRegion = DR.RegionID  
    FROM Staging.TempDMCustomerStaticNew DCS INNER JOIN Mapping.DMRegion DR (nolock)  
    ON DCS.FirstState = DR.State  
      
    UPDATE DCS  
    SET   
--     DCS.Gender = DI.Gender, 5/3/12/SK: changed to use Gender from CustomerOverLay rather than DMMPInput   
--  dcs.Gender = isnull(co.Gender, 'X'),  -- PR -- 8/20/2014 -- Update demographics from WebDecisions table  
  dcs.Gender = isnull(left(co.Gender,1), 'U'),  
        DCS.ReliabilityCode = DI.DwellType,  
  DCS.NumOfHits = DI.NumHitsCategory          
    FROM Staging.TempDMCustomerStaticNew DCS   
   left JOIN Mapping.DMMPInput DI (nolock) ON DCS.CustomerID = DI.Customerid  
--    join Mapping.CustomerOverLay co (nolock) on co.CustomerID = dcs.CustomerID  -- PR -- 8/20/2014 -- Update demographics from WebDecisions table  
   left join Mapping.CustomerOverlay_WD co (nolock) on co.CustomerID = dcs.CustomerID    
  
/*      
    UPDATE DCS  
    SET DCS.NumOfHits = DH.NumHitsCategory  
    FROM Staging.TempDMCustomerStaticNew DCS INNER JOIN Mapping.DMMPINput DH  
    ON DCS.CustomerID = DH.Customerid  
      
    UPDATE DCS  
    SET DCS.ReliabilityCode = DH.DWELLTYPE  
    FROM Staging.TempDMCustomerStaticNew DCS INNER JOIN Mapping.DMMPINput DH  
    ON DCS.CustomerID = DH.Customerid  
*/      
  
    UPDATE Staging.TempDMCustomerStaticNew   
    SET FlagMailableCollegebuyer = 1  
    WHERE CustomerID IN (SELECT CustomerID FROM Staging.vwValidCustomers (nolock))  
  
    UPDATE Staging.TempDMCustomerStaticNew  
    SET FlagEMailable = 1   
    WHERE CustomerID IN (SELECT CustomerID FROM Staging.vwEmailableCustomers (nolock))  
      
    UPDATE Staging.TempDMCustomerStaticNew  
    SET FlagMailable = 1   
    WHERE CustomerID IN (SELECT CustomerID FROM Staging.vwMailableCustomers (nolock))  
      
    UPDATE  DCS  
    SET DCS.IntlPartsBin = BI.IntlPartsBin  
    FROM Staging.TempDMCustomerStaticNew DCS, MarketingCubes.dbo.BinINtlParts BI  
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
    FROM Staging.TempDMCustomerStaticNew DMC   
    INNER JOIN Marketing.DMPurchaseOrders DPO (nolock)   
    ON DMC.CustomerID = DPO.CustomerID   
    WHERE DPO.SequenceNum = 2  
  
    UPDATE MCS  
    SET MCS.SPDateID = MDO.DateID  
    FROM Staging.TempDMCustomerStaticNew MCS   
    INNER JOIN DimDate MDO (nolock)  
    ON CONVERT(DATETIME, CONVERT(VARCHAR(10), MCS.SPDate, 101)) =  MDO.[Date]  
  
  
    UPDATE Staging.TempDMCustomerStaticNew SET   
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
    FROM  Staging.TempDMCustomerStaticNew DMC INNER JOIN Staging.GetOrderFormatAVPreferences(2) F ON   
        DMC.CustomerID = F.CustomerID  
    WHERE DMC.SPFormatAV = 'X'   
  
    UPDATE Staging.TempDMCustomerStaticNew SET   
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
    FROM  Staging.TempDMCustomerStaticNew DMC INNER JOIN Staging.GetOrderFormatADPreferences(2) F ON   
        DMC.CustomerID = F.CustomerID  
    WHERE DMC.SPFormatAD = 'X'   
  
    UPDATE Staging.TempDMCustomerStaticNew SET   
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
    FROM  Staging.TempDMCustomerStaticNew DMC INNER JOIN Staging.GetOrderFormatMediaPreferences(2) F ON   
        DMC.CustomerID = F.CustomerID  
    WHERE DMC.SPFormatMedia = 'X'   
  
    UPDATE Staging.TempDMCustomerStaticNew SET   
        SPFormatMedia = 'T',  
        SPFormatAD = 'P',   
        SPFormatAV = 'P'  
    WHERE CustomerID IN   
    (SELECT DISTINCT DPO.CustomerID from Marketing.DMPurchaseOrders DPO (nolock)   
        where  
            DPO.SequenceNum = 2 and DPO.CustomerID IN   
    (SELECT CustomerID FROM Staging.TempDMCustomerStaticNew (nolock) where   
        SPFormatMedia = 'X'))  
  
 /* secondary purchase information */  
    UPDATE Staging.TempDMCustomerStaticNew SET   
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
    FROM  Staging.TempDMCustomerStaticNew DMC INNER JOIN Staging.GetOrderSubjectCategoryPreferences(2) F ON   
        DMC.CustomerID = F.CustomerID  
    WHERE DMC.SPSubjectCat = 'X'   
      
    update cs  
    set cs.SPSubjectPref = v.SubjectCategory  
    from Staging.TempDMCustomerStaticNew cs  
    join Staging.GetOrderSubjectCategoryPreferences(2) v on cs.CustomerID = v.CustomerID  
    where   
     v.RankNum = 1  
        and cs.SPSubjectCat = 'M'  
          
    update cs  
    set cs.SPSubjectPref = cs.SPSubjectCat  
    from Staging.TempDMCustomerStaticNew cs  
    where   
     cs.SPSubjectPref = 'X'  
          
  /*  update cs  
    set cs.SecondaryPurchaseSubjectPreference2 = v.SubjectCategory2  
    from Staging.TempDMCustomerStaticNew cs  
    join Staging.GetOrderSubjectCategory2Preferences(2) v on cs.CustomerID = v.CustomerID  
    where   
     v.RankNum = 1  
        and cs.SPSubjectCat = 'M'  
   */     
  
    UPDATE  DMC  
    SET  DMC.SPFlagTran = 1  
    FROM Staging.TempDMCustomerStaticNew DMC INNER JOIN Marketing.DMPurchaseOrders DPO (nolock)  
        ON DMC.CustomerID = DPO.CustomerID   
    WHERE  DPO.SequenceNum = 2 AND  
        DPO.TotalTranscriptSales > 0  
  
    UPDATE DMC  
    SET DMC.CountryCode = CCS.CountryCode  
    FROM Staging.TempDMCustomerStaticNew DMC JOIN  
        Marketing.CampaignCustomerSignature CCS (nolock) ON DMC.CustomerID = CCS.CustomerID  
          
 update cs  
    set cs.FlagDRTV = 1  
    from Staging.TempDMCustomerStaticNew cs  
    join Staging.MktAdCodes ac (nolock) on cs.IntlPurchaseAdCode = ac.AdCode  
    join Staging.MktCatalogCodes cc (nolock) on cc.CatalogCode = ac.CatalogCode  
    where   
     cs.IntlPurchaseDate >= '3/1/2012'  
        and cc.DaxMktChannel = 5  
  
 if object_id('Marketing.DMCustomerStaticNew') is not null   
 drop table Marketing.DMCustomerStaticNew  
  
 select *  
    into Marketing.DMCustomerStaticNew  
    from Staging.TempDMCustomerStaticNew (nolock)  
      
    truncate table Staging.TempDMCustomerStaticNew  
end  
  
  
  
GO
