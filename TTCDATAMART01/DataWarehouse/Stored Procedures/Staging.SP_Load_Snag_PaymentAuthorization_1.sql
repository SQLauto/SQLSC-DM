SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE Proc [Staging].[SP_Load_Snag_PaymentAuthorization_1]
as

Begin


--Create table Datawarehouse.archive.TGCPlus_PaymentAuthorization
--(
--id	Bigint  NOT Null,
--version	Bigint  NOT Null,
--status	varchar(255) Null,
--user_id	Bigint  Null,
--uuid varchar(255)Null,
--next_billing_date datetime Null,
--update_date	datetime Null,
--LastupdatedDate datetime not null default(getdate())
--)



/*********************Load into Clean table*********************/

truncate table Datawarehouse.archive.TGCPlus_PaymentAuthorization_1

insert into Datawarehouse.archive.TGCPlus_PaymentAuthorization_1
( id,version,status, user_id,uuid,next_billing_date,update_date)

 select   A.id,version,status,case when user_id is null then null else Cast(user_id as bigint) end as user_id,uuid
 ,case when next_billing_date is null then null else Cast(next_billing_date as datetime) end as next_billing_date
 ,case when update_date is null then null else Cast(update_date as datetime) end as update_date
from  Datawarehouse.staging.Snag_ssis_PaymentAuthorization A


/*

delete   b   from  Datawarehouse.staging.Snag_ssis_PaymentAuthorization A
 inner JOIN (SELECT ID FROM Datawarehouse.archive.TGCPlus_PaymentAuthorization ) B
ON A.id=B.id

insert into Datawarehouse.archive.TGCPlus_PaymentAuthorization
( id,version,status, user_id,uuid,next_billing_date,update_date)

 select   A.id,version,status,case when user_id is null then null else Cast(user_id as bigint) end as user_id,uuid
 ,case when next_billing_date is null then null else Cast(next_billing_date as datetime) end as next_billing_date
 ,case when update_date is null then null else Cast(update_date as datetime) end as update_date
from  Datawarehouse.staging.Snag_ssis_PaymentAuthorization A
 LEFT JOIN (SELECT ID FROM Datawarehouse.archive.TGCPlus_PaymentAuthorization ) B
ON A.id=B.id
WHERE b.id IS NULL

*/

End 






GO
