SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Staging].[vw_MC_CustomerOrderSourcePreferences_L12MR3]
AS
    with cteMRO(CustomerID, OrderSource, SumParts, DateOrdered) as
    (
        select
            CustomerID, 
            isnull(OrderSource,'X') OrderSource,
            sum(Parts) as SumParts,
            max(DateOrdered)
        from Staging.MC_MostRecent3OrdersTGCPref_L12MR3 (nolock)
        group by CustomerID, OrderSource
    )
    select 
        CustomerID, 
        OrderSource,
        rank() over (partition by CustomerID order by SumParts desc, DateOrdered desc) RankNum            
    from cteMRO

GO
