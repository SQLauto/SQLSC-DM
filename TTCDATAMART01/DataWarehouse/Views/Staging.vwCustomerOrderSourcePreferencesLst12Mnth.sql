SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Staging].[vwCustomerOrderSourcePreferencesLst12Mnth]
AS
    with cteMRO(CustomerID, OrderSource, SumParts, DateOrdered) as
    (
        select
            CustomerID, 
            isnull(OrderSource,'X') OrderSource,
            sum(Parts) as SumParts,
            max(DateOrdered)
        from Staging.MostRecent3OrdersLst12MnthCDCR (nolock)
        group by CustomerID, OrderSource
    )
    select 
        CustomerID, 
        OrderSource,
        rank() over (partition by CustomerID order by SumParts desc, DateOrdered desc) RankNum            
    from cteMRO



GO
