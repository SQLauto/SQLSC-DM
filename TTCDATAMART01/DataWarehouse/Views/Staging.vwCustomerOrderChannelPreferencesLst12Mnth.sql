SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Staging].[vwCustomerOrderChannelPreferencesLst12Mnth]
AS
    with cteMRO(CustomerID, MD_Channel, SumParts, DateOrdered) as
    (
        select
            CustomerID, 
            isnull(b.MD_Channel,'X') MD_Channel,
            sum(Parts) as SumParts,
            max(DateOrdered)
        from Staging.MostRecent3OrdersLst12MnthCDCR (nolock) a join
			Mapping.vwAdcodesAll b on a.Adcode = b.AdCode
        group by CustomerID, MD_Channel
    )
    select 
        CustomerID, 
        MD_Channel,
        rank() over (partition by CustomerID order by SumParts desc, DateOrdered desc) RankNum            
    from cteMRO



GO
