SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [Staging].[vw_MC_CustomerChannelPreferences]
AS
    select 
        mro.CustomerID, 
        mro.MD_Channel, 
		rank() over (partition by mro.CustomerID order by max(Orders) desc, max(DateOrdered) desc, max(OrderID) desc) RankNum        
    from Staging.MC_MostRecent3OrdersTGCPref mro (nolock) 
    join 
	(
       	select
        	CustomerID, 
            MD_Channel,
            count(distinct orderID) Orders
		from Staging.MC_MostRecent3OrdersTGCPref (nolock)
		group by CustomerID, MD_Channel
    ) mro2 on mro.CustomerID = mro2.CustomerID and mro.MD_Channel = mro2.MD_Channel
    group by 
        mro.CustomerID, 
        mro.MD_Channel



GO
