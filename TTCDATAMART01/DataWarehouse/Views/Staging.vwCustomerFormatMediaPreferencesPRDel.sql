SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [Staging].[vwCustomerFormatMediaPreferencesPRDel]
AS
    select 
        mro.CustomerID, 
        mro.FormatMedia, 
		rank() over (partition by mro.CustomerID order by max(DateOrdered) desc, max(SumParts) desc, max(OrderItemID) desc) RankNum        
    from TempFormat_20170117DEL mro (nolock) 
    join 
	(
       	select
        	CustomerID, 
            FormatMedia,
            sum(Parts) as SumParts
		from TempFormat_20170117DEL (nolock)
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
    from TempFormat_20170117DEL mro (nolock) 
    join 
	(
       	select
        	CustomerID, 
            FormatMedia,
            sum(Parts) as SumParts
		from TempFormat_20170117DEL (nolock)
		group by CustomerID, FormatMedia
    ) mro2 on mro.CustomerID = mro2.CustomerID and mro.FormatMedia = mro2.FormatMedia
    group by 
        mro.CustomerID, 
        mro.FormatMedia
       
*/


GO
