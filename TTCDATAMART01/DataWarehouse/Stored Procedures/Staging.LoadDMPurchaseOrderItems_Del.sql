SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[LoadDMPurchaseOrderItems_Del]  @AsOfDate datetime = null      
as      
begin      
    set nocount on      
      --declare @AsOfDate datetime = null
    set @AsOfDate = isnull(@AsOfDate, getdate())      
          
    truncate table Staging.TempDMPurchaseOrderItems     
     
/* Removed code from here to Run it one time and do not need to run it everyday. Exec [Staging].[LoadDMPurchaseOrderItems_Legacy] to calc legacy order items */      

 /* <DAX Order Items>        */    
   
 INSERT INTO Staging.TempDMPurchaseOrderItems      
    (      
  OrderID,       
        OrderItemID,       
        DateOrdered,      
  CourseID,       
        BundleID,       
        StockItemID,       
        TotalQuantity,      
  SalesPrice,      
  FlagLegacy,      
  FlagReturn,      
        OriginalOrderID,      
  FlagPaymentRejected,      
        AdCode      
    )      
    select       
        O.OrderID,       
        OI.OrderItemID,       
        O.OrderDate,       
        CASE       
            WHEN B.BundleID IS NULL THEN I.CourseID              
            ELSE B.CourseID      
        END,      
        ISNULL(B.BundleID, 0),       
        case       
            when B.BundleID is null then OI.StockItemID      
            else SUBSTRING(oi.StockItemID, 1, 2) + CONVERT(VARCHAR(10), b.CourseID)              
        end,      
        ISNULL(OI.Quantity, 0),       
        case       
            when B.BundleID is null then isnull(oi.SalesPrice, 0)      
            else isnull(oi.SalesPrice, 0) * b.Portion      
        end,      
        'False',      
        case       
            when oi.Quantity < 0 then 'True'      
            else 'False'      
        end,      
        oi.JSORIGINALSALESID,      
        case       
            when o.PaymentStatus = 2 then 'True'       
            else 'False'      
        end,      
        oi.JSSourceID      
    from Staging.OrderItems oi (nolock)      
    JOIN Staging.InvItem I (nolock) ON OI.StockItemID = I.StockItemID      
    join Staging.Orders o (nolock) on o.OrderID = oi.OrderID      
    LEFT JOIN Mapping.BundleComponents B (nolock) ON I.CourseID = B.BundleID      
    WHERE      
        O.OrderDate < @AsOfDate AND       
        (oI.StockItemID LIKE '[P][TM]%' or OI.StockItemID LIKE '[PL][CD]%' or OI.StockItemID LIKE '[PLD][AV]%') -- PR 5/30/2013 -- changed this to remove 'Streaming items from DMPurchaseorderItems' -- Original -- '[PLSD][AV]%')      
        and I.ItemCategoryID IN ('Course', 'Bundle')      
        and o.OrderStatus <> 4 /* "Cancelled" status*/      
              
    UPDATE oi      
    SET       
    FormatMedia =      
    CASE       
      WHEN StockItemID LIKE 'DA%' THEN 'DL'      
      WHEN StockItemID Like 'DV%' THEN 'DV'      
      ELSE SUBSTRING(StockItemID, 2, 1)      
    END,      
    FormatAV =       
    CASE       
      WHEN SUBSTRING(StockItemID, 2, 1) IN ('A', 'C') THEN 'AU'      
      WHEN SUBSTRING(StockItemID, 2, 1) IN ('D', 'V') THEN 'VI'      
      WHEN SUBSTRING(StockItemID, 2, 1) = 'T' THEN 'P'      
      WHEN SUBSTRING(StockItemID, 2, 1) = 'M' THEN 'M'      
    END,      
    FormatAD =       
    CASE       
      WHEN SUBSTRING(StockItemID, 1, 2) IN ('PA', 'PV', 'LA', 'LV') THEN 'AN'      
      WHEN SUBSTRING(StockItemID, 1, 2) IN ('PC', 'PD', 'DA', 'PM', 'LC', 'LD','DV') THEN 'DI'      
      WHEN SUBSTRING(StockItemID, 1, 2) = 'PT' THEN 'P'      
    END      
    from Staging.TempDMPurchaseOrderItems oi                  
    join Mapping.DMCourse c (nolock) on c.CourseID = oi.CourseID      
     
        
    UPDATE oi      
    SET oi.Parts = mc.CourseParts,      
        oi.TotalParts = mc.CourseParts * oi.TotalQuantity,      
        oi.CourseReleaseDate =       
        case      
            when isnull(mc.ReleaseDate, '') = '' then null      
            else mc.ReleaseDate      
        end,      
        oi.SubjectCategory = mc.SubjectCategory,      
        oi.SubjectCategory2 = mc.SubjectCategory2,      
        oi.CourseName = mc.CourseName,      
        oi.DaysSinceRelease =       
        case      
            when isnull(mc.ReleaseDate, '') = '' then null      
            else datediff(dd, mc.ReleaseDate, oi.DateOrdered)      
        end,      
        oi.FlagNewCourse =                       
        case      
            when datediff(dd, mc.ReleaseDate, oi.DateOrdered) between 0 and 90 then 1                          
            else 0      
        end,      
        oi.FlagCLRCourse = mc.FlagCLRCourse      
 FROM Staging.TempDMPurchaseOrderItems oi       
    join Mapping.DMCourse mc (nolock) on oi.CourseID = mc.CourseID      
          
    UPDATE Staging.TempDMPurchaseOrderItems       
    SET SalesPrice = ABS(SalesPrice),      
        TotalQuantity = - ABS(TotalQuantity),      
        TotalParts = - ABS(TotalParts)      
    WHERE       
  (FlagReturn = 'True' or FlagPaymentRejected = 'True')      
      
    
	update a              
    set a.StandardSalePrice = b.UnitPrice      
    from Staging.TempDMPurchaseOrderItems a join      
          Staging.mktpricingmatrix (nolock) b     
          on a.stockitemid=b.userstockitemid  and b.catalogcode=4 and isnull(b.UnitCurrency,'USD') = 'USD'    


	update a      
    set a.StandardSalePrice = b.UnitPrice      
    from Staging.TempDMPurchaseOrderItems a join      
          Staging.mktpricingmatrix (nolock)  b    
          on a.stockitemid=b.userstockitemid and b.catalogcode=74 and isnull(b.UnitCurrency,'GBP') = 'GBP'
          where a.Orderid in (select distinct OrderID from Staging.vwOrders where CurrencyCode = 'GBP')     

    update a      
    set a.StandardSalePrice = b.UnitPrice      
    from Staging.TempDMPurchaseOrderItems a join      
          Staging.mktpricingmatrix (nolock)  b    
    on a.stockitemid=b.userstockitemid and b.catalogcode=64 and isnull(b.UnitCurrency,'AUD') = 'AUD'
    where a.Orderid in (select distinct OrderID from Staging.vwOrders  where CurrencyCode = 'AUD')   
    

        
    UPDATE Staging.TempDMPurchaseOrderItems SET       
     TotalSales = TotalQuantity * SalesPrice,          
     TotalStandardSalePrice = TotalQuantity * StandardSalePrice          
      
     
      

    
Begin tran  

/*truncate and load both legacy and current order items*/

delete from Marketing.DMPurchaseOrderItems_test   
where FlagLegacy = 0

--Truncate Table Marketing.DMPurchaseOrderItems_test   
  
 /*Legacy Order items  */ 
 
  --     insert into Marketing.DMPurchaseOrderItems_test    
  --  (    
		--OrderID,    
  --      OrderItemID,    
  --      CourseID,    
  --      BundleID,    
  --      StockItemID,    
  --      DateOrdered,    
  --      CourseReleaseDate,    
  --      DaysSinceRelease,    
  --      FormatMedia,    
  --      FormatAD,    
  --      FormatAV,    
  --      CourseName,    
  --      SubjectCategory,    
  --      Parts,    
  --      TotalParts,    
  --      TotalQuantity,    
  --      SalesPrice,    
  --      TotalSales,    
  --      PaymentStatus,    
  --      FlagNewCourse,    
  --      FlagReturn,    
  --      FlagPaymentRejected,    
  --      FlagLegacy,    
  --      SubjectCategory2,    
  --      OriginalOrderID,    
  --      CustomerID,    
  --      AdCode,    
  --      FlagCLRCourse,    
  --      StandardSalePrice,    
  --      TotalStandardSalePrice    
  --  )    
  --  select     
  --oi.OrderID,    
  --      OrderItemID,    
  --      CourseID,    
  --      BundleID,    
  --      StockItemID,    
  --      oi.DateOrdered,    
  --      CourseReleaseDate,    
  --      DaysSinceRelease,    
  --      FormatMedia,    
  --      FormatAD,    
  --      FormatAV,    
  --      CourseName,    
  --      SubjectCategory,    
  --      Parts,    
  --      TotalParts,    
  --      TotalQuantity,    
  --      SalesPrice,    
  --      TotalSales,    
  --      PaymentStatus,    
  --      FlagNewCourse,    
  --      FlagReturn,    
  --      FlagPaymentRejected,    
  --      oi.FlagLegacy,    
  --      SubjectCategory2,    
  --      OriginalOrderID,    
  --      CustomerID,    
  --      case oi.FlagLegacy    
  --       when 'True' then o.AdCode    
  --          else oi.AdCode    
  --end,    
  --      FlagCLRCourse,    
  --      StandardSalePrice,    
  --      TotalStandardSalePrice    
  --  from Legacy.DMPurchaseOrderItems  oi (nolock)    
  --  join Staging.vwOrders o (nolock) on o.OrderID = oi.OrderID      
 
/*Current Order items  */
    insert into Marketing.DMPurchaseOrderItems_test    
    (    
		OrderID,    
        OrderItemID,    
        CourseID,    
        BundleID,    
        StockItemID,    
        DateOrdered,    
        CourseReleaseDate,    
        DaysSinceRelease,    
        FormatMedia,    
        FormatAD,    
        FormatAV,    
        CourseName,    
        SubjectCategory,    
        Parts,    
        TotalParts,    
        TotalQuantity,    
        SalesPrice,    
        TotalSales,    
        PaymentStatus,    
        FlagNewCourse,    
        FlagReturn,    
        FlagPaymentRejected,    
        FlagLegacy,    
        SubjectCategory2,    
        OriginalOrderID,    
        CustomerID,    
        AdCode,    
        FlagCLRCourse,    
        StandardSalePrice,    
        TotalStandardSalePrice    
    )    
    select     
		oi.OrderID,    
        OrderItemID,    
        CourseID,    
        BundleID,    
        StockItemID,    
        oi.DateOrdered,    
        CourseReleaseDate,    
        DaysSinceRelease,    
        FormatMedia,    
        FormatAD,    
        FormatAV,    
        CourseName,    
        SubjectCategory,    
        Parts,    
        TotalParts,    
        TotalQuantity,    
        SalesPrice,    
        TotalSales,    
        PaymentStatus,    
        FlagNewCourse,    
        FlagReturn,    
        FlagPaymentRejected,    
        oi.FlagLegacy,    
        SubjectCategory2,    
        OriginalOrderID,    
        CustomerID,    
        case oi.FlagLegacy    
         when 'True' then o.AdCode    
            else oi.AdCode    
  end,    
        FlagCLRCourse,    
        StandardSalePrice,    
        TotalStandardSalePrice    
    from Staging.TempDMPurchaseOrderItems oi (nolock)    
    join Staging.vwOrders o (nolock) on o.OrderID = oi.OrderID    
        
Commit tran      

    truncate table Staging.TempDMPurchaseOrderItems     


End

GO
