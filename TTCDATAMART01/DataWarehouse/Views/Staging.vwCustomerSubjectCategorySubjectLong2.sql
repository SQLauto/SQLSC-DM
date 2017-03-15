SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Staging].[vwCustomerSubjectCategorySubjectLong2] 
AS  
    select   
        mro.CustomerID,   
        mro.Subjectlong2,   
  rank() over (partition by mro.CustomerID order by max(SumParts) desc, max(DateOrdered) desc, max(OrderItemID) desc) RankNum          
    from Staging.MostRecent3Orders_SubjectLong mro (nolock)   
    join   
 (  
        select  
         CustomerID,   
            Subjectlong2,  
            sum(TotalParts) as SumParts  
  from Staging.MostRecent3Orders_SubjectLong (nolock)  
  group by CustomerID, Subjectlong2  
    ) mro2 on mro.CustomerID = mro2.CustomerID and mro.Subjectlong2 = mro2.Subjectlong2  
    group by   
        mro.CustomerID,   
        mro.Subjectlong2  
  
GO
