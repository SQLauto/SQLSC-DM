SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [dbo].[SP_EPC_Load_ssis_preference_option]   
as   
Begin  

Select count(*) TotalCnts from [staging].[epc_ssis_preference_option]  
  
/* Later do a merge join*/  
truncate table [staging].[epc_ssis_preference_option]  
  
insert into [staging].[epc_ssis_preference_option]  
(preference_option_id ,preference_id ,option_id ,frequency_id)  
select preference_option_id ,preference_id ,option_id ,frequency_id from magentoimports..[epc_preference_option]  
  
End     
GO
