SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



Create view [Staging].[vwCustomerFormatMediaPreferencesLst12Mnth]
AS
    select 
        mro.CustomerID, 
        mro.FormatMedia, 
		rank() over (partition by mro.CustomerID order by max(DateOrdered) desc, max(SumParts) desc, max(OrderItemID) desc) RankNum        
    from MostRecent3OrdersLst12MnthCDCR mro (nolock) 
    join 
	(
       	select
        	CustomerID, 
            FormatMedia,
            sum(Parts) as SumParts
		from MostRecent3OrdersLst12MnthCDCR (nolock)
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
    from MostRecent3OrdersLst12MnthCDCR mro (nolock) 
    join 
	(
       	select
        	CustomerID, 
            FormatMedia,
            sum(Parts) as SumParts
		from MostRecent3OrdersLst12MnthCDCR (nolock)
		group by CustomerID, FormatMedia
    ) mro2 on mro.CustomerID = mro2.CustomerID and mro.FormatMedia = mro2.FormatMedia
    group by 
        mro.CustomerID, 
        mro.FormatMedia
       
*/



GO
