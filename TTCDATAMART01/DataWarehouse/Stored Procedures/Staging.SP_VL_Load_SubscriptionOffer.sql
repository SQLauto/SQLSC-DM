SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [Staging].[SP_VL_Load_SubscriptionOffer]  
as  
Begin  
  

/*Update Previous Counts*/
exec SP_TGCPlus_UpdatePreviousCounts @TGCPlusTableName = 'TGCPlus_SubscriptionOffer'

/*Truncate and Load */  
--Truncate table [Archive].[TGCPlus_SubscriptionOffer]  

delete A from  [Archive].[TGCPlus_SubscriptionOffer]  A
join [Staging].VL_ssis_SubscriptionOffer  S
On A.id = S.id

  
insert into [Archive].[TGCPlus_SubscriptionOffer]  
(id,version,absolute_amount_off,campaign_type,offer_codes,cookie_valid_days,description,expire,percentage_amount_off,reoccuring_billing_periods,scheduled_from_date  
,scheduled_to_date,title,update_date,uuid,site_id,code,offer_strategy_type,period_type,period_multiplier,DMLastUpdateESTDateTime)   
select   
id,Cast(version as BigInt) version,Cast(absolute_amount_off as Real) absolute_amount_off,campaign_type,offer_codes,Cast(cookie_valid_days as BigInt) cookie_valid_days  
,description,expire ,Cast(percentage_amount_off as Real) percentage_amount_off,Cast(reoccuring_billing_periods as BigInt) reoccuring_billing_periods  
,Cast(scheduled_from_date as DateTime)scheduled_from_date,Cast(scheduled_to_date as DateTime)scheduled_to_date,title,Cast(update_date as DateTime)update_date  
,uuid,Cast(site_id as BigInt) site_id,code,offer_strategy_type,period_type,Cast(period_multiplier as BigInt) period_multiplier, GETDATE() as DMLastUpdateESTDateTime   
from [Staging].VL_ssis_SubscriptionOffer  

/*Update Counts*/
exec SP_TGCPlus_UpdateCurrentCounts @TGCPlusTableName = 'TGCPlus_SubscriptionOffer'
 
  
END  

GO
