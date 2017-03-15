SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [dbo].[SP_EPC_Load_ssis_reason]  
as   
Begin  

 Select count(*) TotalCnts from  [staging].[epc_ssis_reason]  
  
/* Later do a merge join*/  
truncate table [staging].[epc_ssis_reason]  
  
insert into [staging].[epc_ssis_reason]  
(reason_id ,name)  
select reason_id,name from magentoimports..[epc_reason]  
  
End  
GO
