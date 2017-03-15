SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE Proc [Staging].[SP_Load_Snag_UsedSubOffer_1]
as

Begin


--Create table Datawarehouse.archive.TGCPlus_UsedSubOffer_1
--(
--id	 bigint NOT Null,
--version	 bigint	NOT Null,
--applied_at	 datetime  Null,
--offer_id bigint   Null,
--offer_code_applied	 varchar(255)  Null,
--redeemed_at	 datetime  Null,
--uuid varchar(255)  Null,
--update_date	 datetime  Null,
--LastupdatedDate datetime not null default(getdate())
--)


/*********************Load into Clean table*********************/
truncate table Datawarehouse.archive.TGCPlus_UsedSubOffer_1


insert into Datawarehouse.archive.TGCPlus_UsedSubOffer_1
 (id,version,applied_at,offer_id,offer_code_applied,redeemed_at,uuid,update_date)


select id,version,    case when applied_at is null then null else Cast(applied_at as Datetime) end as applied_at
,case when offer_id is null then null else Cast(offer_id as Bigint ) end as offer_id
,offer_code_applied,case when redeemed_at is null  or redeemed_at = 'null' then null else Cast(redeemed_at as Datetime) end as redeemed_at
,uuid,case when update_date is null then null else Cast(update_date as Datetime) end as update_date
from  Datawarehouse.staging.Snag_ssis_UsedSubOffer

 
/*

delete S from Datawarehouse.archive.TGCPlus_UsedSubOffer_1 S
inner join  Datawarehouse.staging.Snag_ssis_UsedSubOffer SS
on s.id=ss.id

insert into Datawarehouse.archive.TGCPlus_UsedSubOffer_1
 (id,version,applied_at,offer_id,offer_code_applied,redeemed_at,uuid,update_date)

select a.id,version,    case when applied_at is null then null else Cast(applied_at as Datetime) end as applied_at
,case when offer_id is null then null else Cast(offer_id as Bigint ) end as offer_id
,offer_code_applied,case when redeemed_at is null  or redeemed_at = 'null' then null else Cast(redeemed_at as Datetime) end as redeemed_at
,uuid,case when update_date is null then null else Cast(update_date as Datetime) end as update_date
from  Datawarehouse.staging.Snag_ssis_UsedSubOffer a
left join (select id from Datawarehouse.archive.TGCPlus_UsedSubOffer_1 ) b
on a.id= b.id
where b.id is null

*/

End 




GO
