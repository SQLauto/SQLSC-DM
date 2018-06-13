SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [Staging].[vw_MC_CustomerFormatMediaPreferences_L12MR3]
AS
    select 
        mro.CustomerID, 
        mro.FormatMedia, 
		rank() over (partition by mro.CustomerID order by max(SumParts) desc, max(DateOrdered) desc, max(OrderItemID) desc) RankNum        
    from Staging.MC_MostRecent3OrdersTGCPref_L12MR3 mro (nolock) 
    join 
	(
       	select
        	CustomerID, 
            FormatMedia,
            sum(Parts) as SumParts
		from Staging.MC_MostRecent3OrdersTGCPref_L12MR3 (nolock)
		group by CustomerID, FormatMedia
    ) mro2 on mro.CustomerID = mro2.CustomerID and mro.FormatMedia = mro2.FormatMedia
    group by 
        mro.CustomerID, 
        mro.FormatMedia



GO
