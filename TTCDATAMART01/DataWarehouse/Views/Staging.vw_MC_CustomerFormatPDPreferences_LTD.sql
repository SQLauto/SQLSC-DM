SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE view [Staging].[vw_MC_CustomerFormatPDPreferences_LTD]
AS
    select 
        mro.CustomerID, 
        case when mro.FormatMedia in ('DL','DV') then 'Digital' else 'Physical' end as FormatPD,
		rank() over (partition by mro.CustomerID order by max(SumParts) desc, max(DateOrdered) desc, max(OrderItemID) desc) RankNum        
    from Staging.MC_AllOrdersTGCPref_LTD mro (nolock) 
    join 
	(
       	select
        	CustomerID, 
            case when FormatMedia in ('DL','DV') then 'Digital' else 'Physical' end as FormatPD,
            sum(Parts) as SumParts
		from Staging.MC_AllOrdersTGCPref_LTD (nolock)
		group by CustomerID, 
			  case when FormatMedia in ('DL','DV') then 'Digital' else 'Physical' end 
    ) mro2 on mro.CustomerID = mro2.CustomerID and mro.FormatPD = mro2.FormatPD
    group by 
        mro.CustomerID, 
        case when mro.FormatMedia in ('DL','DV') then 'Digital' else 'Physical' end 



GO
