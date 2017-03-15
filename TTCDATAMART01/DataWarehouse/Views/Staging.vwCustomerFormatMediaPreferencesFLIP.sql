SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [Staging].[vwCustomerFormatMediaPreferencesFLIP]
AS
    select 
        mro.CustomerID, 
        mro.FormatMedia, 
		rank() over (partition by mro.CustomerID order by max(DateOrdered) desc, max(SumParts) desc, max(OrderItemID) desc) RankNum        
    from Staging.MostRecent3OrdersCDCR mro (nolock) 
    join 
	(
       	select
        	CustomerID, 
            FormatMedia,
            sum(Parts) as SumParts
		from Staging.MostRecent3OrdersCDCR (nolock)
		group by CustomerID, FormatMedia
    ) mro2 on mro.CustomerID = mro2.CustomerID and mro.FormatMedia = mro2.FormatMedia
    group by 
        mro.CustomerID, 
        mro.FormatMedia

/*
    select 
        mro.CustomerID, 
        mro.FormatMedia, 
        max(mro2.SumParts) as MaxParts, 
        max(DateOrdered) as MaxDateOrdered, 
        max(OrderItemID) as MaxOrderItemID
    from Staging.MostRecent3OrdersCDCR mro (nolock) 
    join 
	(
       	select
        	CustomerID, 
            FormatMedia,
            sum(Parts) as SumParts
		from Staging.MostRecent3OrdersCDCR (nolock)
		group by CustomerID, FormatMedia
    ) mro2 on mro.CustomerID = mro2.CustomerID and mro.FormatMedia = mro2.FormatMedia
    group by 
        mro.CustomerID, 
        mro.FormatMedia
       
*/

GO
