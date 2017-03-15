SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  
  
CREATE Proc [Staging].[SP_VL_Load_PaymentAuthorizationUsedOffer]   
as  
Begin  
  



/*Update Previous Counts*/
exec SP_TGCPlus_UpdatePreviousCounts @TGCPlusTableName = 'TGCPlus_PaymentAuthorizationUsedOffer'
   
/*Truncate and Load */  
--Truncate table [Archive].[TGCPlus_PaymentAuthorizationUsedOffer]  

/*  
insert into [Archive].[TGCPlus_PaymentAuthorizationUsedOffer]  
  (pa_id,pa_user_id,uso_id,uso_version,uso_applied_at,uso_offer_id,uso_offer_code_applied,uso_redeemed_at,uso_uuid,uso_update_date,DMLastUpdateESTDateTime)  
   
select Cast(pa_id as BigInt) pa_id,Cast(pa_user_id as BigInt) pa_user_id,uso_id,Cast(uso_version as BigInt) uso_version,Cast(uso_applied_at as DateTime) uso_applied_at  
,Cast(uso_offer_id as BigInt) uso_offer_id,uso_offer_code_applied,Cast(uso_redeemed_at as DateTime) uso_redeemed_at,uso_uuid,Cast(uso_update_date as DateTime)uso_update_date  
, GETDATE() as DMLastUpdateESTDateTime   
from [Staging].VL_ssis_PaymentAuthorizationUsedOffer  
*/  
  
/*Deletes*/  
/*  
Delete from [Archive].[TGCPlus_PaymentAuthorizationUsedOffer]  
where uso_applied_at >= (select Min(Cast(uso_applied_at as DateTime)) as uso_applied_at from [Staging].VL_ssis_PaymentAuthorizationUsedOffer )  
*/
  
  
Delete A from [Archive].[TGCPlus_PaymentAuthorizationUsedOffer] A
join [Staging].VL_ssis_PaymentAuthorizationUsedOffer S
on A.uso_id = S.uso_id
  

/*Inserts*/  
  
insert into [Archive].[TGCPlus_PaymentAuthorizationUsedOffer]  
  (pa_id,pa_user_id,uso_id,uso_version,uso_applied_at,uso_offer_id,uso_offer_code_applied,uso_redeemed_at,uso_uuid,uso_update_date,DMLastUpdateESTDateTime)  
   
select distinct Cast(pa_id as BigInt) pa_id,Cast(pa_user_id as BigInt) pa_user_id,uso_id,Cast(uso_version as BigInt) uso_version,Cast(uso_applied_at as DateTime) uso_applied_at  
,Cast(uso_offer_id as BigInt) uso_offer_id,uso_offer_code_applied,Cast(uso_redeemed_at as DateTime) uso_redeemed_at,uso_uuid,Cast(uso_update_date as DateTime)uso_update_date  
, GETDATE() as DMLastUpdateESTDateTime   
from [Staging].VL_ssis_PaymentAuthorizationUsedOffer  

  


/*Update Counts*/
exec SP_TGCPlus_UpdateCurrentCounts @TGCPlusTableName = 'TGCPlus_PaymentAuthorizationUsedOffer'
 
END  
GO
