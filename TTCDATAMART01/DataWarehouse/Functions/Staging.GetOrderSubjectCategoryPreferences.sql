SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [Staging].[GetOrderSubjectCategoryPreferences]
(
	@OrderSequenceNum int = null
)
returns table
as
	return
    
	select 
    	OrderID, 
        isnull(SubjectCategory, 'X') as SubjectCategory,
        CustomerID,
		sum(TotalParts) as SumTotalParts, 
        rank() over (partition by OrderID order by sum(TotalParts) desc, min(OrderItemID)) as RankNum
	from Staging.GetOrderBySequenceNum(@OrderSequenceNum)        
    where FormatMedia <> 'T'
	group by OrderID, SubjectCategory, CustomerID
GO
