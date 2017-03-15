SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [Staging].[SP_VL_Load_Seriescategories_20160325]      
as      
Begin      
      
      
/*Truncate and Load */      
Truncate table [Archive].[TGCPlus_Seriescategories]       
    

      
/*Deletes*/      
      
--Delete A from [Archive].[TGCPlus_Seriescategories]  A    
--Join [Staging].VL_ssis_Seriescategories   S    
--On A.id = S.ID    
      
/*Inserts*/      
      
insert into [Archive].[TGCPlus_Seriescategories]      
( series_id,	series_categories_id,	ordinal_id,	category_name)      
      
select       
series_id,	series_categories_id,	ordinal_id,	category_name    
from [Staging].VL_ssis_Seriescategories       
      
      
END      
GO
