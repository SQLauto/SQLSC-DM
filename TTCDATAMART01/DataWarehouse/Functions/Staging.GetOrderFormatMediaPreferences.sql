SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [Staging].[GetOrderFormatMediaPreferences]
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
	from Staging.GetOrderBySequenceNum(@OrderSequenceNum)
    where
        FormatMedia <> 'T'
	group by OrderID, FormatMedia, CustomerID
GO
