SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE view [Staging].[vw_MC_CustomerFormatAVPreferences_LTD]
AS
    select 
        mro.CustomerID, 
        mro.FormatAV, 
		rank() over (partition by mro.CustomerID order by max(SumParts) desc, max(DateOrdered) desc, max(OrderItemID) desc) RankNum        
    from Staging.MC_AllOrdersTGCPref_LTD mro (nolock) 
    join 
	(
       	select
        	CustomerID, 
            case when FormatAV = 'M' then 'D' else FormatAV end as FormatAV,
            sum(Parts) as SumParts
		from Staging.MC_AllOrdersTGCPref_LTD (nolock)
		group by CustomerID, case when FormatAV = 'M' then 'D' else FormatAV end 
    ) mro2 on mro.CustomerID = mro2.CustomerID and mro.FormatAV = mro2.FormatAV
    group by 
        mro.CustomerID, 
        mro.FormatAV
    




GO
