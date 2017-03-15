SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

    
CREATE FUNCTION [Staging].[GetOrderFormatPDPreferences]    
(    
 @OrderSequenceNum int = null    
)    
returns table    
as    
 return    
   
 select OrderID,     
        CustomerID,    
  sum(TotalParts) as SumTotalParts,     
        rank() over (partition by OrderID order by sum(TotalParts) desc, min(OrderItemID)) as RankNum,    
  case when MediaTypeID in ('DownloadA','DownloadV')   
    then 'DI'  
    else 'PH' end as FormatPD   
 from Staging.GetOrderBySequenceNum_1(@OrderSequenceNum)     
 group by OrderID,CustomerID, case when MediaTypeID in ('DownloadA','DownloadV')   
         then 'DI'  
         else 'PH' end   
GO
