SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE Proc [dbo].[SP_TGCPLus_Load_DS]
As

Begin
--drop table #tgcplus_userbilling_Payments
select a.*,Row_number() over(partition by user_id order by service_period_from , completed_at) BillingRank,
--select a.*,Row_number() over(partition by user_id order by completed_at,service_period_from ) BillingRank, --VB 10/5/2017 test for billing rank fix
--service_period_to as Adjusted_Service_period_to,
Cast(0 as Bit) Refunded ,
Cast(0 as Money) RefundedAmount,
Cast(null as datetime) Refunded_Completed_at,
Cast(0 as Bit) Changed_RefundedService_period_to, 
Cast(0 as Bit) Changed_Service_period_to ,
Cast(0 as Bit) Changed_Billing_cycle_period_type ,
Cast(0 as Bit) Changed_Subscription_plan_id,
Cast(0 as Bit) Changed_Payment_handler,
Cast(null as datetime) PAS_Cancelled_date,
Cast(0 as Bit) PAS_Cancelled,
Cast(null as datetime) PAS_DeferredSuspension_date,
Cast(0 as Bit) PAS_DeferredSuspension,
Cast(null as datetime) PAS_Suspended_date,
Cast(0 as Bit) PAS_Suspended,
Cast(0 as Int) BillingDupes,
Cast(0 as Bit) UBIssue,
Cast(null as int) uso_offer_id,
Cast(null as varchar(255)) uso_offer_code_applied,
Cast(null as datetime) uso_applied_at,
Cast(null as varchar(255)) Final_Status
into #tgcplus_userbilling_Payments
From  (
select distinct User_id,completed_at,billing_cycle_period_type,Type,Cast(pre_tax_amount as Money)pre_tax_amount,service_period_from,service_period_to ,service_period_to as actual_service_period_to ,subscription_plan_id,payment_handler
from Datawarehouse.archive.tgcplus_userbilling ub
join Datawarehouse.Archive.Vw_TGCPlus_ValidUser cs
on cs.customerid = ub.user_id
where Type = 'PAYMENT' 
and completed_at>='9/28/2015'
	)a



--Refunds
--drop table #tgcplus_userbilling_Refunds
select distinct User_id,completed_at,billing_cycle_period_type,Type,pre_tax_amount,service_period_from,service_period_to  ,subscription_plan_id,payment_handler
into #tgcplus_userbilling_Refunds
from Datawarehouse.archive.tgcplus_userbilling ub
join Datawarehouse.Archive.Vw_TGCPlus_ValidUser cs
on cs.customerid = ub.user_id
where Type = 'Refund' 
and completed_at>='9/28/2015'

 
--drop table #PAS 
select distinct Pas.pa_user_id,Pas.pas_plan_id, Pas.pas_created_at , Pas.pas_payment_handler, Pas.pas_state  
into #PAS 
From Datawarehouse.archive.tgcplus_PaymentAuthorizationStatus PAS
join Datawarehouse.Archive.Vw_TGCPlus_ValidUser cs
on cs.customerid = PAS.Pa_user_id
where pas.pas_created_at>='9/28/2015'
and pas_state in ('Suspended','Deferred Suspension','Cancelled')

 /*Fix data for duplicate start periods and different end periods*/

 --select user_id, service_period_from,max(service_period_to)Max_service_period_to 
	--from #tgcplus_userbilling_Payments
	--group by user_id,service_period_from
	--having count(*)>1


select ub.User_id,	min(completed_at)completed_at,	min(billing_cycle_period_type)billing_cycle_period_type,min(Type)Type,	
sum(pre_tax_amount)pre_tax_amount,	ub.service_period_from,	max(service_period_to) service_period_to,max(actual_service_period_to)actual_service_period_to,	
min(subscription_plan_id)subscription_plan_id,min(payment_handler) payment_handler,min(BillingRank) BillingRank,	Cast(0 as Bit) Refunded ,
Cast(0 as Money) RefundedAmount,Cast(null as datetime) Refunded_Completed_at,Cast(0 as Bit) Changed_RefundedService_period_to, Cast(0 as Bit) Changed_Service_period_to ,
Cast(0 as Bit) Changed_Billing_cycle_period_type ,Cast(0 as Bit) Changed_Subscription_plan_id,Cast(0 as Bit)Changed_Payment_handler,Cast(null as datetime) PAS_Cancelled_date,
Cast(0 as Bit) PAS_Cancelled,Cast(null as datetime) PAS_DeferredSuspension_date,Cast(0 as Bit) PAS_DeferredSuspension,Cast(null as datetime) PAS_Suspended_date,
Cast(0 as Bit) PAS_Suspended,Count(*) as BillingDupes,Cast(1 as Bit)UBIssue,Cast(0 as int) uso_offer_id,Cast(0 as varchar(255)) uso_offer_code_applied,Cast(null as datetime) uso_applied_at,Cast(null as varchar(255)) Final_Status
Into #UB_dupes
from  
 #tgcplus_userbilling_Payments ub
 join (select user_id, service_period_from,max(service_period_to)Max_service_period_to 
	from #tgcplus_userbilling_Payments
	group by user_id,service_period_from
	having count(*)>1
	) ubdupes 
 on ub.user_id = ubdupes.user_id
 and ub.service_period_from = ubdupes.service_period_from
 group by ub.user_id , ub.service_period_from
order by 1,2

/* Delete Dupes */
delete ub  from #tgcplus_userbilling_Payments ub
join #UB_dupes dupes
on Ub.user_id = dupes.user_id
and ub.service_period_from = dupes.service_period_from

/*Load Remaining and Recalculate Billing Rank */
insert into #UB_dupes
select ub.*
from  
 #tgcplus_userbilling_Payments ub
 join #UB_dupes ubdupes 
 on ub.user_id = ubdupes.user_id

/* Delete All and reload after ranking  */
delete ub  from #tgcplus_userbilling_Payments ub
join #UB_dupes dupes
on Ub.user_id = dupes.user_id

--select * into ##UB_dupes from  #UB_dupes

insert into #tgcplus_userbilling_Payments
 select User_id,completed_at,billing_cycle_period_type,Type,Cast(pre_tax_amount as Money)pre_tax_amount,service_period_from,service_period_to ,service_period_to as actual_service_period_to ,subscription_plan_id,payment_handler
 ,Row_number() over(partition by user_id order by service_period_from , completed_at) BillingRank 
 --,Row_number() over(partition by user_id order by completed_at,service_period_from) BillingRank --VB 10/5/2017 test for billing rank fix
 
 ,Refunded , RefundedAmount, Refunded_Completed_at,Changed_RefundedService_period_to, Changed_Service_period_to ,Changed_Billing_cycle_period_type ,Changed_Subscription_plan_id,
Changed_Payment_handler, PAS_Cancelled_date,PAS_Cancelled, PAS_DeferredSuspension_date,PAS_DeferredSuspension, PAS_Suspended_date,PAS_Suspended,BillingDupes,UBIssue,uso_offer_id,uso_offer_code_applied, uso_applied_at, Final_Status
 from #UB_dupes UB
 order by 1,2

-- select ubdupes.*,ub.* from 
-- #tgcplus_userbilling_Payments ub
-- join #UB_Dupes ubdupes 
-- on ub.user_id = ubdupes.user_id
-- and ub.service_period_from = ubdupes.service_period_from
--order by 1,2

/*Updates based on Refunds, for now ignoring to update entitlement untill suspended/cancelled*/
Update P
set Refunded = Case when R.Type ='REFUND' then 1 else 0 end,
	RefundedAmount = Isnull(R.pre_tax_amount,0),
	Refunded_Completed_at = R.Completed_at
	--service_period_to = Case when R.completed_at < P.service_period_to then Isnull(R.completed_at,P.service_period_to) else P.service_period_to end,
	--Changed_RefundedService_period_to = Case when Isnull(R.completed_at,P.service_period_to) < P.service_period_to then 1 else 0 end
from #tgcplus_userbilling_Payments P
join #tgcplus_userbilling_Refunds R
on P.user_id = R.user_id 
and P.service_period_from = R.service_period_from

 
/*Update Flag if changes to Service_period_to and update Service_period_to Based on multiple billing periods*/ 
update a
set Service_period_to = Case when b.service_period_from < a.service_period_to then b.service_period_from else a.service_period_to end,
Changed_Service_period_to = Case when b.service_period_from < a.service_period_to then 1 else 0 end
from #tgcplus_userbilling_Payments a
join #tgcplus_userbilling_Payments b
on a.user_id = b.user_id and a.billingrank + 1 = b.Billingrank
 
 
/*Update Change Flags if changes to Billing_cycle_period_type	Subscription_plan_id	Payment_handler */
update b
set 
Changed_Billing_cycle_period_type = Case When a.billing_cycle_period_type <> b.billing_cycle_period_type then 1 else 0 end ,
Changed_Subscription_plan_id = Case When a.subscription_plan_id <> b.subscription_plan_id then 1 else 0 end,
Changed_Payment_handler = Case When a.payment_handler <> b.payment_handler then 1 else 0 end
from #tgcplus_userbilling_Payments a
join #tgcplus_userbilling_Payments b
on a.user_id = b.user_id and a.billingrank + 1 = b.Billingrank


/*Pas Updates for Cancels/Suspends/DeferredSuspension based if in service_period_from and Dateadd(d,7,service_period_to) */ 
 update UB
 set  PAS_Cancelled_date = UB1.PAS_Cancelled_date,	 
      PAS_Cancelled = UB1.PAS_Cancelled,
	  PAS_DeferredSuspension_Date = UB1.PAS_DeferredSuspension_Date,
	  PAS_DeferredSuspension = UB1.PAS_DeferredSuspension,	
	  PAS_Suspended_Date = UB1.PAS_Suspended_Date,
	  PAS_Suspended = UB1.PAS_Suspended

 from  #tgcplus_userbilling_Payments UB
 join 
(select 
	 UB.user_id, UB.billingRank, 
     PAS_Cancelled_date = max(case when pas_state = 'Cancelled' then pas.pas_created_at else null end),	 
     PAS_Cancelled = max(case when pas_state = 'Cancelled' then 1 else 0 end),
	 PAS_DeferredSuspension_Date = max(case when pas_state = 'Deferred Suspension' then pas.pas_created_at else null end),
	 PAS_DeferredSuspension = max(case when pas_state = 'Deferred Suspension' then 1 else 0 end),	
	 PAS_Suspended_Date = max(case when pas_state = 'Suspended' then pas.pas_created_at else null end),
	 PAS_Suspended = max(case when pas_state = 'Suspended' then 1 else 0 end)
 from #tgcplus_userbilling_Payments UB
 join #pas pas
 on pas.pa_user_id = UB.user_id
 and pas.pas_plan_id = UB.subscription_plan_id
 and pas.pas_payment_handler = Ub.payment_handler
 and Pas.Pas_created_at between service_period_from	and Dateadd(d,7,service_period_to)
 group by UB.user_id, UB.billingRank
 )UB1 
 on UB.user_id=UB1.user_id
 and UB.billingRank  = UB1.billingRank 

 --Used offercode update

 --drop table #USO 
	select uo.pa_user_id,uso_offer_id,uo.uso_id,uso_applied_at,uso_offer_code_applied,uso_redeemed_at, Row_number() over(partition by pa_user_id order by uso_applied_at ,uso_redeemed_at desc) USORank 
	 into #USO 
	from datawarehouse.[Archive].[TGCPlus_PaymentAuthorizationUsedOffer] uo
	left join [Archive].[TGCPlus_SubscriptionOffer] so
	on uo.uso_offer_id = so.id

 update UB
 set UB.uso_offer_id = uso.uso_offer_id,
 UB.uso_offer_code_applied = uso.uso_offer_code_applied,
 UB.uso_applied_at = uso.uso_applied_at
 from #tgcplus_userbilling_Payments UB
 left join #USO uso
 on ub.user_id = uso.pa_user_id and uso.uso_applied_at between service_period_from	and service_period_to  and USORank  = 1
 --where user_id = 3191975

 

 --drop table #DS
 select *,cast(null as int)DS into #DS
 from #tgcplus_userbilling_Payments

/*  Set DS = 0 for Initial dollar payment*/
	update d
	set DS = 0
	From #DS d
	where BillingRank =  1 
	and pre_tax_amount = 0;

/*  Set DS = 0 untill initial Payment > 0 */
	update d
	set DS = 0
	 From #DS d
	  join (	select User_id,Min(BillingRank)Min_BillingRank 
				from #DS
				where pre_tax_amount> 0
				group by User_id
			) d1 
	 on d1.user_id = d.user_id
	 and d.BillingRank < d1.Min_BillingRank;


 update d
 set d.DS = d1.DS
   from #DS d
   join (select User_id,BillingRank, 
		Row_number() Over( partition by user_id order by BillingRank) DS
		from #DS
		where DS is null
		) d1 
 on d1.user_id = d.user_id
 and d.BillingRank = d1.BillingRank;


  --drop table #DS_Calc
 
  select BillingRank,DS,User_id,Datediff(d,Service_period_from, service_period_to) as Days,
  Service_period_from,
  service_period_to,
  --Cast(service_period_to as date) End_DSDate,
  Datediff(M,Service_period_from, service_period_to)MonthDiff 
  into #DS_Calc
  from #DS
   order by 2,1


  
  
 --drop table #DS_Final

 select User_id,Days,Service_period_from,service_period_to,MonthDiff,Month,year,max(D.Date)As DSDate
 into #DS_Final
 from Datawarehouse.mapping.date d
 join #DS_Calc E
 On d.date between E.Service_period_from and Cast(service_period_to as date)
 and Datepart(d,d.date) <= Datepart(D,Cast(service_period_to as date))
 where MonthDiff >1
 group by User_id,Days,Service_period_from,service_period_to,MonthDiff,Month,year;

 insert into #DS_Final
 select User_id,Days,Service_period_from,service_period_to,MonthDiff,Month,year,max(D.Date)As DSDate
 from Datawarehouse.mapping.date d
 join #DS_Calc E
 On d.date = Cast(service_period_to as date)
  where MonthDiff <=1
 group by User_id,Days,Service_period_from,service_period_to,MonthDiff,Month,year;

 

 --drop table #DS_Additional
 select *, Lead(Service_period_from) over( Partition by user_id Order by DSDate) Next_Service_period_from,
 --Lead(Service_period_from,2) over( Partition by user_id Order by DSDate) Next2_Service_period_from,
 DateDiff(d,service_period_to,Lead(Service_period_from) over( Partition by user_id Order by DSDate)) as MissingDays, 
 Case when DateDiff(d,service_period_to,Lead(Service_period_from) over( Partition by user_id Order by DSDate))>1
 then dateadd(d,1,service_period_to)
 else null end as MissingDSStart, 
 Case when DateDiff(d,service_period_to,Lead(Service_period_from) over( Partition by user_id Order by DSDate))>1
 then dateadd(d,-1,Lead(Service_period_from) over( Partition by user_id Order by DSDate))
 else null end as MissingDSEnd
 into #DS_Additional
 from #DS_Final


    
 --drop table #DS_ALL

 -- DS_Entitled (0,1) 
 -- if DS_Entitled = 1 Has Entitlement 

 --DS_ValidDS (0,1,2)
 --if DS_Entitled = 1  DS calculated based on Entitlement Dates 
 --if DS_Entitled = 2  DS Dates have been padded for gaps of subscription
 --if DS_Entitled = 0  DS Dates have been padded for gaps of subscription but, these will not have a DS # as the gaps are incomeplete for DS Calculations


 select User_id,Days,Service_period_from,Service_period_to,MonthDiff,Month,DSDate,1 as ValidDS,1 as DS_Entitled
 into #DS_ALL
 from #DS_Additional 

 insert into #DS_ALL
 select User_id,Days,Service_period_from,Service_period_to,MonthDiff,Month,DSDate,ValidDS, DS_Entitled
 from 
 ( 
 /* greater than one month*/
 select User_id,Datediff(d,MissingDSStart,MissingDSEnd)Days,MissingDSStart as Service_period_from,MissingDSEnd as Service_period_to,MonthDiff
 ,d.Month,max(D.Date)As DSDate,2 as ValidDS,0 as DS_Entitled
 from Datawarehouse.mapping.date d
 join (
 select * from #DS_Additional
) E
 On d.date between E.MissingDSStart and E.MissingDSEnd
 and Datepart(d,d.date) <= Datepart(D,E.service_period_to)
 where datediff(m,MissingDSStart,MissingDSEnd)>1
 group by User_id,Days,MissingDSStart,MissingDSEnd,MonthDiff,d.Month
union 
/* less than or in one month*/
select User_id,Datediff(d,MissingDSStart,MissingDSEnd)Days,MissingDSStart,MissingDSEnd,MonthDiff,d.Month,max(D.Date)As DSDate,
Case when max(D.Date) between MissingDSStart and Dateadd(d,-1,MissingDSEnd) then 1 else 0 end as ValidDS
,0 as DS_Entitled
 from Datawarehouse.mapping.date d
 join ( select * from #DS_Additional
 ) E
 --On d.date = cast(E.MissingDSEnd as date)
  On d.date between E.MissingDSStart and E.MissingDSEnd
 and Datepart(d,d.date) <= Datepart(D,E.service_period_to)
 where datediff(m,MissingDSStart,MissingDSEnd) <=1
 group by User_id,Days,MissingDSStart,MissingDSEnd,MonthDiff,d.Month
 )a
  order by 7


 
  --select * from #DS_ALL
  --where user_id in (  select  distinct top 2 user_id from #DS_ALL where ValidDS in (0))
  --order by user_id,DSDate

  --select * from #DS_ALL
  --where user_id in (  select distinct top 2 user_id from #DS_ALL where DS_Entitled in (0))
  --order by user_id,DSDate

  --exception for ValidDS = 1 and Days = 0 ignore for DS # Calc also ignore when ValidDS = 0
   
 --select * from #DS_Additional
 --where User_id = 1219363
 --select  * from #DS_ALL DS
 --where DS.User_id = 1219363

   --select * from #DS_ALL
  --where user_id in (  select distinct user_id from #DS_ALL DS  where  Days = 0 and ValidDS = 1)
  --order by user_id,DSDate


  --drop table #DSPAS
  select Coalesce(DS.DSDate,U.Service_period_to)Coalesce_DSDate ,Coalesce(DS.User_id,u.user_id)CustomerID,
  DS.User_id as DS_User_id,DS.Days as EntitlementDays,	DS.Service_period_from as DS_Service_period_from,	DS.Service_period_to as DS_Service_period_to,	DS.MonthDiff as DS_MonthDiff,
  DS.Month as DS_Month,	DS.DSDate,	DS.ValidDS as DS_ValidDS, 	DS.DS_Entitled as DS_Entitled,U.*,cast(null as money) Amount,cast(null as money) NetAmount,
  cast(null as Int) DS,cast(null as Int) DSSplits,Cast(0 as int) as PaidFlag
  into #DSPAS
  from #DS_ALL DS
  full outer join #tgcplus_userbilling_Payments U 
  on DS.user_id = U.User_id
  --and DS.DSDate = Cast(U.Service_period_to as date)
  and U.Service_period_from = DS.Service_period_from
  and U.Service_period_to = DS.Service_period_to
  order by 2,1
    

	--issue with DSDays = 0 ignore for All DS Calculations further
	--select Coalesce_DSDate, CustomerID,Count(*) 
	--from #DSPAS
	--where EntitlementDays >0
	--group by Coalesce_DSDate, CustomerID
	--having Count(*)>1


 
  /*Now calculate # DS in BillingRank and Split them accross the numbers*/
  
  select CustomerID, BillingRank,pre_tax_amount as DSpre_tax_amount, 
  RefundedAmount as DSRefunded ,
  Count(Coalesce_DSDate)DSSplits
  ,Cast(0 as money) as Amount
  ,Cast(0 as money) as NetAmount
  into #DSSplits
  From #DSPAS
  where (BillingRank is not null and DS_ValidDS = 1 and EntitlementDays >0) 
  or pre_tax_amount > 0 
  group by CustomerID, BillingRank,pre_tax_amount,RefundedAmount

  update #DSSplits
  set NetAmount = (DSpre_tax_amount - DSRefunded)/DSSplits,
	  Amount = (DSpre_tax_amount)/DSSplits
 

	update DS
	set NetAmount = Sp.NetAmount,
		Amount	= Sp.Amount,
		DSSplits = Sp.DSSplits
	from #DSPAS Ds
	join #DSSplits Sp
	on Sp.CustomerID = DS.CustomerID
		and Sp.BillingRank = Ds.BillingRank

		  
  
  --drop table #DSPAS1
  --select Coalesce(DS.DSDate,U.Service_period_to)Coalesce_DSDate ,Coalesce(DS.User_id,u.user_id)CustomerID,
  --DS.User_id as DS_User_id,DS.Days as EntitlementDays,	DS.Service_period_from as DS_Service_period_from,	DS.Service_period_to as DS_Service_period_to,	DS.MonthDiff as DS_MonthDiff,
  --DS.Month as DS_Month,	DS.DSDate,	DS.ValidDS as DS_ValidDS, 	DS.DS_Entitled as DS_Entitled,U.*,
  --cast(null as money) NetAmount,cast(null as Int) DS,cast(null as Int) DSSplits
  ----into  #DSPAS1
  --from #DS_ALL DS
  --full outer join #tgcplus_userbilling_Payments U 
  --on DS.user_id = U.User_id
  --and DS.DSDate Between U.Service_period_to and Cast(U.Service_period_to as date)
  --where Coalesce(DS.User_id,u.user_id) = 1177119
  --order by 2,1

 

  --select distinct PriceChange.*,A.BillingRank, A.pre_tax_amount ,billing_cycle_period_type
  --from #DSPAS A
  --join (
  --select CustomerID as PriceChangeCustomerID,pre_tax_amount as PriceChangepre_tax_amount,max(BillingRank)  PriceChangeBillingRank from #DSPAS
  --where pre_tax_amount >200
  --and Year(Completed_at) in (2015,2016)
  --group by pre_tax_amount,CustomerID) PriceChange
  --on PriceChange.PriceChangeCustomerID = A.CustomerID 
  --and PriceChange.PriceChangeBillingRank + 1 = A.BillingRank 
  --where billing_cycle_period_type = 'YEAR' and A.pre_tax_amount = 0
  --order by 2

  /* Annual Customers who have paid a higher Price point got free Next year ie next yearly billing plan*/
  update A
  set PaidFlag = 1
  from #DSPAS A
  join (
  select CustomerID as PriceChangeCustomerID,pre_tax_amount as PriceChangepre_tax_amount,max(BillingRank)  PriceChangeBillingRank from #DSPAS
  where pre_tax_amount >200
  and Year(Completed_at) in (2015,2016)
  group by pre_tax_amount,CustomerID) PriceChange
  on PriceChange.PriceChangeCustomerID = A.CustomerID 
  and PriceChange.PriceChangeBillingRank + 1 = A.BillingRank 
  where billing_cycle_period_type = 'YEAR' and A.pre_tax_amount = 0
  

  Update #DSPAS
  set PaidFlag = 1
  where Amount>0


   update d
	set DS = NULL
	From #DSPAS d


  /*  Set DS = 0 for Initial dollar payment*/
	update d
	set DS = 0
	From #DSPAS d
	where BillingRank =  1 
	and pre_tax_amount = 0;

/*  Set DS = 0 untill initial Payment > 0 */
	update d
	set DS = 0
	 From #DSPAS d
	  join (	select User_id,Min(BillingRank)Min_BillingRank 
				from #DSPAS
				where pre_tax_amount> 0
				group by User_id
			) d1 
	 on d1.user_id = d.user_id
	 and d.BillingRank < d1.Min_BillingRank;
  
 update d
 set d.DS = d1.DS
   from #DSPAS  d
   join (select CustomerID,Coalesce_DSDate, 
		Row_number() Over( partition by CustomerID order by Coalesce_DSDate) DS
		from #DSPAS
		where DS is null 
		and ((DS_ValidDS <> 0 and EntitlementDays >0) or pre_tax_amount > 0 )
		 
		) d1 
 on d1.CustomerID = d.CustomerID
 and d.Coalesce_DSDate = d1.Coalesce_DSDate


  
 drop table Datawarehouse.Staging.TGCplus_DS_Working
 select * into Datawarehouse.Staging.TGCplus_DS_Working 
 from #DSPAS



 --select * from Datawarehouse.Staging.TGCplus_DS_Working
 --where DS = 0 and 
 --pas_Cancelled_date between DS_Service_period_from and Dateadd(d,7,DS_Service_period_to)
 
 --issues with ds is null blanks
 --select DS,* from Datawarehouse.Staging.TGCplus_DS_Working 
 --where CustomerID  in (  select CustomerID from Datawarehouse.Staging.TGCplus_DS_Working  where ds is null )
 --order by 3,2



---Additional Issues
 --select ds,* from Datawarehouse.Staging.TGCplus_DS_Working 
 -- where CustomerID  in (
	--						 select CustomerID  from Datawarehouse.Staging.TGCplus_DS_Working 
	--						 where isnull(DS,0)<>0
	--						 and NetAmount >0
	--						 group by CustomerID,ds
	--						 having count(*)>1
	--						 )
 --order by 3,2

 --Additional Issues DS Dupes due to 0 days entitlement and change in plans
	update DSW
	set DSW.DS_ValidDS  = 0,
		DS = null
	--select dsw.ds,* 
	from Datawarehouse.Staging.TGCplus_DS_Working DSW
	join (select customerid,DS,count(*) cnt ,max(BillingRank)BillingRank
	from Datawarehouse.Staging.TGCplus_DS_Working  
	where DS>0
	group by customerid,DS
	having count(*)>1
	) err
	on err.customerid = DSW.customerid 
	and err.DS  = DSW.DS 
	and err.BillingRank <> DSW.BillingRank



  drop table Datawarehouse.Archive.TGCplus_DS
  select DS.CustomerID,cast(Coalesce_DSDate as date)as DSDate,DS,datediff(d,MinDSDate,Coalesce_DSDate)DSDays, EntitlementDays,DS_Service_period_from,DS_Service_period_to,
  --,DS_MonthDiff
  DS_Month,DS_ValidDS,DS_Entitled,completed_at,billing_cycle_period_type,Type,pre_tax_amount,service_period_from,service_period_to,actual_service_period_to,subscription_plan_id,
  payment_handler,BillingRank,Refunded,RefundedAmount,Refunded_Completed_at,Changed_Service_period_to,Changed_Billing_cycle_period_type,Changed_Subscription_plan_id,
  Changed_Payment_handler,PAS_Cancelled_date,PAS_DeferredSuspension_date,PAS_Suspended_date,
  --Case when PAS_Cancelled_date between Coalesce_DSDate and Dateadd(d,7,Coalesce_DSDate) then 1 else 0 end Cancelled,
  --Case when PAS_Suspended_Date between Coalesce_DSDate and Dateadd(d,7,Coalesce_DSDate) then 1 else 0 end Suspended,
  --Case when PAS_DeferredSuspension_Date between Coalesce_DSDate and Dateadd(d,7,Coalesce_DSDate) then 1 else 0 end DeferredSuspension, /*changed to capture cancels and others*/
  Case when PAS_Cancelled_date between DS_Service_period_from and Dateadd(d,7,DS_Service_period_to) then 1 else 0 end Cancelled,
  Case when PAS_Suspended_Date between DS_Service_period_from and Dateadd(d,7,DS_Service_period_to) then 1 else 0 end Suspended,
  Case when PAS_DeferredSuspension_Date between DS_Service_period_from and Dateadd(d,7,DS_Service_period_to) then 1 else 0 end DeferredSuspension,
  lag( billing_cycle_period_type, 1) over(partition by DS.customerid order by BillingRank )Prior_billing_cycle_period_type,
  lag( subscription_plan_id, 1) over(partition by DS.customerid order by BillingRank )Prior_subscription_plan_id,
  lag( payment_handler, 1) over(partition by DS.customerid order by BillingRank )Prior_payment_handler,
  Amount,NetAmount,DSSplits,PaidFlag,BillingDupes,	UBIssue, MinDS,MinDSDate,MaxDS,MaxDSDate,LTDAmount,LTDNetAmount,
  IntlDSbilling_cycle_period_type,IntlDSsubscription_plan_id,IntlDSpayment_handler,IntlDSAmount,IntlDSuso_offer_id,
  SubDSbilling_cycle_period_type,SubDSsubscription_plan_id,SubDSpayment_handler,SubDSAmount,SubDSuso_offer_id,
  Case when Coalesce_DSDate = MaxDSDate and DS is not null then 1 else 0 end as CurrentDS,uso_offer_id,uso_offer_code_applied,uso_applied_at,
  getdate() as DMLastupdated
  into Datawarehouse.Archive.TGCplus_DS
  from Datawarehouse.Staging.TGCplus_DS_Working DS
  Left join 
  (
	/*	  select distinct MinMax.*,
		  IntlDS.billing_cycle_period_type as IntlDSbilling_cycle_period_type,IntlDS.subscription_plan_id as IntlDSsubscription_plan_id,
		  IntlDS.payment_handler as IntlDSpayment_handler,IntlDS.pre_tax_amount as IntlDSAmount,IntlDS.uso_offer_id as IntlDSuso_offer_id,
		  SubDS.billing_cycle_period_type as SubDSbilling_cycle_period_type,SubDS.subscription_plan_id as SubDSsubscription_plan_id,
		  SubDS.payment_handler as SubDSpayment_handler,SubDS.pre_tax_amount as SubDSAmount,SubDS.uso_offer_id as SubDSuso_offer_id
		  from 
		  (select Customerid,min(DS)MinDS,cast(Min(DS_Service_period_from) as Date) MinDSDate,Max(DS)MaxDS,cast(Max(Coalesce_DSDate) as date)as MaxDSDate, Sum(Amount) As LTDAmount ,Sum(NetAmount) As LTDNetAmount 
		  from Datawarehouse.Staging.TGCplus_DS_Working
		  group by Customerid)MinMax
		  join Datawarehouse.Staging.TGCplus_DS_Working IntlDS
		  on MinMax.customerid = IntlDS.Customerid
		  and IntlDS.DS = MinDS --and IntlDS.EntitlementDays >0
		  join Datawarehouse.Staging.TGCplus_DS_Working SubDS
		  on MinMax.customerid = SubDS.Customerid
		  and SubDS.DS = MaxDS --and SubDS.EntitlementDays >0
		  */

 select   MinMax.Customerid, MinDS,  MinDSDate, MaxDS,  MaxDSDate,   LTDAmount ,  LTDNetAmount,
		  min(IntlDS.billing_cycle_period_type) as IntlDSbilling_cycle_period_type,min(IntlDS.subscription_plan_id) as IntlDSsubscription_plan_id,
		  min(IntlDS.payment_handler) as IntlDSpayment_handler,min(IntlDS.pre_tax_amount) as IntlDSAmount,min(IntlDS.uso_offer_id) as IntlDSuso_offer_id,
		  min(SubDS.billing_cycle_period_type) as SubDSbilling_cycle_period_type,min(SubDS.subscription_plan_id) as SubDSsubscription_plan_id,
		  min(SubDS.payment_handler) as SubDSpayment_handler,min(SubDS.pre_tax_amount) as SubDSAmount,min(SubDS.uso_offer_id) as SubDSuso_offer_id
		  from 
		  (select Customerid,min(DS)MinDS,cast(Min(DS_Service_period_from) as Date) MinDSDate,Max(DS)MaxDS,cast(Max(Coalesce_DSDate) as date)as MaxDSDate, Sum(Amount) As LTDAmount ,Sum(NetAmount) As LTDNetAmount 
		  from Datawarehouse.Staging.TGCplus_DS_Working
		  group by Customerid)MinMax
		  join Datawarehouse.Staging.TGCplus_DS_Working IntlDS
		  on MinMax.customerid = IntlDS.Customerid
		  and IntlDS.DS = MinDS --and IntlDS.EntitlementDays >0
		  join Datawarehouse.Staging.TGCplus_DS_Working SubDS
		  on MinMax.customerid = SubDS.Customerid
		  and SubDS.DS = MaxDS --and SubDS.EntitlementDays >0
		  group by MinMax.Customerid, MinDS,  MinDSDate, MaxDS,  MaxDSDate,   LTDAmount ,  LTDNetAmount

  ) DSMinMax on DS.CustomerID = DSMinMax.CustomerID
  --where DS.CustomerID in (1399220, 1216192,2342155,956855,1085427,1216137,1216192,1216406,1216469,1219363,1219423,1220932,1221129,1221171,956855,1216137,2376383  )
  order by 1,2

 
  --select * from  Datawarehouse.Archive.TGCplus_DS
  --where  CustomerID in (1399220, 1216192,2342155,956855,1085427,1216137,1216192,1216406,1216469,1219363,1219423,1220932,1221129,1221171,956855,1216137,2376383  )
  --order by 1,2


  
 -- select * from  Datawarehouse.Archive.TGCplus_DS
 -- where    DS_ValidDS =0
 -- order by 1,2
 -- select * from  Datawarehouse.Archive.TGCplus_DS
 -- where customerid = 1009276
 -- select * from  Datawarehouse.Archive.TGCplus_DS
 -- where customerid = 1216406

 --   select    *  
	--from  Datawarehouse.Archive.TGCplus_DS
	--where customerid = 1216406  
	--order by 3,4


	
update a
set	PAS_Cancelled_date = pas_created_at,
	Cancelled  = 1
from Archive.TGCPlus_DS a
left join archive.TGCPlus_paymentAuthorizationstatus b 
on a.customerid = b.pa_user_id and (b.pas_created_at between DS_Service_period_from and DS_Service_period_to or b.pas_created_at>DS_Service_period_to )
and a.payment_handler=b.pas_payment_handler and a.subscription_plan_id =  b.pas_plan_id
where CurrentDS = 1 --and DS = 0 
and Cancelled+Suspended+DeferredSuspension = 0
and Dateadd(d,7,DS_Service_period_to) < getdate()
and pas_state in ('Cancelled')
 


update a
set	PAS_Suspended_date = pas_created_at,
	Suspended  = 1
from Archive.TGCPlus_DS a
left join archive.TGCPlus_paymentAuthorizationstatus b 
on a.customerid = b.pa_user_id and (b.pas_created_at between DS_Service_period_from and DS_Service_period_to or b.pas_created_at>DS_Service_period_to )
and a.payment_handler=b.pas_payment_handler and a.subscription_plan_id =  b.pas_plan_id
where CurrentDS = 1 --and DS = 0 
and Cancelled+Suspended+DeferredSuspension = 0
and  Dateadd(d,7,DS_Service_period_to) < getdate()
and pas_state in ('suspended')

--Fix for people who come back afterwards and get a free trial again so have not paid yet and ltdamount = 0.
update a
set DS = Case when DS is null then null else 0 end
from Archive.TGCPlus_DS a
where isnull(ltdamount,0) = 0
and DS>0 

END








GO
