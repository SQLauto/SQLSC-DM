SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [Staging].[SP_VL_Load_Seriescategories_del]      
as      
Begin      
      
      
/*Truncate and Load */      
Truncate table [Archive].[TGCPlus_Seriescategories_del]       
    

      
/*Deletes*/      
      
--Delete A from [Archive].[TGCPlus_Seriescategories]  A    
--Join [Staging].VL_ssis_Seriescategories   S    
--On A.id = S.ID    
      
/*Inserts*/      
      
insert into [Archive].[TGCPlus_Seriescategories_del]      
( series_id,	series_categories_id,	ordinal_id,	category_name,DMLastUpdateESTDateTime)      
      
select       
series_id,	series_categories_id,	ordinal_id,	category_name ,getdate()   
from [Staging].VL_ssis_Seriescategories       
      
      
END      
GO
