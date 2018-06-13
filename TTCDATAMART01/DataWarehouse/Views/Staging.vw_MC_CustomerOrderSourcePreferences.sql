SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Staging].[vw_MC_CustomerOrderSourcePreferences]
AS
    with cteMRO(CustomerID, OrderSource, SumParts, DateOrdered) as
    (
        select
            CustomerID, 
            isnull(OrderSource,'X') OrderSource,
            sum(Parts) as SumParts,
            max(DateOrdered)
        from Staging.MC_MostRecent3OrdersTGCPref (nolock)
        group by CustomerID, OrderSource
    )
    select 
        CustomerID, 
        OrderSource,
        rank() over (partition by CustomerID order by SumParts desc, DateOrdered desc) RankNum            
    from cteMRO

--    select 
--        mro.CustomerID, 
--        mro.OrderSource, 
--		rank() over (partition by mro.CustomerID order by max(SumParts) desc, max(DateOrdered) desc, max(OrderItemID) desc) RankNum        
--    from Staging.MC_MostRecent3OrdersTGCPref mro (nolock) 
--    join 
--	(
--       	select
--        	CustomerID, 
--            OrderSource,
--            sum(Parts) as SumParts
--		from Staging.MC_MostRecent3OrdersTGCPref (nolock)
--		group by CustomerID, OrderSource
--    ) mro2 on mro.CustomerID = mro2.CustomerID and mro.OrderSource = mro2.OrderSource
--    group by 
--        mro.CustomerID, 
--        mro.OrderSource


GO
