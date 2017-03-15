SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [Staging].[GetOrderSubjectCategory2Preferences_1]  
(  
 @OrderSequenceNum int = null  
)  
returns table  
as  
 return  
      
 select   
     OrderID,   
     case when SubjectCategory2 in ('MSC' , 'VA')then 'FA'  
        else  isnull(SubjectCategory2, 'X') end as SubjectCategory2,  
        CustomerID,  
  sum(TotalParts) as SumTotalParts,  
        rank() over (partition by OrderID order by sum(TotalParts) desc, min(OrderItemID)) as RankNum  
 from Staging.GetOrderBySequenceNum(@OrderSequenceNum)          
    where FormatMedia <> 'T'  
 group by OrderID, case when SubjectCategory2 in ('MSC' , 'VA')then 'FA' else  isnull(SubjectCategory2, 'X') end, CustomerID  
GO
