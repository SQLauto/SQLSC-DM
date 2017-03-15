SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [Staging].[SP_VL_Load_SubscriptionPlan_del]   
as  
Begin  
  
   
/*Truncate and Load */  
--Truncate table [Archive].[TGCPlus_SubscriptionPlan_del] 

Delete A from [Archive].[TGCPlus_SubscriptionPlan_del] A
join [Staging].VL_ssis_SubscriptionPlan S
on A.id =S.id
  
  
insert into [Archive].[TGCPlus_SubscriptionPlan_del]   
(id,version, billing_cycle_period_multiplier,billing_cycle_period_type,description,name,recurring_payment_amount,recurring_payment_currency_code  
,scheduled_from_date,scheduled_to_date,visible,uuid,site_id,update_date,seller_note,DMLastUpdateESTDateTime)  
  
select   
id,Cast(version as BigInt) version,Cast(billing_cycle_period_multiplier as Int)billing_cycle_period_multiplier,billing_cycle_period_type  
,description,name,recurring_payment_amount,recurring_payment_currency_code,Cast(scheduled_from_date as DateTime) scheduled_from_date  
,Cast(scheduled_to_date as DateTime) scheduled_to_date,Cast(visible as Bit) visible,uuid,Cast(site_id as BigInt) site_id  
,Cast(update_date as DateTime) update_date,seller_note, GETDATE() as DMLastUpdateESTDateTime   
from [Staging].VL_ssis_SubscriptionPlan   
  
END
GO
