SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [Staging].[GetOrderFormatAVPreferencesReActivation]
(
	@OrderSequenceNum int = null
)
returns table
as
	return
    
	select 
    	OrderID, 
        FormatAV,
        CustomerID,
		sum(TotalParts) as SumTotalParts, 
        rank() over (partition by OrderID order by sum(TotalParts) desc, min(OrderItemID)) as RankNum
	from Staging.GetOrderBySequenceNumReActivation(@OrderSequenceNum)        
    where FormatAV in ('AU', 'VI')
	group by OrderID, FormatAV, CustomerID
GO
