SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE Proc [Staging].[SP_Load_Snag_PaymentAuthorizationStatus_1]
as

Begin

--Table column issues
--Create table Datawarehouse.archive.TGCPlus_PaymentAuthorizationStatus_1
--(
--id	bigint   NOT Null,
--version	 bigint   NOT Null,
--created_at 	datetime  Null,
--plan_id bigint  Null,
--state	varchar(255)  Null,
--updated_at	datetime  Null,
--uuid varchar(255)  Null,
--payment_hadler	 varchar(255)  Null,
--subscribed_via_platform	 varchar(255)  Null,
--LastupdatedDate datetime not null default(getdate())
--)



/*********************Load into Clean table*********************/

Truncate table Datawarehouse.archive.TGCPlus_PaymentAuthorizationStatus_1

insert into Datawarehouse.archive.TGCPlus_PaymentAuthorizationStatus_1
(id,version,created_at,plan_id,state,updated_at,uuid,payment_hadler,subscribed_via_platform)
 
 select  id,version,    case when created_at is null then null else Cast(created_at as datetime) end as created_at
,plan_id,state,case when updated_at is null then null else Cast(updated_at as datetime) end as updated_at
,uuid,payment_hadler,subscribed_via_platform
from  Datawarehouse.staging.Snag_ssis_PaymentAuthorizationStatus
 


/*
 delete b from  Datawarehouse.staging.Snag_ssis_PaymentAuthorizationStatus a
 inner join (select id from  Datawarehouse.archive.TGCPlus_PaymentAuthorizationStatus_1 ) b
 on a.id=b.id 

insert into Datawarehouse.archive.TGCPlus_PaymentAuthorizationStatus_1
(id,version,created_at,plan_id,state,updated_at,uuid,payment_hadler,subscribed_via_platform)
 
 select  a.id,version,    case when created_at is null then null else Cast(created_at as datetime) end as created_at
,plan_id,state,case when updated_at is null then null else Cast(updated_at as datetime) end as updated_at
,uuid,payment_hadler,subscribed_via_platform
from  Datawarehouse.staging.Snag_ssis_PaymentAuthorizationStatus a
 left join (select id from  Datawarehouse.archive.TGCPlus_PaymentAuthorizationStatus_1 ) b
 on a.id=b.id 
 where b.id is null
 
 */
 

End 



GO
