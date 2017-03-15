SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE Proc [Staging].[SP_Load_Snag_PaymentAuthorizationSubOffer_1]
as

Begin

--Table column issues
--Create table Datawarehouse.archive.TGCPlus_PaymentAuthorizationtoUsedSubOffer_1
--(
--payment_authorization_usedoffers_id	bigint	null,
--used_subscription_offer_id	 bigint	null,
--LastupdatedDate datetime not null default(getdate())
--)




/*********************Load into Clean table*********************/
truncate table Datawarehouse.archive.TGCPlus_PaymentAuthorizationSubOffer_1


insert into Datawarehouse.archive.TGCPlus_PaymentAuthorizationSubOffer_1
 (payment_authorization_usedoffers_id,used_subscription_offer_id)

select case when payment_authorization_usedoffers_id is null then null else Cast(payment_authorization_usedoffers_id as Bigint) end as payment_authorization_usedoffers_id
	  ,case when used_subscription_offer_id is null then null else Cast(used_subscription_offer_id as Bigint) end as used_subscription_offer_id
from  Datawarehouse.staging.Snag_ssis_PaymentAuthorizationSubOffer A


End 





GO
