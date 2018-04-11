SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create FUNCTION [Staging].[GetOrderBySequenceNumIgnoreReturns]  
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
        o.CustomerID  
    from Marketing.DMpurchaseOrderItems oi (nolock)  
    join Marketing.DMPurchaseOrdersIgnoreReturns o (nolock) on OI.OrderID = O.OrderID  
    where O.SequenceNum = isnull(@SequenceNum, 0)  
GO
