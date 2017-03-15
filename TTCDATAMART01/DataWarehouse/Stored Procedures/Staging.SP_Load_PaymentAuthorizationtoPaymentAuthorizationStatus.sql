SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Proc [Staging].[SP_Load_PaymentAuthorizationtoPaymentAuthorizationStatus]
as

Begin

--Table column issues
--Create table Datawarehouse.archive.Snag_PaymentAuthorizationtoPaymentAuthorizationStatus
--(
--payment_authorization_usedoffers_id bigint Null,
--used_subscription_offer_id	 bigint	Null,
--LastupdatedDate datetime not null default(getdate())
--)


--Create table Datawarehouse.archive.Snag_PaymentAuthorizationtoPaymentAuthorizationStatus
--(
--payment_authorization_status_history_id bigint Null,
--payment_authorization_status_id	 bigint	Null,
--LastupdatedDate datetime not null default(getdate())
--)



/*********************Load into Clean table*********************/

insert into Datawarehouse.archive.Snag_PaymentAuthorizationtoPaymentAuthorizationStatus
(payment_authorization_status_history_id , payment_authorization_status_id)

 select  
  case when payment_authorization_status_history_id is null then null else Cast(payment_authorization_status_history_id as Bigint) end as payment_authorization_status_history_id,
  case when payment_authorization_status_id is null then null else Cast(payment_authorization_status_id as Bigint) end as payment_authorization_status_id
from  Datawarehouse.staging.Snag_ssis_PaymentAuthorizationtoPaymentAuthorizationStatus
 

End 
GO
