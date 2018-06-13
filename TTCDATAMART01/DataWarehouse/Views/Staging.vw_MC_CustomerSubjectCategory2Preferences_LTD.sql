SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Staging].[vw_MC_CustomerSubjectCategory2Preferences_LTD]
AS
    select 
        mro.CustomerID, 
        mro.SubjectCategory2, 
        max(mro2.SumParts) as MaxParts, 
        max(DateOrdered) as MaxDateOrdered, 
        max(OrderItemID) as MaxOrderItemID
    from Staging.MC_AllOrdersTGCPref_LTD mro (nolock) 
    join 
	(
       	select
        	CustomerID, 
            SubjectCategory2,
            sum(Parts) as SumParts
		from Staging.MC_AllOrdersTGCPref_LTD (nolock)
		group by CustomerID, SubjectCategory2
    ) mro2 on mro.CustomerID = mro2.CustomerID and mro.SubjectCategory2 = mro2.SubjectCategory2
    group by 
        mro.CustomerID, 
        mro.SubjectCategory2

GO
