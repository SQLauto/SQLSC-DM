SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [Staging].[vwCustomerFormatADPreferences]
AS
    select 
        mro.CustomerID, 
        mro.FormatAD, 
		rank() over (partition by mro.CustomerID order by max(SumParts) desc, max(DateOrdered) desc, max(OrderItemID) desc) RankNum        
    from Staging.MostRecent3OrdersCDCR mro (nolock) 
    join 
	(
       	select
        	CustomerID, 
            FormatAD,
            sum(Parts) as SumParts
		from Staging.MostRecent3OrdersCDCR (nolock)
		group by CustomerID, FormatAD
    ) mro2 on mro.CustomerID = mro2.CustomerID and mro.FormatAD = mro2.FormatAD
    group by 
        mro.CustomerID, 
        mro.FormatAD

/*
    select 
        mro.CustomerID, 
        mro.FormatAD, 
        max(mro2.SumParts) as MaxParts, 
        max(DateOrdered) as MaxDateOrdered,
        max(OrderItemID) as MaxOrderItemID
    from Staging.MostRecent3OrdersCDCR mro (nolock) 
    join 
	(
       	select
        	CustomerID, 
            FormatAD,
            sum(Parts) as SumParts
		from Staging.MostRecent3OrdersCDCR (nolock)
		group by CustomerID, FormatAD
    ) mro2 on mro.CustomerID = mro2.CustomerID and mro.FormatAD = mro2.FormatAD
    group by 
        mro.CustomerID, 
        mro.FormatAD
*/
GO
