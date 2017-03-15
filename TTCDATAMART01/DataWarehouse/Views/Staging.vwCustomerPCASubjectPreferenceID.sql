SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Staging].[vwCustomerPCASubjectPreferenceID]
AS
    select 
        mro.CustomerID, 
        mro.SubjectPreferenceID, 
		rank() over (partition by mro.CustomerID order by max(SumParts) desc, max(DateOrdered) desc, max(OrderItemID) desc, max(CourseID)) RankNum        
    from Staging.MostRecent3Orders mro (nolock) 
    join 
	(
       	select
        	CustomerID, 
            SubjectPreferenceID,
            sum(Parts) as SumParts
		from Staging.MostRecent3Orders (nolock)
		group by CustomerID, SubjectPreferenceID
    ) mro2 on mro.CustomerID = mro2.CustomerID and mro.SubjectPreferenceID = mro2.SubjectPreferenceID
    group by 
        mro.CustomerID, 
        mro.SubjectPreferenceID
GO
