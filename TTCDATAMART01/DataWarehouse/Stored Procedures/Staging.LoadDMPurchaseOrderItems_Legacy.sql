SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================  
-- Author: Vikram Bondugula  
-- Create date:  07/21/2015  
-- Description: Calculate and Load Data into Legacy DMPurchaseOrderItems 
-- =============================================  
  
CREATE PROCEDURE [Staging].[LoadDMPurchaseOrderItems_Legacy]    
    @AsOfDate datetime = null    
as    
begin    
    set nocount on    
    
    set @AsOfDate = isnull(@AsOfDate, getdate())    
        
    truncate table Legacy.DMPurchaseOrderItems    
    insert into Legacy.DMPurchaseOrderItems    
    (    
        OrderID,     
        OrderItemID,     
        DateOrdered,    
        CourseID,     
        BundleID,     
        StockItemID,     
        TotalQuantity,    
        SalesPrice,    
        FlagReturn,    
        PaymentStatus,    
        FlagLegacy,    
        FlagPaymentRejected    
    )    
    SELECT     
        O.OrderID,     
        OI.OrderItemID,     
        O.DateOrdered,     
        isnull(B.CourseID, i.CourseID) as CourseID,        
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
  case     
   when (oi.Quantity < 0 or oi.SalesPrice < 0 ) then 'True'    
   else 'False'    
     end,    
        oi.PmtStatus,    
        'True',    
        case     
   when oi.PmtStatus IN (4, 8, 13) then 'True'    
   else 'False'    
        end    
    FROM Legacy.OrderItems Oi (nolock)    
    JOIN Staging.InvItem I (nolock) ON OI.StockItemID = I.StockItemID    
    join Legacy.Orders o (nolock) on o.OrderID = oi.OrderID    
    LEFT JOIN Mapping.BundleComponents B (nolock) ON I.CourseID = B.BundleID    
    WHERE    
        O.DateOrdered < @AsOfDate     
        AND (oI.StockItemID LIKE '[P][TM]%' or OI.StockItemID LIKE '[PL][CD]%' or OI.StockItemID LIKE '[PLD][AV]%') -- PR 5/30/2013 -- changed this to remove 'Streaming items from DMPurchaseorderItems' -- Original -- '[PLSD][AV]%')    
        and I.ItemCategoryID IN ('Course', 'Bundle')    
            
 INSERT INTO Legacy.DMPurchaseOrderItems    
    (    
  OrderID,     
        OrderItemID,     
        DateOrdered,    
  CourseID,     
        BundleID,     
        StockItemID,     
        TotalQuantity,    
  SalesPrice,    
  FlagReturn,    
  PaymentStatus,    
  FlagLegacy    
    )    
 SELECT      
        O.OrderID,     
        OI.OrderItemID,     
        O.DateOrdered,    
  200,     
        0,     
        'PA200',     
        OI.Quantity,     
        OI.SalesPrice,    
        0,    
        oi.PmtStatus,    
        'True'    
 FROM Legacy.OrderItems OI (nolock)    
    join Staging.InvItem I (nolock) on OI.StockItemID = I.StockItemID    
    join Legacy.Orders o (nolock) on o.OrderID = oi.OrderID    
 WHERE     
        I.CourseID IN (201, 202, 203, 204, 205, 206, 207) and    
  Quantity > 0 AND    
     SalesPrice > 0    
    
            
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
    from Legacy.DMPurchaseOrderItems oi                
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
 FROM Legacy.DMPurchaseOrderItems oi     
    join Mapping.DMCourse mc (nolock) on oi.CourseID = mc.CourseID    
        
    UPDATE Legacy.DMPurchaseOrderItems     
    SET SalesPrice = ABS(SalesPrice),    
        TotalQuantity = - ABS(TotalQuantity),    
        TotalParts = - ABS(TotalParts)    
    WHERE     
  (FlagReturn = 'True' or FlagPaymentRejected = 'True')    
    
    update a            
    set a.StandardSalePrice = b.UnitPrice    
    from Legacy.DMPurchaseOrderItems a join    
          (select *     
          from Staging.mktpricingmatrix (nolock)    
          where catalogcode=4    
          and isnull(UnitCurrency,'USD') = 'USD') b    
    on a.stockitemid=b.userstockitemid    
    
    update a    
    set a.StandardSalePrice = b.UnitPrice    
    from Legacy.DMPurchaseOrderItems a join    
          (select *     
          from Staging.mktpricingmatrix (nolock)    
          where catalogcode=74    
          and isnull(UnitCurrency,'GBP') = 'GBP') b       
    on a.stockitemid=b.userstockitemid and a.Orderid in (select distinct OrderID from Staging.vwOrders    
                      where CurrencyCode = 'GBP')    
    
    update a    
    set a.StandardSalePrice = b.UnitPrice    
    from Legacy.DMPurchaseOrderItems a join    
          (select *     
          from Staging.mktpricingmatrix (nolock)    
          where catalogcode=64    
          and isnull(UnitCurrency,'AUD') = 'AUD') b       
    on a.stockitemid=b.userstockitemid and a.Orderid in (select distinct OrderID from Staging.vwOrders    
                      where CurrencyCode = 'AUD')    
      
    UPDATE Legacy.DMPurchaseOrderItems SET     
     TotalSales = TotalQuantity * SalesPrice,        
     TotalStandardSalePrice = TotalQuantity * StandardSalePrice        
    
      
           
end    
  
  
  
  
  
GO
