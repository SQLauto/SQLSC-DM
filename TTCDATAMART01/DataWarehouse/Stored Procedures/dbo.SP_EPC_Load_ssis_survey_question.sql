SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [dbo].[SP_EPC_Load_ssis_survey_question]  
as   
Begin  

Select count(*) TotalCnts from [staging].epc_ssis_survey_question  
  
/* Later do a merge join*/  
truncate table [staging].epc_ssis_survey_question  
  
insert into [staging].epc_ssis_survey_question  
(survey_question_id,survey_id,reason_id)  
select survey_question_id,survey_id,reason_id from  MagentoImports..epc_survey_question  
  
End  
GO
