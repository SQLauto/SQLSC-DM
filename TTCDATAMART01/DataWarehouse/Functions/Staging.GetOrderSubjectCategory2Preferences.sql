SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create FUNCTION [Staging].[GetOrderSubjectCategory2Preferences]
(
	@OrderSequenceNum int = null
)
returns table
as
	return
    
	select 
    	OrderID, 
        isnull(SubjectCategory2, 'X') as SubjectCategory2,
        CustomerID,
		sum(TotalParts) as SumTotalParts, 
        rank() over (partition by OrderID order by sum(TotalParts) desc, min(OrderItemID)) as RankNum
	from Staging.GetOrderBySequenceNum(@OrderSequenceNum)        
    where FormatMedia <> 'T'
	group by OrderID, SubjectCategory2, CustomerID
GO
