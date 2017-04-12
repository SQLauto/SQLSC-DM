SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [Staging].[vwValidPurchaseOrderItemsIgnoreReturns] 
as
--(
--	OrderID,
--    CourseID,
--    OrderItemID,
--	DateOrdered,
--	TotalSales,
--    TotalParts,
--	TotalQuantity,
--    FormatMedia,
--    FormatAV,
--    FormatAD,
--    SubjectCategory,
--    SubjectCategory2,    
--    FlagLegacy,
--    StockItemID,
--    CustomerID
--)
--AS
--	/* All order items*/
--	select 
--        OrderID,
--        CourseID,
--        OrderItemID,
--        DateOrdered,
--		TotalSales,
--        TotalParts,
--		TotalQuantity,
--        FormatMedia,
--        FormatAV,
--        FormatAD,
--        SubjectCategory,
--        SubjectCategory2,    
--        FlagLegacy,
--	    StockItemID,
--        CustomerID
--	from Marketing.DMPurchaseOrderItems poi (nolock)
--	where FlagReturn = 0 --and FlagPaymentRejected = 0


select *
from Marketing.DMPurchaseOrderItems poi (nolock)
where FlagReturn = 0 

GO
