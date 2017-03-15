SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


    
CREATE Proc [dbo].[SP_EPC_Load_ssis_option]   
as   
Begin  
  
  
Select count(*) TotalCnts from [staging].[epc_ssis_option]  
  
/* Later do a merge join*/  
truncate table [staging].[epc_ssis_option]  
  
insert into [staging].[epc_ssis_option]  
(option_id ,name ,description)  
select option_id ,name ,description from magentoimports..[epc_option]  
  
  
End
GO
