SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [dbo].[SP_EPC_Load_ssis_frequency]   
as   
Begin  
  
 Select count(*) TotalCnts from  [staging].[epc_ssis_frequency]  
  
/* Later do a merge join*/  
Truncate table [staging].[epc_ssis_frequency]  
  
insert into [staging].[epc_ssis_frequency] (frequency_id ,name)  
select frequency_id ,name from magentoimports..[epc_frequency]  
  
End  
GO
