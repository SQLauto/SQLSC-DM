SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Staging].[vwCustomerSubjectCategory2PreferencesCDCR]
AS
    select 
        mro.CustomerID, 
        mro.SubjectCategory2, 
        max(mro2.SumParts) as MaxParts, 
        max(DateOrdered) as MaxDateOrdered, 
        max(OrderItemID) as MaxOrderItemID
    from Staging.MostRecent3OrdersCDCR mro (nolock) 
    join 
	(
       	select
        	CustomerID, 
            SubjectCategory2,
            sum(Parts) as SumParts
		from Staging.MostRecent3OrdersCDCR (nolock)
		group by CustomerID, SubjectCategory2
    ) mro2 on mro.CustomerID = mro2.CustomerID and mro.SubjectCategory2 = mro2.SubjectCategory2
    group by 
        mro.CustomerID, 
        mro.SubjectCategory2
GO
