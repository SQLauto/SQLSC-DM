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

Exec Staging.SP_Load_TGCPlus_CustomerSignature
Print 'Executed staging.SP_Load_TGCPlus_CustomerSignature'

Exec SP_Load_TGC_TGCplus --@StartDate = '5/1/2015' ,@EndDate ='4/19/2016'
Print 'Executed SP_Load_TGC_TGCplus'

exec  Staging.TGCPlus_CustomerChangeTracker_Update -- added on 12/20/2017
Print 'Executed TGCPlus_CustomerChangeTracker_Update'


/*Refresh other consumption reports*/

Exec [Staging].[SP_VL_Load_TGCplus_User]
Print 'Executed [Staging].[SP_VL_Load_TGCplus_User]'

Exec [Staging].[SP_VL_Load_TGCplus_AcqsnDashboard] 
Print 'Executed [Staging].[SP_VL_Load_TGCplus_AcqsnDashboard]'

Exec [SP_Calc_TGCplus_VideoEvents_Smry]
Print 'Executed [SP_Calc_TGCplus_VideoEvents_Smry]'

Exec  [Staging].[SP_VL_Load_TGCplus_ConsumptionAll]
Print 'Executed [Staging].[SP_VL_Load_TGCplus_ConsumptionAll]'


Exec [Staging].[SP_VL_Load_TGCplus_ConsumptionByPlatform]
Print 'Executed [Staging].[SP_VL_Load_TGCplus_ConsumptionByPlatform]'


Exec [Staging].[SP_TGCPlus_ConsumptionFreeMonthChurn]
Print 'Executed Staging.SP_TGCPlus_ConsumptionFreeMonthChurn'

exec [Staging].[SP_Load_TGCPlus_LTDLectureConsmption]
Print 'Executed [Staging].[SP_Load_TGCPlus_LTDLectureConsmption]'

Exec [dbo].[SP_Calc_TGCplus_VideoEvents_Smry_TestAccts]
Print 'Executed dbo.SP_Calc_TGCplus_VideoEvents_Smry_TestAccts'



if @@ERROR = 0 

Begin
select 1
EXECUTE msdb.dbo.sp_start_job 'TGCPLusToAWS'
end


END






GO
