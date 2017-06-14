SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [Staging].[vwCustomerOrderSourcePreferencesLst12MnthRU]
AS
    with cteMRO(CustomerID, OrderSourceRU, SumParts, DateOrdered) as
    (
        select
            CustomerID, 
			case when OrderSource in ('W','P','M','E') then OrderSource
				else 'O'
			end as OrderSourceRU,
          -- isnull(OrderSource,'X') OrderSource,
            sum(Parts) as SumParts,
            max(DateOrdered) DateOrdered
        from Staging.MostRecent3OrdersLst12MnthCDCR (nolock)
        group by CustomerID, 
			case when OrderSource in ('W','P','M','E') then OrderSource
				else 'O'
			end,
			isnull(OrderSource,'X')
    )
    select 
        CustomerID, 
        OrderSourceRU,
		--OrderSource,
        rank() over (partition by CustomerID order by SumParts desc, DateOrdered desc) RankNum            
    from cteMRO





GO
