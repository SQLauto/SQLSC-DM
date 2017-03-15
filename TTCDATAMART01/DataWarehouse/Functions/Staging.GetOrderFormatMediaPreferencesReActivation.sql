SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [Staging].[GetOrderFormatMediaPreferencesReActivation]
(
	@OrderSequenceNum int = null
)
returns table
as
	return
    
	select 
    	OrderID, 
        FormatMedia,
        CustomerID,
		SUM(TotalParts) as SumTotalParts, 
        rank() over (partition by OrderID order by SUM(TotalParts) desc, MIN(OrderItemID)) as RankNum
	from Staging.GetOrderBySequenceNumReActivation(@OrderSequenceNum)
    where
        FormatMedia <> 'T'
	group by OrderID, FormatMedia, CustomerID
GO
