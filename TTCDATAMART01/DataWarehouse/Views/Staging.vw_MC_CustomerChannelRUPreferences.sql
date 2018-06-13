SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE view [Staging].[vw_MC_CustomerChannelRUPreferences]
AS
    select 
        mro.CustomerID, 
        mro.MD_ChannelRU, 
		rank() over (partition by mro.CustomerID order by max(Orders) desc, max(DateOrdered) desc, max(OrderID) desc) RankNum        
    from Staging.MC_MostRecent3OrdersTGCPref mro (nolock) 
    join 
	(
       	select
        	CustomerID, 
            MD_ChannelRU,
            count(distinct orderID) Orders
		from Staging.MC_MostRecent3OrdersTGCPref (nolock)
		group by CustomerID, MD_ChannelRU
    ) mro2 on mro.CustomerID = mro2.CustomerID and mro.MD_ChannelRU = mro2.MD_ChannelRU
    group by 
        mro.CustomerID, 
        mro.MD_ChannelRU





GO
