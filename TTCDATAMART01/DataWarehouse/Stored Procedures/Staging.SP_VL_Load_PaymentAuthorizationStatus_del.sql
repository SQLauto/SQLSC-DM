SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
    
    
CREATE Proc [Staging].[SP_VL_Load_PaymentAuthorizationStatus_del]    
as    
Begin    
    
    
/*Truncate and Load */    
--Truncate table [Archive].[TGCPlus_PaymentAuthorizationStatus_del]    
  
/*     
insert into [Archive].[TGCPlus_PaymentAuthorizationStatus]     
 (pa_id,pa_user_id,pas_id,pas_version,pas_created_at,pas_plan_id,pas_state,pas_updated_at,pas_uuid,pas_payment_handler,pas_subscribed_via_platform,DMLastUpdateESTDateTime)    
     
     
select     
Cast(pa_id as BigInt) pa_id,Cast(pa_user_id as BigInt) pa_user_id,pas_id,Cast(pas_version as BigInt) pas_version,Cast(pas_created_at as DateTime) pas_created_at    
,pas_plan_id,pas_state,Cast(pas_updated_at as DateTime) pas_updated_at,pas_uuid,pas_payment_handler,pas_subscribed_via_platform,  GETDATE() as DMLastUpdateESTDateTime     
from [Staging].VL_ssis_PaymentAuthorizationStatus    
*/    
    
/*Deletes*/    
/*    
Delete from [Archive].[TGCPlus_PaymentAuthorizationStatus]     
where pas_created_at >= (select Min(Cast(pas_created_at as DateTime)) as pas_created_at from [Staging].VL_ssis_PaymentAuthorizationStatus)    
*/  
  
    
Delete A from [Archive].[TGCPlus_PaymentAuthorizationStatus_del] A  
inner join [Staging].VL_ssis_PaymentAuthorizationStatus  S  
on a.pas_id = s.pas_id  
  
  
/*Inserts*/    
    
insert into [Archive].[TGCPlus_PaymentAuthorizationStatus_del]     
 (pa_id,pa_user_id,pas_id,pas_version,pas_created_at,pas_plan_id,pas_state,pas_updated_at,pas_uuid,pas_payment_handler,pas_subscribed_via_platform,DMLastUpdateESTDateTime)    
    
select     
Cast(pa_id as BigInt) pa_id,Cast(pa_user_id as BigInt) pa_user_id,pas_id,Cast(pas_version as BigInt) pas_version,Cast(pas_created_at as DateTime) pas_created_at    
,pas_plan_id,pas_state,Cast(pas_updated_at as DateTime) pas_updated_at,pas_uuid,pas_payment_handler,pas_subscribed_via_platform,  GETDATE() as DMLastUpdateESTDateTime     
from [Staging].VL_ssis_PaymentAuthorizationStatus    
    
    
END 
GO
