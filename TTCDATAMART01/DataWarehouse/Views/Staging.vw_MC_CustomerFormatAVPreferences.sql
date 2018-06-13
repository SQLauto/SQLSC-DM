SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [Staging].[vw_MC_CustomerFormatAVPreferences]
AS
    select 
        mro.CustomerID, 
        mro.FormatAV, 
		rank() over (partition by mro.CustomerID order by max(SumParts) desc, max(DateOrdered) desc, max(OrderItemID) desc) RankNum        
    from Staging.MC_MostRecent3OrdersTGCPref mro (nolock) 
    join 
	(
       	select
        	CustomerID, 
            FormatAV,
            sum(Parts) as SumParts
		from Staging.MC_MostRecent3OrdersTGCPref (nolock)
		group by CustomerID, FormatAV
    ) mro2 on mro.CustomerID = mro2.CustomerID and mro.FormatAV = mro2.FormatAV
    group by 
        mro.CustomerID, 
        mro.FormatAV
    

GO
