SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create FUNCTION [Staging].[GetOrderBySequenceNum_1]  
(  
 @SequenceNum int = null  
)  
returns table  
as  
 return  
      
    select   
        OI.OrderID,  
        oi.OrderItemID,   
        OI.TotalParts,   
        oi.FormatMedia,     
        OI.FormatAV,  
        oi.FormatAD,  
        oi.SubjectCategory,  
        oi.SubjectCategory2,  
        o.CustomerID,
        it.MediaTypeID
    from Marketing.DMpurchaseOrderItems oi (nolock)  
    join Marketing.DMpurchaseOrders o (nolock) on OI.OrderID = O.OrderID  
    left join DataWarehouse.Staging.InvItem it (nolock) on oi.StockItemID = it.StockItemID
    where O.SequenceNum = isnull(@SequenceNum, 0)   
GO
