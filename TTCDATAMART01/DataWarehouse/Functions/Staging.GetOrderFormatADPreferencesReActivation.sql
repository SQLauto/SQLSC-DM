SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [Staging].[GetOrderFormatADPreferencesReActivation]
(
	@OrderSequenceNum int = null
)
returns table
as
	return
    
	select 
    	OrderID, 
        FormatAD,
        CustomerID,
		sum(TotalParts) as SumTotalParts, 
        rank() over (partition by OrderID order by sum(TotalParts) desc, min(OrderItemID)) as RankNum
	from Staging.GetOrderBySequenceNumReActivation(@OrderSequenceNum) 
    where FormatAD in ('AN', 'DI')
	group by OrderID, FormatAD, CustomerID
GO
