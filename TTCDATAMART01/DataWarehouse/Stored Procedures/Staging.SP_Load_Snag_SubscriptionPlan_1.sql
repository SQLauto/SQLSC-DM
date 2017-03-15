SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE Proc [Staging].[SP_Load_Snag_SubscriptionPlan_1]
as

Begin


--Create table Datawarehouse.archive.TGCPlus_SubscriptionPlan_1
--(
--id	Bigint  Null,
--version	Bigint  Null,
--billing_cycle_period_multiplier	int  Null,
--billing_cycle_period_type varchar(255)  Null,
--description varchar(255)  Null,
--name varchar(255)  Null,
--recurring_payment_amount Real  Null,
--recurring_payment_currency_code varchar(255)  Null,
--scheduled_from_date datetime  Null,
--scheduled_to_date	datetime  Null,
--visible	bit  Null,
--uuid varchar(255)  Null,
--site_id	int Null,
--update_date	datetime  Null,
--seller_note	varchar(255)  Null,
--LastupdatedDate datetime not null default(getdate())
--)


/*********************Load into Clean table*********************/

truncate table Datawarehouse.archive.TGCPlus_SubscriptionPlan_1

insert into Datawarehouse.archive.TGCPlus_SubscriptionPlan_1
 (   id,version,billing_cycle_period_multiplier,billing_cycle_period_type,description,name,recurring_payment_amount,recurring_payment_currency_code,
scheduled_from_date,scheduled_to_date,visible,uuid,site_id,update_date,seller_note
)

select    case when id is null or id = 'Null' then null else Cast(id as Bigint) end as id,case when version is null or version = 'Null' then null else Cast(version as Bigint) end as version
,case when billing_cycle_period_multiplier is null or billing_cycle_period_multiplier = 'Null' then null else Cast(billing_cycle_period_multiplier as int) end as billing_cycle_period_multiplier
,billing_cycle_period_type,description,name,case when recurring_payment_amount is null or recurring_payment_amount = 'Null' then null else Cast(recurring_payment_amount as Real) end as recurring_payment_amount
,recurring_payment_currency_code,case when scheduled_from_date is null or scheduled_from_date = 'Null' then null else Cast(scheduled_from_date as datetime) end as scheduled_from_date
,case when scheduled_to_date is null or scheduled_to_date = 'Null' then null else Cast(scheduled_to_date as datetime) end as scheduled_to_date
,case when visible is null or visible = 'Null' then null else Cast(visible as bit) end as visible,uuid,case when site_id is null or site_id = 'Null' then null else Cast(site_id as int) end as site_id
,case when update_date is null or update_date = 'Null' then null else Cast(update_date as datetime) end as update_date,seller_note
from  Datawarehouse.staging.Snag_ssis_SubscriptionPlan

 

End 

    
    
    


GO
