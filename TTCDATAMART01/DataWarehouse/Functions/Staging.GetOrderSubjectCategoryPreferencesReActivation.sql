SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [Staging].[GetOrderSubjectCategoryPreferencesReActivation]
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
	from Staging.GetOrderBySequenceNumReActivation(@OrderSequenceNum)        
    where FormatMedia <> 'T'
	group by OrderID, SubjectCategory, CustomerID
GO
