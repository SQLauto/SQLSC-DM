SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE Proc [Staging].[SP_Load_Snag_SubscriptionOffer_1]
as

Begin



--Create table Datawarehouse.archive.TGCPlus_SubscriptionOffer_1
--(
--id	Bigint  NOT Null,
--version	Bigint  Null,
--absolute_amount_off	Real  Null,
--campaign_type varchar(255)  Null,
--offer_codes	varchar(1000)  Null,
--cookie_valid_days	int  Null,
--description varchar(255)  Null,
--expire	bit  Null,
--percentage_amount_off	Real  Null,
--reoccuring_billing_periods	int  Null,
--scheduled_from_date	datetime  Null,
--scheduled_to_date datetime  Null,
--title varchar(255)  Null,
--update_date	datetime  Null,
--uuid varchar(255)  Null,
--site_id	int  Null,
--code	 varchar(255)  NOT Null,
--offer_strategy_type	varchar(50)  Null,
--period_type	varchar(50)  Null,
--period_multiplier int   Null,
--LastupdatedDate datetime not null default(getdate())
--)


/*********************Load into Clean table*********************/

truncate table Datawarehouse.archive.TGCPlus_SubscriptionOffer_1

insert into Datawarehouse.archive.TGCPlus_SubscriptionOffer_1
 (   id,version,absolute_amount_off,campaign_type,offer_codes,cookie_valid_days,description,expire,percentage_amount_off,reoccuring_billing_periods,scheduled_from_date
,scheduled_to_date,title,update_date,uuid,site_id,code,offer_strategy_type,period_type,period_multiplier 
)

select   id,case when version is null or version = 'Null' then null else Cast(version as Bigint ) end as version
,case when absolute_amount_off is null or absolute_amount_off = 'Null' then null else Cast(absolute_amount_off as Real) end as absolute_amount_off
,campaign_type,offer_codes,case when cookie_valid_days is null or cookie_valid_days = 'Null' then null else Cast(cookie_valid_days as int) end as cookie_valid_days
,description,case when expire is null or expire = 'Null' then null else Cast(expire as Bit) end as expire
,case when percentage_amount_off is null or percentage_amount_off = 'Null' then null else Cast(percentage_amount_off as Real) end as percentage_amount_off
,case when reoccuring_billing_periods is null or reoccuring_billing_periods = 'Null' then null else Cast(reoccuring_billing_periods as int) end as reoccuring_billing_periods
,case when scheduled_from_date is null or scheduled_from_date = 'Null' then null else Cast(scheduled_from_date as datetime) end as scheduled_from_date
, case when scheduled_to_date is null or scheduled_to_date = 'Null' then null else Cast(scheduled_to_date as datetime) end as scheduled_to_date
,title,case when update_date is null or update_date = 'Null' then null else Cast(update_date as datetime) end as update_date,uuid
,case when site_id is null or site_id = 'Null' then null else Cast(site_id as int) end as site_id,code,offer_strategy_type,period_type
,case when period_multiplier is null or period_multiplier = 'Null' then null else Cast(period_multiplier as int) end as period_multiplier 
from  Datawarehouse.staging.Snag_ssis_SubscriptionOffer

 
End 

    


GO
