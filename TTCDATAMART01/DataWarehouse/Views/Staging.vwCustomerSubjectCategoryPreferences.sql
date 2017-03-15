SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Staging].[vwCustomerSubjectCategoryPreferences]
AS
    select 
        mro.CustomerID, 
        mro.SubjectCategory, 
		rank() over (partition by mro.CustomerID order by max(SumParts) desc, max(DateOrdered) desc, max(OrderItemID) desc) RankNum
    from Staging.MostRecent3OrdersCSM mro (nolock) 
    join 
	(
       	select
        	CustomerID, 
            SubjectCategory,
            sum(Parts) as SumParts
		from Staging.MostRecent3OrdersCSM (nolock)
		group by CustomerID, SubjectCategory
    ) mro2 on mro.CustomerID = mro2.CustomerID and mro.SubjectCategory = mro2.SubjectCategory
    group by 
        mro.CustomerID, 
        mro.SubjectCategory
/*
    select 
        mro.CustomerID, 
        mro.SubjectCategory, 
        max(mro2.SumParts) as MaxParts, 
        max(DateOrdered) as MaxDateOrdered, 
        max(OrderItemID) as MaxOrderItemID
    from Staging.MostRecent3OrdersCSM mro (nolock) 
    join 
	(
       	select
        	CustomerID, 
            SubjectCategory,
            sum(Parts) as SumParts
		from Staging.MostRecent3OrdersCSM (nolock)
		group by CustomerID, SubjectCategory
    ) mro2 on mro.CustomerID = mro2.CustomerID and mro.SubjectCategory = mro2.SubjectCategory
    group by 
        mro.CustomerID, 
        mro.SubjectCategory
*/
GO
