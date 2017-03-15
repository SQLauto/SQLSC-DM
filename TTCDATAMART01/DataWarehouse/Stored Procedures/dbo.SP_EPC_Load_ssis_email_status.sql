SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[SP_EPC_Load_ssis_email_status]    
as     
Begin    
    
/* Later do a merge join*/    

select COUNT(*) TotalCnts from [staging].[epc_ssis_email_status]
    
Truncate table [staging].[epc_ssis_email_status]    
    
insert into [staging].[epc_ssis_email_status]    
(recipient_failure_id,email,created_date,transaction_date,category,type_number,reason,user_id)    
    
select recipient_failure_id,email,created_date,transaction_date,category,type_number,reason,user_id     
from magentoimports..[epc_email_status]    
    
End    
  
GO
