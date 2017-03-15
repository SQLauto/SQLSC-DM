SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [Staging].[SP_VL_Load_Seriescategories]      
as      
Begin      


/*Update Previous Counts*/
exec SP_TGCPlus_UpdatePreviousCounts @TGCPlusTableName = 'TGCPlus_Seriescategories'
      
/*Truncate and Load */      
--Truncate table [Archive].[TGCPlus_Seriescategories]       
    
     
/*Deletes*/      
      
Delete A from [Archive].[TGCPlus_Seriescategories]  A    
Join [Staging].VL_ssis_Seriescategories   S    
On A.series_id = S.series_id    
      
/*Inserts*/      
      
insert into [Archive].[TGCPlus_Seriescategories]      
( series_id,	series_categories_id,	ordinal_id,	category_name,DMLastUpdateESTDateTime)      
      
select       
series_id,	series_categories_id,	ordinal_id,	category_name ,getdate()   
from [Staging].VL_ssis_Seriescategories       
      


/*Update Counts*/
exec SP_TGCPlus_UpdateCurrentCounts @TGCPlusTableName = 'TGCPlus_Seriescategories'
      
END      

GO
