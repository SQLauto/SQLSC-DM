SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE Proc [Staging].[SP_Load_Snag_PaymentAuthorizationtoPaymentAuthorizationStatus_1]
as

Begin

--Table column issues
--Create table Datawarehouse.archive.TGCPlus_PaymentAuthorizationtoPaymentAuthorizationStatus_1
--(
--payment_authorization_usedoffers_id bigint Null,
--used_subscription_offer_id	 bigint	Null,
--LastupdatedDate datetime not null default(getdate())
--)


--Create table Datawarehouse.archive.TGCPlus_PaymentAuthorizationtoPaymentAuthorizationStatus_1
--(
--payment_authorization_status_history_id bigint Null,
--payment_authorization_status_id	 bigint	Null,
--LastupdatedDate datetime not null default(getdate())
--)



/*********************Load into Clean table*********************/

truncate table Datawarehouse.archive.TGCPlus_PaymentAuthorizationtoPaymentAuthorizationStatus_1

insert into Datawarehouse.archive.TGCPlus_PaymentAuthorizationtoPaymentAuthorizationStatus_1
(payment_authorization_status_history_id , payment_authorization_status_id)

 select  
  case when payment_authorization_status_history_id is null then null else Cast(payment_authorization_status_history_id as Bigint) end as payment_authorization_status_history_id,
  case when payment_authorization_status_id is null then null else Cast(payment_authorization_status_id as Bigint) end as payment_authorization_status_id
from  Datawarehouse.staging.Snag_ssis_PaymentAuthorizationtoPaymentAuthorizationStatus
 
 
 

/*

delete B
from  Datawarehouse.staging.Snag_ssis_PaymentAuthorizationtoPaymentAuthorizationStatus A
inner join (select payment_authorization_status_history_id as status_history_id ,payment_authorization_status_id as status_id
from  Datawarehouse.archive.TGCPlus_PaymentAuthorizationtoPaymentAuthorizationStatus_1) B
on a.payment_authorization_status_history_id=b.status_history_id
and a.payment_authorization_status_id =b.status_id

insert into Datawarehouse.archive.TGCPlus_PaymentAuthorizationtoPaymentAuthorizationStatus_1
(payment_authorization_status_history_id , payment_authorization_status_id)

 select  
  case when payment_authorization_status_history_id is null then null else Cast(payment_authorization_status_history_id as Bigint) end as payment_authorization_status_history_id,
  case when payment_authorization_status_id is null then null else Cast(payment_authorization_status_id as Bigint) end as payment_authorization_status_id
from  Datawarehouse.staging.Snag_ssis_PaymentAuthorizationtoPaymentAuthorizationStatus A
left join (select payment_authorization_status_history_id as status_history_id ,payment_authorization_status_id as status_id
from  Datawarehouse.archive.TGCPlus_PaymentAuthorizationtoPaymentAuthorizationStatus_1) B
on a.payment_authorization_status_history_id=b.status_history_id
and a.payment_authorization_status_id =b.status_id
where B.status_history_id is null or B.status_id is null


*/ 

End 



GO
