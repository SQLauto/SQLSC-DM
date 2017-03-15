SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

    
CREATE Proc [Staging].[SP_VL_Load_UserBilling_20160325]    
as    
Begin    
    
    
/*Truncate and Load */    
Truncate table [Archive].[TGCPlus_UserBilling]     
  
/*     
insert into [Archive].[TGCPlus_UserBilling]    
( id,version,billing_cycle_period_multiplier,billing_cycle_period_type,charged_amount_currency_code,completed_at,description,pre_tax_amount    
,subscription_plan_id,tax_amount,user_id,type,update_date,site_id,uuid,tx_uuid,service_period_from,service_period_to,payment_handler_fee,DMLastUpdateESTDateTime)    
    
select     
    
id,Cast(version as BigInt) version,Cast(billing_cycle_period_multiplier as Int) billing_cycle_period_multiplier,billing_cycle_period_type    
,charged_amount_currency_code,Cast(completed_at as DateTime) completed_at,description,Cast(pre_tax_amount as Real) pre_tax_amount    
,Cast(subscription_plan_id as BigInt) subscription_plan_id,Cast(tax_amount as Real) tax_amount,Cast(user_id as BigInt) user_id    
,type,Cast(update_date as DateTime) update_date,Cast(site_id as BigInt) site_id,uuid,tx_uuid,Cast(service_period_from as DateTime) service_period_from    
,Cast(service_period_to as DateTime) service_period_to,Cast(payment_handler_fee as Real) payment_handler_fee,GETDATE() as DMLastUpdateESTDateTime     
from [Staging].VL_ssis_UserBilling     
    
*/    
    
/*Deletes*/    
    
--Delete A from [Archive].[TGCPlus_UserBilling]  A  
--Join [Staging].VL_ssis_UserBilling   S  
--On A.id = S.ID  
    
/*Inserts*/    
    
insert into [Archive].[TGCPlus_UserBilling]    
( id,version,billing_cycle_period_multiplier,billing_cycle_period_type,charged_amount_currency_code,completed_at,description,pre_tax_amount    
,subscription_plan_id,tax_amount,user_id,type,update_date,site_id,uuid,tx_uuid,service_period_from,service_period_to,payment_handler_fee,payment_handler,DMLastUpdateESTDateTime)    
    
select     
id,Cast(version as BigInt) version,Cast(billing_cycle_period_multiplier as Int) billing_cycle_period_multiplier,billing_cycle_period_type    
,charged_amount_currency_code,Cast(completed_at as DateTime) completed_at,description,Cast(pre_tax_amount as Real) pre_tax_amount    
,Cast(subscription_plan_id as BigInt) subscription_plan_id,Cast(tax_amount as Real) tax_amount,Cast(user_id as BigInt) user_id    
,type,Cast(update_date as DateTime) update_date,Cast(site_id as BigInt) site_id,uuid,tx_uuid,Cast(service_period_from as DateTime) service_period_from    
,Cast(service_period_to as DateTime) service_period_to,Cast(payment_handler_fee as Real) payment_handler_fee,payment_handler,GETDATE() as DMLastUpdateESTDateTime     
from [Staging].VL_ssis_UserBilling     
    
    
END    
  
GO
