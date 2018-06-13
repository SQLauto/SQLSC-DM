SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [Staging].[vw_MC_CustomerFormatADPreferences]
AS
    select 
        mro.CustomerID, 
        mro.FormatAD, 
		rank() over (partition by mro.CustomerID order by max(SumParts) desc, max(DateOrdered) desc, max(OrderItemID) desc) RankNum        
    from Staging.MC_MostRecent3OrdersTGCPref mro (nolock) 
    join 
	(
       	select
        	CustomerID, 
            FormatAD,
            sum(Parts) as SumParts
		from Staging.MC_MostRecent3OrdersTGCPref (nolock)
		group by CustomerID, FormatAD
    ) mro2 on mro.CustomerID = mro2.CustomerID and mro.FormatAD = mro2.FormatAD
    group by 
        mro.CustomerID, 
        mro.FormatAD


GO
