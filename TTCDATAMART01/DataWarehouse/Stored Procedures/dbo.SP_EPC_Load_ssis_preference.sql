SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [dbo].[SP_EPC_Load_ssis_preference]   
as   
Begin  

Select count(*) TotalCnts from [staging].[epc_ssis_preference] 
  
/* Later do a merge join*/  
truncate table [staging].[epc_ssis_preference]   
  
insert into [staging].[epc_ssis_preference]   
(preference_id,email,created_date,last_updated_date,snooze_end_date,registration_source_id,snooze_start_date,guest_key)  
select preference_id,email,created_date,last_updated_date,snooze_end_date,registration_source_id,snooze_start_date,guest_key   
from magentoimports.[dbo].[epc_preference]  
  
End  
GO
