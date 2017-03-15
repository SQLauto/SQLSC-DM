SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [dbo].[SP_EPC_Load_ssis_registration_source]   
as   
Begin  

Select count(*) TotalCnts from  [staging].[epc_ssis_registration_source]  
  
/* Later do a merge join*/  
truncate table [staging].[epc_ssis_registration_source]  
  
Insert into [staging].[epc_ssis_registration_source]  
(registration_source_id ,name)  
select registration_source_id ,name from magentoimports..[epc_registration_source]  
  
End      
GO
