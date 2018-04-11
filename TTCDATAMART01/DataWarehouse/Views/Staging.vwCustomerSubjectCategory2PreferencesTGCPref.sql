SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



create VIEW [Staging].[vwCustomerSubjectCategory2PreferencesTGCPref]
AS
    select 
        mro.CustomerID, 
        mro.SubjectCategory2, 
        max(mro2.SumParts) as MaxParts, 
        max(DateOrdered) as MaxDateOrdered, 
        max(OrderItemID) as MaxOrderItemID
    from Staging.MostRecent3OrdersTGCPref mro (nolock) 
    join 
	(
       	select
        	CustomerID, 
            SubjectCategory2,
            sum(TotalParts) as SumParts
		from Staging.MostRecent3OrdersTGCPref (nolock)
		group by CustomerID, SubjectCategory2
    ) mro2 on mro.CustomerID = mro2.CustomerID and mro.SubjectCategory2 = mro2.SubjectCategory2
    group by 
        mro.CustomerID, 
        mro.SubjectCategory2

GO
