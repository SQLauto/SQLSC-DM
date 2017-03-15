SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[SP_EPC_Load_ssis_preference_history]       
as       
Begin      
    
 Select count(*) TotalCnts from [staging].[epc_ssis_preference_history]      
      
/* Later do a merge join*/      
--truncate table [staging].[epc_ssis_preference_history]   
      
insert into [staging].[epc_ssis_preference_history]      
(preference_history_id,preference_id,change_date,change_type,change_source,value_old,value_new)      
select preference_history_id,preference_id,change_date,change_type,change_source,value_old,value_new       
from magentoimports..[epc_preference_history]      
where preference_history_id > (select isnull(MAX(preference_history_id),0) as preference_history_id from [staging].[epc_ssis_preference_history])      
      
 Select count(*) TotalCnts from [staging].[epc_ssis_preference_history]      
       
       
End 
GO
