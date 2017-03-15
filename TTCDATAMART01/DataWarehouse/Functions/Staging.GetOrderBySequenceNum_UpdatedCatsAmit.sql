SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create FUNCTION [Staging].[GetOrderBySequenceNum_UpdatedCatsAmit]
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
        case when oi.CourseID in (550,1426,1474,1487,2031,2044,2133,2368,4294,5511,5630,5657,5932,5943,5964,9331) then 'PR'
			else oi.SubjectCategory2
		end as SubjectCategory2,
        o.CustomerID
    from Marketing.DMpurchaseOrderItems oi (nolock)
    join Marketing.DMpurchaseOrders o (nolock) on OI.OrderID = O.OrderID
    where O.SequenceNum = isnull(@SequenceNum, 0)
GO
