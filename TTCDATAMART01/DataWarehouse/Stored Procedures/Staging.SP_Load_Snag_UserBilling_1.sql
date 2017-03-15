SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE Proc [Staging].[SP_Load_Snag_UserBilling_1]
as

Begin


/***************** Data cleanup and Load to Final Table. ***************** */

--Create Table Datawarehouse.archive.TGCPlus_UserBilling_1
--(
--id	Bigint  NOT Null,
--version	Bigint Null,
--billing_cycle_period_multiplier	int Null,
--billing_cycle_period_type	varchar(255) Null,
--charged_amount_currency_code varchar(255) Null,
--completed_at  datetime Null,
--description	 varchar(255) Null,
--pre_tax_amount	Real  Null,
--subscription_plan_id Bigint Null,
--tax_amount	Real  Null,
--user_id	 Bigint Null,
--type varchar(255)  NOT Null,
--update_date	 datetime Null,
--site_id	 int Null,
--uuid varchar(255) Null,
--service_period_from	datetime Null,
--service_period_to datetime Null,
--payment_handler_fee	Real  Null,
--LastupdatedDate datetime not null default(getdate())
--)



/*********************Load into Clean table*********************/

truncate table Datawarehouse.archive.TGCPlus_UserBilling_1


insert into Datawarehouse.archive.TGCPlus_UserBilling_1
( id,version,billing_cycle_period_multiplier,billing_cycle_period_type,charged_amount_currency_code,completed_at,description,pre_tax_amount,subscription_plan_id
,tax_amount,user_id,type,update_date,site_id,uuid,service_period_from,service_period_to,payment_handler_fee)

 select  id,case when version is null or version = 'NULL' then null else cast( version as bigint) End as version
,case when billing_cycle_period_multiplier ='null' then null else cast( billing_cycle_period_multiplier as int) End as billing_cycle_period_multiplier
,billing_cycle_period_type,charged_amount_currency_code,case when completed_at is null then null else cast( completed_at as datetime) End as completed_at
,description,case when pre_tax_amount is null then null else cast( pre_tax_amount as Real) End as pre_tax_amount
,case when subscription_plan_id is null then null else cast( subscription_plan_id as Bigint) End as subscription_plan_id
,case when tax_amount is null then null else cast( tax_amount as Real) End as tax_amount,case when user_id is null then null else cast( user_id as Bigint) End as user_id
,type,case when update_date is null then null else cast( update_date as datetime) End as update_date,case when site_id is null then null else cast( site_id as int) End as site_id
,uuid,case when service_period_from is null then null else cast( service_period_from as Datetime) End as service_period_from
,case when service_period_to is null then null else cast( service_period_to as Datetime) End as service_period_to
,case when payment_handler_fee is null then null else cast( payment_handler_fee as Real) End as payment_handler_fee
from  Datawarehouse.staging.Snag_ssis_UserBilling
 

End 




GO
