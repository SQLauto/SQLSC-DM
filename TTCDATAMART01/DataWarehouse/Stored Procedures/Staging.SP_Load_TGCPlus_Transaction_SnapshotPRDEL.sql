SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create PROC [Staging].[SP_Load_TGCPlus_Transaction_SnapshotPRDEL] @Date Date = null
As
Begin

If @Date is null 
begin
set @Date = DATEADD(month, DATEDIFF(month, 0, getdate()), 0)
end 

 

select  *
into #Suspended
from (
select pa_id,pa_user_id,pas_id,pas_version,pas_created_at,pas_plan_id,pas_state,pas_updated_at,pas_uuid,pas_payment_handler,pas_subscribed_via_platform from [Archive].[TGCPlus_PaymentAuthorizationStatus_ROKU_BKP_20170220]
except 
select pa_id,pa_user_id,pas_id,pas_version,pas_created_at,pas_plan_id,pas_state,pas_updated_at,pas_uuid,pas_payment_handler,pas_subscribed_via_platform from [Archive].[TGCPlus_PaymentAuthorizationStatus]
)a 



select id as Customerid, joined  as Eventdate,'Registered' as Event,id ,'Registered' as Eventstatus , CAST(NULL AS INT) AS plan_id,CAST(null AS VARCHAR(255)) AS SubType, CAST(NULL AS VARCHAR(255)) AS payment_handler
into #Registered 
from DataWarehouse.archive.TGCplus_user u (nolock)
where joined is not null

--Entitled

select u.id AS Customerid, entitled_dt  as Eventdate ,'Subscribed' as Event, u.id,'Subscribed' as Eventstatus , subscription_plan_id AS plan_id,SP.billing_cycle_period_type AS SubType, payment_handler AS payment_handler
into #Subscribed
from DataWarehouse.archive.TGCplus_user u (nolock)
JOIN DataWarehouse.Archive.TGCPlus_SubscriptionPlan SP  
ON Sp.id = u.subscription_plan_id
where entitled_dt is not null

--Billing

select b.user_id as Customerid,b.completed_at as Eventdate,'Billing' as Event, b.id AS id ,type as Eventstatus, subscription_plan_id AS plan_id,b.billing_cycle_period_type AS SubType, payment_handler AS payment_handler
into #billing
from DataWarehouse.Archive.TGCPlus_UserBilling20170802 b


--PaymentAuth

select p.pa_user_id as Customerid,p.pas_created_at as Eventdate,'PaymentAuthStatus' as Event ,p.pas_id id, pas_state as Eventstatus, p.pas_plan_id AS plan_id,SP.billing_cycle_period_type AS SubType
, p.pas_payment_handler AS payment_handler
into #PaymentAuthStatus
from DataWarehouse.Archive.TGCPlus_PaymentAuthorizationStatus p 
JOIN DataWarehouse.Archive.TGCPlus_SubscriptionPlan SP  
ON Sp.id = P.pas_plan_id
UNION 
select p.pa_user_id as Customerid,p.pas_created_at as Eventdate,'PaymentAuthStatus' as Event ,p.pas_id id, pas_state as Eventstatus, p.pas_plan_id AS plan_id,SP.billing_cycle_period_type AS SubType
, p.pas_payment_handler AS payment_handler
from #Suspended p 
JOIN DataWarehouse.Archive.TGCPlus_SubscriptionPlan SP  
ON Sp.id = P.pas_plan_id

select p.pa_user_id as Customerid,p.pas_created_at as Eventdate,'PaymentAuthStatus' as Event ,p.pas_id id, pas_state as Eventstatus, p.pas_plan_id AS plan_id,SP.billing_cycle_period_type AS SubType
, p.pas_payment_handler AS payment_handler
into #PaymentAuthStatus2
from DataWarehouse.Archive.TGCPlus_PaymentAuthorizationStatus p 
JOIN DataWarehouse.Archive.TGCPlus_SubscriptionPlan SP  
ON Sp.id = P.pas_plan_id
UNION 
select p.pa_user_id as Customerid,p.pas_created_at as Eventdate,'PaymentAuthStatus' as Event ,p.pas_id id, pas_state as Eventstatus, p.pas_plan_id AS plan_id,SP.billing_cycle_period_type AS SubType
, p.pas_payment_handler AS payment_handler
from #Suspended p 
JOIN DataWarehouse.Archive.TGCPlus_SubscriptionPlan SP  
ON Sp.id = P.pas_plan_id

--PaymentAuthoffer

select p.pa_user_id as Customerid,p.uso_applied_at as Eventdate,'PaymentAuthOffer' as Event ,p.uso_id id, ISNULL(uso_offer_code_applied,'No Offer Description') as Eventstatus, CAST(NULL AS INT) AS plan_id
,CAST(null AS VARCHAR(255)) AS SubType, CAST(null AS VARCHAR(255))AS payment_handler
into #PaymentAuthOffer
from DataWarehouse.Archive.TGCPlus_PaymentAuthorizationUsedOffer p 
 
 
select  Customerid, id
,row_number()over( partition by Customerid order by Eventdate,Event desc)EventRank
, Eventdate,Event
--,cast(row_number()over( partition by Customerid order by Eventdate,Event desc)  as varchar(10))+ Event as EventRankDesc
, Eventstatus,a.plan_id,a.SubType,a.payment_handler
Into #TGCPlus_Transaction
from 
(
select * from #Registered
Union all
select * from #Subscribed
Union all
select * from #billing
Union all
select * from #PaymentAuthStatus
Union all
select * from #PaymentAuthOffer
)
a
where Eventdate<@Date
order by 2,1,4
 

DELETE FROM #TGCPlus_Transaction
WHERE Customerid IN (SELECT id FROM DataWarehouse.archive.TGCPlus_User WHERE email LIKE '%+%' OR email LIKE '%plustest%' OR email LIKE '%teachco%')

/* Billing Entitled*/
select user_id AS Customerid,completed_at, service_period_from, service_period_to , CAST(0 AS BIT) AS RefundFlag
into #BillingEntitled
from DataWarehouse.Archive.TGCPlus_UserBilling20170802 
where type = 'Payment'
and completed_at < @Date
group by user_id,completed_at, service_period_from, service_period_to 

/* Billing Refunded*/
select user_id AS Customerid,completed_at ,service_period_from, service_period_to 
 into #BillingRefunded
from DataWarehouse.Archive.TGCPlus_UserBilling20170802 
where type = 'Refund'
and completed_at < @Date
group by user_id,completed_at, service_period_from, service_period_to 


/* ReCalculate billing date based on refund issued r.completed*/
UPDATE E 
SET E.service_period_to = COALESCE(r.completed_at,E.service_period_to), RefundFlag = CASE WHEN r.completed_at IS NOT NULL THEN 1 END 
FROM #BillingEntitled e
LEFT JOIN #BillingRefunded r
ON e.Customerid = r.Customerid AND e.service_period_from = r.service_period_from AND e.service_period_to = r.service_period_to 


/*
--Billing NEW Entitled date if the billing cycle did not expire and there was another billing cycle, then set the first cycle to end with second billing start date-
DROP TABLE #BillingEntitledNew
SELECT E1.Customerid,E1.completed_at,E1.service_period_from,E1.service_period_to,e1.RefundFlag,
MIN(CASE WHEN e1.service_period_to < e2.service_period_from THEN e1.service_period_to ELSE e2.service_period_from END) AS New_service_period_to
, CAST (0 AS BIT) AS UpdatedServicePeriodToFlag
INTO #BillingEntitledNew
FROM #BillingEntitled e1 
left JOIN  #BillingEntitled e2 
ON e1.customerid = e2.customerid AND e1.completed_at< e2.completed_at
and e2.service_period_from  BETWEEN e1.service_period_from    AND e1.service_period_to
--where  e1.Customerid = 1238769 
GROUP BY E1.Customerid,E1.completed_at,E1.service_period_from,E1.service_period_to,e1.RefundFlag
ORDER BY 2
*/

-- Billing NEW Entitled date if the billing cycle did not expire and there was another billing cycle, then set the first cycle to end with second billing start date - 1 minute 
SELECT E1.Customerid,E1.completed_at,E1.service_period_from,E1.service_period_to,e1.RefundFlag,
MIN(CASE WHEN e1.service_period_to < e2.service_period_from THEN e1.service_period_to ELSE DATEADD(MINUTE,-1,e2.service_period_from) END) AS New_service_period_to
, CAST (0 AS BIT) AS UpdatedServicePeriodToFlag
INTO #BillingEntitledNew
FROM #BillingEntitled e1 
left JOIN  #BillingEntitled e2 
ON e1.customerid = e2.customerid AND e1.completed_at< e2.completed_at
and e2.service_period_from  BETWEEN e1.service_period_from    AND e1.service_period_to
--where  e1.Customerid = 1053617 
GROUP BY E1.Customerid,E1.completed_at,E1.service_period_from,E1.service_period_to,e1.RefundFlag
ORDER BY 2


/* Update Corrected dates based on the billing data only for */
UPDATE #BillingEntitledNew
SET service_period_to = New_service_period_to,   UpdatedServicePeriodToFlag = 1
WHERE New_service_period_to IS NOT NULL
 


/* Billing Max Entitled*/
select   Customerid, max(service_period_from)Max_service_period_from, max(service_period_to)Max_service_period_to 
 into #BillingMax_Entitled
from #BillingEntitledNew 
group by Customerid

IF OBJECT_ID('Archive.TGCPlus_Transaction_SnapshotPRDEL') IS NOT NULL
DROP TABLE Archive.TGCPlus_Transaction_SnapshotPRDEL

select t.*
, CASE WHEN Type = 'PAYMENT' THEN ISNULL(pre_tax_amount,0) ELSE -1*ISNULL(pre_tax_amount,0) END Payment
, CASE WHEN Type = 'Refund' THEN 1 ELSE ISNULL(BE.RefundFlag,0) END AS RefundFlag --,BE.New_service_period_to
, ISNULL(BE.UpdatedServicePeriodToFlag,0) UpdatedServicePeriodToFlag
,BE.service_period_from,BE.service_period_to,BME.Max_service_period_from,BME.Max_service_period_to 
,GETDATE() AS DMLastupdated
INTO Archive.TGCPlus_Transaction_SnapshotPRDEL
FROM  #TGCPlus_Transaction t
left join #BillingEntitledNew BE
on BE.Customerid = t.Customerid AND t.Eventdate  >= BE.service_period_from  and t.Eventdate <= BE.service_period_to 
left join #BillingMax_Entitled BME
on BME.Customerid = t.Customerid 
AND t.Eventdate  >= BME.Max_service_period_from 
LEFT JOIN DataWarehouse.Archive.TGCPlus_UserBilling20170802 UB
ON Ub.id  =  t.id AND Event = 'Billing'
order by 1,3





IF OBJECT_ID('Archive.TGCPlus_CustomerStatus_SnapshotPRDEL') IS NOT NULL
DROP TABLE Archive.TGCPlus_CustomerStatus_SnapshotPRDEL

--drop table ##TGCPlus_QC 
SELECT  F.Customerid,F.id,F.EventRank,F.Eventdate,F.Event,F.Eventstatus,F.plan_id,F.SubType,F.payment_handler,F.Payment,
F.RefundFlag,F.UpdatedServicePeriodToFlag,F.service_period_from,F.service_period_to,F.Max_service_period_from,F.Max_service_period_to,
F1. LTDPayment,F1. Refunds, F1. Payments--,DISTINCT EVENT,Eventstatus
, CASE 
WHEN Eventstatus = 'REFUND' AND LTDPayment = 0  THEN 'Complete REFUND'
WHEN Eventstatus = 'REFUND' AND LTDPayment > 0 AND (LTDPayment > Payment OR Payments>1) THEN 'Partial REFUND'
WHEN Eventstatus = 'Suspended' AND LTDPayment = 0 THEN 'Suspended'
WHEN Eventstatus = 'Suspended' AND LTDPayment > 0 THEN 'Suspended later'
WHEN Eventstatus = 'Payment Handler Issue' THEN 'Payment Handler Issue'
WHEN Eventstatus IN ('PAYMENT','Completed') AND LTDPayment = 0 AND (LTDPayment = Payment OR Payments=1 OR CAST(Eventdate AS DATE) BETWEEN CAST(Max_service_period_from AS DATE) AND CAST(Max_service_period_to AS DATE)) THEN 'Free Trial'
WHEN Eventstatus = 'Deferred Suspension' AND LTDPayment = 0 /*AND CAST(Eventdate AS DATE) BETWEEN CAST(Max_service_period_from AS DATE) AND CAST(Max_service_period_to AS DATE)*/ THEN 'Free Trial Deferred Suspension'
WHEN Eventstatus = 'Deferred Suspension' AND LTDPayment > 0 /*AND CAST(Eventdate AS DATE) BETWEEN CAST(Max_service_period_from AS DATE) AND CAST(Max_service_period_to AS DATE)*/ THEN 'Paid Deferred Suspension'
WHEN Eventstatus = 'Cancelled' AND LTDPayment = 0 AND Refunds > 0 AND payments>0 THEN 'Complete REFUND'
WHEN Eventstatus = 'Cancelled' AND LTDPayment = 0 AND CAST(Eventdate AS DATE) BETWEEN CAST(Max_service_period_from AS DATE) AND CAST(Max_service_period_to AS DATE) THEN 'Free Trial Cancelled'
WHEN Eventstatus = 'Cancelled' AND LTDPayment = 0 AND CAST(Eventdate AS DATE) > CAST(Max_service_period_from AS DATE)  THEN 'Free Trial Cancelled Later'
WHEN Eventstatus = 'Cancelled' AND LTDPayment = 0 /*AND CAST(Eventdate AS DATE) BETWEEN CAST(Max_service_period_from AS DATE) AND CAST(Max_service_period_to AS DATE)*/ THEN 'Not Paid Cancelled'
WHEN Eventstatus = 'Cancelled' AND LTDPayment > 0 /*AND CAST(Eventdate AS DATE) BETWEEN CAST(Max_service_period_from AS DATE) AND CAST(Max_service_period_to AS DATE)*/ THEN 'Paid Cancelled'
WHEN Eventstatus IN ('Completed') AND LTDPayment = 0 AND (F.Eventdate >= Max_service_period_to  OR CAST(@Date AS date)> F.Max_service_period_to) THEN 'Billing Issue'
WHEN Eventstatus IN ('Completed') AND LTDPayment = 0 AND F.Max_service_period_to IS null THEN 'Billing Issue'
--WHEN Eventstatus IN ('Pending','Completed') AND LTDPayment = 0 AND CAST(@Date AS date)> F.Max_service_period_to THEN 'Recurring Payment Issue'
WHEN Eventstatus IN ('PAYMENT','Completed') AND LTDPayment > 0 AND (LTDPayment = Payment OR Payments=1) THEN 'Initial Payment'
WHEN Eventstatus IN ('PAYMENT','Completed') AND LTDPayment > 0 AND (LTDPayment > Payment OR Payments > 1) THEN 'Recurring Payment'
WHEN Eventstatus ='Pending' THEN 'Pending'
WHEN Eventstatus = 'Registered'  THEN 'Registered Only'
WHEN EVENT = 'PaymentAuthOffer' THEN 'Offer Applied'END AS Status
, CASE WHEN CAST(dateadd(d,-1,@Date) AS date) BETWEEN CAST(f.Max_service_period_from AS DATE) AND CAST(f.Max_service_period_to AS DATE) THEN 1 ELSE 0 END AS ActiveSubscriber 
,GETDATE() AS DMLastupdated
--INTO ##TGCPlus_QC
INTO Archive.TGCPlus_CustomerStatus_SnapshotPRDEL
FROM Archive.TGCPlus_Transaction_SnapshotPRDEL F
JOIN (SELECT Customerid,SUM(CAST(Payment AS DECIMAL(5,2))) AS LTDPayment, MAX(Eventrank)Eventrank, SUM( CASE WHEN Eventstatus = 'Refund' AND payment <0 THEN 1 ELSE 0 END) AS Refunds, SUM(CASE WHEN Eventstatus = 'Payment' AND payment >0 THEN 1 ELSE 0 END) 

Payments
FROM Archive.TGCPlus_Transaction_SnapshotPRDEL GROUP BY Customerid ) F1
ON F.customerid = f1.Customerid AND f.EventRank = f1.Eventrank
--WHERE CAST(ISNULL(max_service_period_to,GETDATE()-5) AS DATE) < CAST(GETDATE()-5  AS DATE)
--AND Eventstatus = 'PAYMENT'


--SELECT Status,--CAST(ISNULL(max_service_period_to,GETDATE()-5) AS DATE), 
--COUNT(*) 
--FROM Archive.TGCPlus_CustomerStatus
--WHERE CAST(ISNULL(max_service_period_to,GETDATE()-5) AS DATE) < CAST(GETDATE()-5  AS DATE)
----AND Eventstatus = 'PAYMENT'
--GROUP BY Status--,CAST(ISNULL(max_service_period_to,GETDATE()-5) AS DATE)  
--ORDER BY 2
 


 END 

GO
