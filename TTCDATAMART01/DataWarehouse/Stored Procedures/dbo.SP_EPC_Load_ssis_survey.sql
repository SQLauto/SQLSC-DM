SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [dbo].[SP_EPC_Load_ssis_survey] 
as 
Begin

/* Later do a merge join*/
truncate table [staging].epc_ssis_survey

Insert into [staging].epc_ssis_survey
(survey_id,preference_id,created_date,feedback)
select survey_id,preference_id,created_date,feedback from magentoimports..epc_survey
End

GO
