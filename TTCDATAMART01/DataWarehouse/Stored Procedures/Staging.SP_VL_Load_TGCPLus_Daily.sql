SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









CREATE Proc [Staging].[SP_VL_Load_TGCPLus_Daily]
as

Begin

--return(0)


exec  staging.SP_VL_Load_Film
Print 'Executed staging.SP_VL_Load_Film'

exec  staging.SP_VL_Load_PaymentAuthorizationStatus
Print 'Executed staging.SP_VL_Load_PaymentAuthorizationStatus'

exec  staging.SP_VL_Load_PaymentAuthorizationUsedOffer
Print 'Executed staging.SP_VL_Load_PaymentAuthorizationUsedOffer'

exec  staging.SP_VL_Load_SubscriptionOffer
Print 'Executed staging.SP_VL_Load_SubscriptionOffer'

exec  staging.SP_VL_Load_SubscriptionPlan
Print 'Executed staging.SP_VL_Load_SubscriptionPlan'

exec  staging.SP_VL_Load_User
Print 'Executed staging.SP_VL_Load_User'


exec  staging.SP_VL_Load_UserBilling
Print 'Executed staging.SP_VL_Load_UserBilling'

exec  staging.SP_VL_Load_VideoEvents
Print 'Executed staging.SP_VL_Load_VideoEvents'

Exec Staging.SP_VL_Load_Seriescategories
Print 'Executed staging.SP_VL_Load_Seriescategories'

/*Refresh TGCPlus_Transaction  & TGCPlus_CustomerStatus table*/

Exec [Staging].[SP_Load_TGCPlus_Transaction]  
Print 'Executed staging.SP_Load_TGCPlus_Transaction'

/*Refresh Datawarehouse.archive.tgcplus_ds table*/
Exec [dbo].[SP_TGCPLus_Load_DS]
Print 'Executed [dbo].[SP_TGCPLus_Load_DS]'

/*Refresh TGCPlus Daily orders table and TGCPluscustomerSignature table*/

Exec Staging.SP_Load_TGCplus_StatusHistory
Print 'Executed staging.SP_Load_TGCplus_StatusHistory'

Exec SP_Load_TGC_TGCplus --@StartDate = '5/1/2015' ,@EndDate ='4/19/2016'
Print 'Executed SP_Load_TGC_TGCplus'

Exec Staging.SP_Load_TGCPlus_CustomerSignature
Print 'Executed staging.SP_Load_TGCPlus_CustomerSignature'

exec  Staging.TGCPlus_CustomerChangeTracker_Update -- added on 12/20/2017
Print 'Executed TGCPlus_CustomerChangeTracker_Update'
exec Staging.SP_TGCPLUS_SP_Run_End  'SP_Calc_TGCplus_Consumption_Smry'

/*Refresh other consumption reports*/

Exec [Staging].[SP_VL_Load_TGCplus_User]
Print 'Executed [Staging].[SP_VL_Load_TGCplus_User]'
exec Staging.SP_TGCPLUS_SP_Run_End  'SP_Calc_TGCplus_Consumption_Smry'



exec Staging.SP_TGCPLUS_SP_Run_start  'Staging.SP_VL_Load_TGCplus_AcqsnDashboard'
Exec [Staging].[SP_VL_Load_TGCplus_AcqsnDashboard] 
Print 'Executed [Staging].[SP_VL_Load_TGCplus_AcqsnDashboard]'
exec Staging.SP_TGCPLUS_SP_Run_End   'Staging.SP_VL_Load_TGCplus_AcqsnDashboard'


exec Staging.SP_TGCPLUS_SP_Run_start  'SP_Calc_TGCplus_Consumption_Smry'
exec dbo.SP_Calc_TGCplus_Consumption_Smry
Print 'Executed SP_Calc_TGCplus_Consumption_Smry'
exec Staging.SP_TGCPLUS_SP_Run_End  'SP_Calc_TGCplus_Consumption_Smry'


-- ADDED 4/4/2018 for course release dates  - Imane


exec [dbo].[SP_TGC_CourseReleasesUpdates] @BU ='TGCPlus' 
Print 'Executed [dbo].[SP_TGC_CourseReleasesUpdates] @BU =''TGCPlus'' '




exec [dbo].[SP_TGC_CourseReleasesUpdates] @BU ='TGC'
Print 'Executed [dbo].[SP_TGC_CourseReleasesUpdates] @BU =''TGC'''


--Added audible and AIV COURSES RELEASES 4/9/2018 - Imane


exec [dbo].[SP_TGC_CourseReleasesUpdates] @BU='Audible'
Print 'Executed [dbo].[SP_TGC_CourseReleasesUpdates] @BU =''Audible'''

exec [dbo].[SP_TGC_CourseReleasesUpdates] @BU='AIV'

Print 'Executed [dbo].[SP_TGC_CourseReleasesUpdates] @BU =''AIV'''


/*exec Staging.SP_TGCPLUS_SP_Run_start  'sp_tgcplus_course_releases'
exec dbo.sp_tgcplus_course_releases
Print 'Executed sp_tgcplus_course_releases'
exec Staging.SP_TGCPLUS_SP_Run_End  'sp_tgcplus_course_releases'*/



exec Staging.SP_TGCPLUS_SP_Run_start  'Staging.SP_VL_Load_TGCplus_ConsumptionAll'
Exec  [Staging].[SP_VL_Load_TGCplus_ConsumptionAll]
Print 'Executed [Staging].[SP_VL_Load_TGCplus_ConsumptionAll]'
exec Staging.SP_TGCPLUS_SP_Run_End   'Staging.SP_VL_Load_TGCplus_ConsumptionAll'


exec Staging.SP_TGCPLUS_SP_Run_start  'Staging.SP_VL_Load_TGCplus_ConsumptionByPlatform'
Exec [Staging].[SP_VL_Load_TGCplus_ConsumptionByPlatform]
Print 'Executed [Staging].[SP_VL_Load_TGCplus_ConsumptionByPlatform]'
exec Staging.SP_TGCPLUS_SP_Run_End   'Staging.SP_VL_Load_TGCplus_ConsumptionByPlatform'


-- adding these modified procs to run in parallel starting on 3/19/2018 - Imane Badra

-- alter procedure names to reflect new names for backup procedure  4/2/2018 - imane 
-- Commented them as these are replaced by new procs listed above... 4/30/2018 - PR

--exec Staging.SP_TGCPLUS_SP_Run_start  'staging.SP_VL_Load_TGCplus_ConsumptionAll_bkp_del'
--exec [Staging].[SP_VL_Load_TGCplus_ConsumptionAll_bkp_del]

--Print 'Executed staging.SP_VL_Load_TGCplus_ConsumptionAll_bkp_del'
--exec Staging.SP_TGCPLUS_SP_Run_End   'staging.SP_VL_Load_TGCplus_ConsumptionAll_bkp_del'


--exec Staging.SP_TGCPLUS_SP_Run_start  'staging.SP_VL_Load_TGCplus_ConsumptionByPlatform_bkp_del'
--exec [Staging].[SP_VL_Load_TGCplus_ConsumptionByPlatform_bkp_del]


--Print 'Executed staging.SP_VL_Load_TGCplus_ConsumptionByPlatform_bkp_del'
--exec Staging.SP_TGCPLUS_SP_Run_End   'staging.SP_VL_Load_TGCplus_ConsumptionByPlatform_bkp_del'


exec Staging.SP_TGCPLUS_SP_Run_start  'Staging.SP_TGCPlus_ConsumptionFreeMonthChurn'
Exec [Staging].[SP_TGCPlus_ConsumptionFreeMonthChurn]
Print 'Executed Staging.SP_TGCPlus_ConsumptionFreeMonthChurn'
exec Staging.SP_TGCPLUS_SP_Run_End  'Staging.SP_TGCPlus_ConsumptionFreeMonthChurn'


exec Staging.SP_TGCPLUS_SP_Run_start  'Staging.SP_Load_TGCPlus_LTDLectureConsmption'
exec [Staging].[SP_Load_TGCPlus_LTDLectureConsmption]
Print 'Executed [Staging].[SP_Load_TGCPlus_LTDLectureConsmption]'
exec Staging.SP_TGCPLUS_SP_Run_End  'Staging.SP_Load_TGCPlus_LTDLectureConsmption'


exec Staging.SP_TGCPLUS_SP_Run_start  'SP_Calc_TGCplus_VideoEvents_Smry_TestAccts'
Exec [dbo].[SP_Calc_TGCplus_VideoEvents_Smry_TestAccts]
Print 'Executed dbo.SP_Calc_TGCplus_VideoEvents_Smry_TestAccts'
exec Staging.SP_TGCPLUS_SP_Run_End  'SP_Calc_TGCplus_VideoEvents_Smry_TestAccts'

/*


exec Staging.SP_TGCPLUS_SP_Run_start  'SP_Calc_TGCplus_VideoEvents_Smry'  -- Turning off Old Summary job 4/4/2018 - Imane
Exec [SP_Calc_TGCplus_VideoEvents_Smry]
Print 'Executed [SP_Calc_TGCplus_VideoEvents_Smry]'
exec Staging.SP_TGCPLUS_SP_Run_End   'SP_Calc_TGCplus_VideoEvents_Smry' */

exec [dbo].[PLUS_PaidFlag_QC]
Print 'Executed dbo.PLUS_PaidFlag_QC'

if @@ERROR = 0 

Begin
select 1
EXECUTE msdb.dbo.sp_start_job 'TGCPLusToAWS'
end


END














GO
