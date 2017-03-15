SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [Staging].[vwCustomerFormatAVPreferences]
AS
    select 
        mro.CustomerID, 
        mro.FormatAV, 
		rank() over (partition by mro.CustomerID order by max(SumParts) desc, max(DateOrdered) desc, max(OrderItemID) desc) RankNum        
    from Staging.MostRecent3OrdersCDCR mro (nolock) 
    join 
	(
       	select
        	CustomerID, 
            FormatAV,
            sum(Parts) as SumParts
		from Staging.MostRecent3OrdersCDCR (nolock)
		group by CustomerID, FormatAV
    ) mro2 on mro.CustomerID = mro2.CustomerID and mro.FormatAV = mro2.FormatAV
    group by 
        mro.CustomerID, 
        mro.FormatAV
        
/*
    select 
        mro.CustomerID, 
        mro.FormatAV, 
        max(mro2.SumParts) as MaxParts, 
        max(DateOrdered) as MaxDateOrdered, 
        max(OrderItemID) as MaxOrderItemID
    from Staging.MostRecent3OrdersCDCR mro (nolock) 
    join 
	(
       	select
        	CustomerID, 
            FormatAV,
            sum(Parts) as SumParts
		from Staging.MostRecent3OrdersCDCR (nolock)
		group by CustomerID, FormatAV
    ) mro2 on mro.CustomerID = mro2.CustomerID and mro.FormatAV = mro2.FormatAV
    group by 
        mro.CustomerID, 
        mro.FormatAV        
*/
GO
