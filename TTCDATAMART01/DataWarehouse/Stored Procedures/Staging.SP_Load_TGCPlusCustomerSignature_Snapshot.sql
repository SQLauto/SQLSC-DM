SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [Staging].[SP_Load_TGCPlusCustomerSignature_Snapshot] @SnapshotDate Date = null
as

Begin

--declare @SnapshotDate Date = null


If @SnapshotDate is null
Begin

set @SnapshotDate = DATEADD(month, DATEDIFF(month, 0, getdate()), 0)

End


/* Creates snapshot of TGCPLus Customers as of the @SnapshotDate*/
select @SnapshotDate


/********** Base Table without Pending records *****************/

	select distinct
	dateadd(day,0,convert(date,@SnapshotDate)) as AsofDate,
	a.pa_user_id as CustomerID,
	a.pas_id,						
	a.pas_plan_id as SubPlanID,						
	a.pas_state,
	a.pas_created_at, 	
	a.pas_payment_handler, 
	CONVERT(varchar(30),null) Prior_pas_state,
	CONVERT(varchar(30),null) Prior_pas_Plan_id,
	CONVERT(varchar(30),null) Prior_pas_payment_handler, 
	CONVERT(varchar(30),null) TransactionType,
	rank() over (partition by a.pa_user_id order by pas_created_at, pas_id) SeqNum
	into #TGCPlus_Customer						
	from DataWarehouse.Archive.TGCPlus_PaymentAuthorizationStatus a						
	where a.pas_state not in ('Pending')	
	and cast(a.pas_created_at as date) < @SnapshotDate


/********** Delete records that don't start with 'Completed' and re-rank *****************/

	Delete C 
	from #TGCPlus_Customer C
	inner join	(select min(SeqNum)SeqNum,Customerid from #TGCPlus_Customer
				where pas_state = 'Completed'
				group by Customerid) D
				on c.customerid = D.CustomerID and C.SeqNum<D.SeqNum

				 

	Update C1
	Set C1.SeqNum = C2.SeqNum
	from #TGCPlus_Customer C1
	inner join (select rank() over (partition by customerid order by pas_created_at, pas_id) as SeqNum,customerid,pas_created_at,pas_id 
				From #TGCPlus_Customer) C2
				on C1.CustomerID=C2.customerid and C1.pas_created_at = C2.pas_created_at and C1.pas_id = C2.pas_id
	inner join (select Customerid from #TGCPlus_Customer 
				group by Customerid 
				having min(seqNum)<>1)C3
				on C3.CustomerID = C1.CustomerID
	--140
	

/********** Delete customers where seq = 1 and pas_state Suspended or payment handler issue *****************/
	
	Delete from #TGCPlus_Customer  
	where  CustomerID in (select CustomerID from  #TGCPlus_Customer
						 where SeqNum=1 and pas_state<>'Completed')

/********** Update prior status and calculate type of transation *****************/
		update a
		set a.prior_pas_state = b.pas_state,
			a.prior_pas_plan_id = b.SubPlanID,
			a.prior_pas_payment_handler = b.pas_payment_handler
		from #TGCPlus_Customer	a 
		join #TGCPlus_Customer b 
		on a.CustomerID = b.CustomerID and a.SeqNum -1 = b.SeqNum 

		update a
		set a.TransactionType = 
		case when (SeqNum = 1 and pas_state='Completed') or (SeqNum=2 and pas_state='Completed' and Prior_pas_state='Suspended') then 'Initial Subscription'
		--when pas_state in ('Cancelled','Suspended','Deferred Suspension') then pas_state
		when Prior_pas_state = 'Completed' and pas_state in ('Cancelled','Suspended','Deferred Suspension') then pas_state
		--when Prior_pas_state = 'Completed' and Prior_pas_Plan_id = SubPlanID then 'Renew'
		when Prior_pas_state = 'Completed' and pas_state = 'Completed' and Prior_pas_Plan_id = SubPlanID and prior_pas_payment_handler=pas_payment_handler then 'Renew' 
		when Prior_pas_state = 'Completed' and pas_state = 'Completed' and Prior_pas_Plan_id = SubPlanID and prior_pas_payment_handler<>pas_payment_handler then 'PaymentChange'
		when Prior_pas_state = 'Completed' and pas_state = 'Completed' and Prior_pas_Plan_id <> SubPlanID then 'PlanChange'
		when Prior_pas_state in ('Deferred Suspension') and pas_state in ('Cancelled') then pas_state -- added on 10/26
		when Prior_pas_state in ('Cancelled','Suspended','Payment Handler Issue') and pas_state = 'Completed' and Prior_pas_Plan_id = SubPlanID then 'SamePlanReact'
		--when Prior_pas_state in ('Cancelled','Suspended') and Prior_pas_Plan_id = SubPlanID and prior_pas_payment_handler=pas_payment_handler then 'SamePlanReact'
		--when Prior_pas_state in ('Cancelled','Suspended') and Prior_pas_Plan_id = SubPlanID and prior_pas_payment_handler<>pas_payment_handler then 'PaymentChange'
		when Prior_pas_state in ('Cancelled','Suspended','Payment Handler Issue') and pas_state = 'Completed' and Prior_pas_Plan_id <> SubPlanID then 'DiffPlanReact'
		--when Prior_pas_state in ('Cancelled','Suspended') and Prior_pas_Plan_id <> SubPlanID and prior_pas_payment_handler=pas_payment_handler then 'DiffPlanReact'
		--when Prior_pas_state in ('Cancelled','Suspended') and Prior_pas_Plan_id <> SubPlanID and prior_pas_payment_handler<>pas_payment_handler then 'PaymentChange'
		else pas_state
		end
		from #TGCPlus_Customer	a

/********** Delete TransactionType ='PaymentChange' and redo previous steps *****************/


While exists (select * from #TGCPlus_Customer	where TransactionType ='PaymentChange')

Begin
		Delete from #TGCPlus_Customer
		where TransactionType ='PaymentChange'


		Update C1
		Set C1.SeqNum = C2.SeqNum
		from #TGCPlus_Customer C1
		inner join (select rank() over (partition by customerid order by pas_created_at, pas_id) as SeqNum,customerid,pas_created_at,pas_id 
					From #TGCPlus_Customer) C2
					on C1.CustomerID=C2.customerid and C1.pas_created_at = C2.pas_created_at and C1.pas_id = C2.pas_id

		update a
		set a.TransactionType = 
		case when (SeqNum = 1 and pas_state='Completed') or (SeqNum=2 and pas_state='Completed' and Prior_pas_state='Suspended') then 'Initial Subscription'
		--when pas_state in ('Cancelled','Suspended','Deferred Suspension') then pas_state
		when Prior_pas_state = 'Completed' and pas_state in ('Cancelled','Suspended','Deferred Suspension') then pas_state
		--when Prior_pas_state = 'Completed' and Prior_pas_Plan_id = SubPlanID then 'Renew'
		when Prior_pas_state = 'Completed' and pas_state = 'Completed' and Prior_pas_Plan_id = SubPlanID and prior_pas_payment_handler=pas_payment_handler then 'Renew' 
		when Prior_pas_state = 'Completed' and pas_state = 'Completed' and Prior_pas_Plan_id = SubPlanID and prior_pas_payment_handler<>pas_payment_handler then 'PaymentChange'
		when Prior_pas_state = 'Completed' and pas_state = 'Completed' and Prior_pas_Plan_id <> SubPlanID then 'PlanChange'
		when Prior_pas_state in ('Deferred Suspension') and pas_state in ('Cancelled') then pas_state -- added on 10/26
		when Prior_pas_state in ('Cancelled','Suspended','Payment Handler Issue') and pas_state = 'Completed' and Prior_pas_Plan_id = SubPlanID then 'SamePlanReact'
		--when Prior_pas_state in ('Cancelled','Suspended') and Prior_pas_Plan_id = SubPlanID and prior_pas_payment_handler=pas_payment_handler then 'SamePlanReact'
		--when Prior_pas_state in ('Cancelled','Suspended') and Prior_pas_Plan_id = SubPlanID and prior_pas_payment_handler<>pas_payment_handler then 'PaymentChange'
		when Prior_pas_state in ('Cancelled','Suspended','Payment Handler Issue') and pas_state = 'Completed' and Prior_pas_Plan_id <> SubPlanID then 'DiffPlanReact'
		--when Prior_pas_state in ('Cancelled','Suspended') and Prior_pas_Plan_id <> SubPlanID and prior_pas_payment_handler=pas_payment_handler then 'DiffPlanReact'
		--when Prior_pas_state in ('Cancelled','Suspended') and Prior_pas_Plan_id <> SubPlanID and prior_pas_payment_handler<>pas_payment_handler then 'PaymentChange'
		else pas_state
		end
		from #TGCPlus_Customer	a		

select * from #TGCPlus_Customer	
where TransactionType ='PaymentChange'

END
 
/************** Suspended where TransactionType='Payment Handler Issue' *****************/

update #TGCPlus_Customer set TransactionType='Suspended'
-- select * from #TGCPlus_Customer
where TransactionType='Payment Handler Issue'
--(322 row(s) affected)


/************** Add Cancel records to the Plan Change people *****************/
Insert into #TGCPlus_Customer 
	(AsofDate,CustomerID,pas_id,SubPlanID,pas_state,pas_created_at,pas_payment_handler,Prior_pas_state,Prior_pas_Plan_id,Prior_pas_payment_handler,TransactionType,SeqNum)
	select 
	a.AsofDate,
	a.CustomerID,
	a.pas_id,						
	a.SubPlanID,						
	a.pas_state,
	a.pas_created_at, 	
	a.pas_payment_handler, 
	a.pas_state as Prior_pas_state,
	a.SubPlanID as Prior_pas_Plan_id,
	a.pas_payment_handler as Prior_pas_payment_handler,
	'CancelOldPlan' as TransactionType,
	a.SeqNum+1 as SeqNum
	from #TGCPlus_Customer a
	join (select * from #TGCPlus_Customer where TransactionType='PlanChange') b
	on a.CustomerID=b.CustomerID and a.SeqNum=b.SeqNum-1


	--select * from #TGCPlus_Customer  where TransactionType = 'CancelOldPlan'


/************* Final Subscription Table *****************/


		select 	
		a.AsofDate,					
		a.CustomerID,
		b.uuid,
		b.email as EmailAddress,	
		b.TGCPluscampaign as IntlCampaignID,
		e.AdcodeName as IntlCampaignName,
		e.MD_Channel as IntlMDChannel,						
		CONVERT(date,b.entitled_dt) as IntlSubDate,	
		MONTH(b.entitled_dt) as IntlSubMonth,
		YEAR(b.entitled_dt) as IntlSubYear,	
		b.subscription_plan_id as IntlSubPlanID,
		f.name as IntlSubPlanName,
		f.billing_cycle_period_type as IntlSubType,
		a.SubPlanID,						
		d.name as SubPlanName,			
		d.billing_cycle_period_type as SubType,	
		a.pas_id,
		a.pas_created_at,					
		CONVERT(date,a.pas_created_at) as SubDate,
		MONTH(a.pas_created_at) as SubMonth,
		YEAR(a.pas_created_at) as SubYear,
		a.pas_payment_handler as SubPaymentHandler, 
		case when TransactionType in ('Cancelled','Suspended','CancelOldPlan') then 'Cancelled'
		when TransactionType in ('Initial Subscription') then 'Initial Subscription'
		when TransactionType in ('Renew') then 'Renew'
		--when TransactionType in ('SamePlanReact','DiffPlanReact') then 'React'
		when TransactionType in ('SamePlanReact') then 'SamePlanReact'
		when TransactionType in ('DiffPlanReact') then 'DiffPlanReact'
		when TransactionType in ('PlanChange') then 'PlanChange' 
		when TransactionType in ('Deferred Suspension') then 'Deferred Suspension'
		end as TransactionType,
		case when TransactionType in ('Initial Subscription','PlanChange','Renew','SamePlanReact','DiffPlanReact') then 1
		when TransactionType in ('Cancelled','Suspended','CancelOldPlan') then -1
		else 0 end CustStatusFlag,
		CONVERT(nvarchar(20),null) TGCCustomerID,
		CONVERT(int,null) as TGCCust,
		CONVERT(varchar(20),null) as TGCCustSegmentFcst,
		CONVERT(varchar(20),null) as TGCCustSegment,
		rank() over (partition by customerid order by pas_created_at, pas_id,a.SeqNum ) TransSeqNum,
		convert(date,b.joined) as RegDate,  -- PR 10/25/2016 added Registration Date to Signature Table
		MONTH(b.joined) as RegMonth,		-- PR 10/25/2016 added Registration Date to Signature Table
		YEAR(b.joined) as RegYear			-- PR 10/25/2016 added Registration Date to Signature Table
		into #TGCPlus_CustomerFinal						
		from #TGCPlus_Customer a						
		join DataWarehouse.Archive.TGCPlus_User b						
		on a.CustomerID=b.id 					
		join Archive.TGCPlus_SubscriptionPlan d						
		on a.SubPlanID=d.id	
		join DataWarehouse.Mapping.vwAdcodesAll e
		on b.TGCPluscampaign=e.AdCode
		join Archive.TGCPlus_SubscriptionPlan f						
		on b.subscription_plan_id=f.id	
		--where a.TransactionType not in ('Deferred Suspension')


	/*Update TGC Customerid with EPC Email Match*/
		update a
		set TGCCustomerID=b.CustomerID
		from #TGCPlus_CustomerFinal a
		join (select distinct Email, CustomerID
				from DataWarehouse.Marketing.epc_preference) b
		on a.EmailAddress=b.Email

	/*Update TGC Customerid segments with matched customerid*/
		update a
		set TGCCust=
		case when b.CustomerID is not null then 1
		else 0 end,
		TGCCustSegmentFcst=
		case when b.Name in ('18m1','18m2','18m3') then 'Active_Multi'
		else b.CustomerSegmentFnl end,
		TGCCustSegment=b.CustomerSegmentFnl
		from #TGCPlus_CustomerFinal a
		join DataWarehouse.Marketing.CampaignCustomerSignature b
		on a.TGCCustomerID=b.CustomerID
		--(8915 row(s) affected)


	/*Load to Final table*/

		select * into #TGCPlus_StatusHistory from Datawarehouse.Marketing.TGCPlus_StatusHistory 
		where 1= 0 

		insert into #TGCPlus_StatusHistory 
		select * from #TGCPlus_CustomerFinal 



		Select max(Asofdate)Asofdate,Count(*)Counts from #TGCPlus_StatusHistory


/********************************************************** Start CustomerSignature Snapshot **********************************************************/


	select
		AsofDate,
		CustomerID,
		uuid,
		EmailAddress,
		TGCCustomerID,
		IntlCampaignID,
		IntlCampaignName,
		IntlMDChannel,
		IntlSubDate,
		DataWarehouse.staging.getmonday(IntlSubDate) as IntlSubWeek,
		IntlSubMonth,
		IntlSubYear,
		IntlSubPlanID,
		IntlSubPlanName,
		IntlSubType,
		CONVERT(varchar(50), null) as IntlSubPaymentHandler, /*Initial payment handler*/
		CONVERT(date, null) as SubDate,
		CONVERT(date, null) as SubWeek,
		CONVERT(int, null) as SubMonth,
		CONVERT(int, null) as SubYear,
		CONVERT(int,null) as SubPlanID,
		CONVERT(varchar(100), null) as SubPlanName,
		CONVERT(varchar(20), null) as SubType,
		CONVERT(varchar(50), null) as SubPaymentHandler,
		CONVERT(varchar(50), null) as TransactionType,
		CONVERT(float, null) as CustStatusFlag,
		CONVERT(int,0) as PaidFlag,
		CONVERT(float,null) as LTDPaidAmt,
		CONVERT(date, null) as LastPaidDate,
		CONVERT(date, null) as LastPaidWeek,
		CONVERT(int, null) as LastPaidMonth,
		CONVERT(int, null) as LastPaidYear,
		CONVERT(float,null) as LastPaidAmt,
		CONVERT(int,null) DSDayCancelled,
		CONVERT(int,null) DSMonthCancelled,
		CONVERT(int,null) DSDayDeferred,
		CONVERT(int, null) as TGCCust,
		CONVERT(varchar(50),null) as TGCCustSegmentFcst,
		CONVERT(varchar(50),null) as TGCCustSegment,
		MAX(TransSeqNum) MaxSeqNum,
		RegDate, 		-- PR 10/25/2016 added Registration Date to Signature Table
		RegMonth,		-- PR 10/25/2016 added Registration Date to Signature Table
		RegYear			-- PR 10/25/2016 added Registration Date to Signature Table
		into #TGCPlus_CustomerDaily
		from #TGCPlus_StatusHistory
		group by
		AsofDate,
		CustomerID,
		uuid,
		EmailAddress,
		TGCCustomerID,
		IntlCampaignID,
		IntlCampaignName,
		IntlMDChannel,
		IntlSubDate,
		DataWarehouse.staging.getmonday(IntlSubDate),
		IntlSubMonth,
		IntlSubYear,
		IntlSubPlanID,
		IntlSubPlanName,
		IntlSubType,
		RegDate, 		-- PR 10/25/2016 added Registration Date to Signature Table
		RegMonth,		-- PR 10/25/2016 added Registration Date to Signature Table
		RegYear			-- PR 10/25/2016 added Registration Date to Signature Table
		--(18427 row(s) affected)

		update a
		set SubPlanID = b.SubPlanID,
			SubPlanName = b.SubPlanName,
			SubType = b.SubType,
			SubPaymentHandler = b.SubPaymentHandler,
			TransactionType = b.TransactionType,
			SubDate = b.SubDate,
			SubWeek=DataWarehouse.staging.getmonday(b.SubDate) ,
			SubMonth = b.SubMonth,
			SubYear = b.SubYear,
			CustStatusFlag = b.CustStatusFlag,
			TGCCust = b.TGCCust,
			TGCCustSegmentFcst = b.TGCCustSegmentFcst,
			TGCCustSegment = b.TGCCustSegment
			from DataWarehouse.#TGCPlus_CustomerDaily a
			join #TGCPlus_StatusHistory b
			on a.CustomerID=b.CustomerID and a.MaxSeqNum=b.TransSeqNum


/*Initial payment handler*/

Update CD
set IntlSubPaymentHandler = Cust.SubPaymentHandler
from DataWarehouse.#TGCPlus_CustomerDaily CD
left Join (select customerid,SubPaymentHandler 
			from #TGCPlus_StatusHistory
			where TransSeqNum = 1
			group by customerid,SubPaymentHandler )Cust
			On CD.CustomerID = Cust.CustomerID
 

/* Change beta users' initial subcription date to actual plan join date */

/*
		Update a 
		set IntlSubDate= SubDate,
			IntlSubWeek= DataWarehouse.staging.getmonday(SubDate),
			IntlSubMonth= MONTH(SubDate),
			IntlSubYear= YEAR(SubDate),
			IntlSubPlanID= SubPlanID,
			IntlSubPlanName= SubPlanName,
			IntlSubType= SubType
			from DataWarehouse.#TGCPlus_CustomerDaily a
			where IntlSubPlanName='Beta'
			and SubPlanID in (39,40,43,44,57,58,42,55,67,68) /* Added mapping table to filter planid's Mapping.Vw_TGCPlus_ValidSubscriptionPlan*/
*/
/* Changed after Julia's new code on 4/4/2016*/
			select CustomerID, TransSeqNum 
			into #Beta
			from #TGCPlus_StatusHistory
			where customerid in (select CustomerID from #TGCPlus_StatusHistory
			where IntlSubPlanName='Beta')
			and TransactionType in ('PlanChange','DiffPlanReact')

			select a.*
			into #Beta2
			from #TGCPlus_StatusHistory a
			join (select CustomerID, min(TransSeqNum) MinSeq
						  from #Beta
						  group by CustomerID) b
			on a.CustomerID=b.CustomerID and a.TransSeqNum=b.MinSeq

			update a 
			set IntlSubDate=b.SubDate,
				IntlSubWeek=DataWarehouse.staging.getmonday(b.SubDate),
				IntlSubMonth=MONTH(b.SubDate),
				IntlSubYear=YEAR(b.SubDate),
				IntlSubPlanID=b.SubPlanID,
			    IntlSubPlanName=b.SubPlanName,
			    IntlSubType=b.SubType
			-- select *
			from DataWarehouse.#TGCPlus_CustomerDaily a
			join  #Beta2 b
			on a.customerid=b.customerid
			join Mapping.Vw_TGCPlus_ValidSubscriptionPlan P
			on P.id =b.SubPlanID
			--where b.SubPlanID in (39,40,43,44,57,58,42,55,67,68,71) /* Added mapping table to filter planid's Mapping.Vw_TGCPlus_ValidSubscriptionPlan*/

--(326 row(s) affected)

/*Update Downstream dates for TransactionType 'Cancelled' */
		Update DataWarehouse.#TGCPlus_CustomerDaily 
		set  DSDayCancelled=DATEDIFF(d,IntlSubDate,SubDate),
			DSMonthCancelled=
			case when SubDate = IntlSubDate then 0
				 when DATEPART(D,dateadd(day,-1,SubDate)) >=DATEPART(D,IntlSubDate) 
				 THEN ( case when DATEPART(M,dateadd(day,-1,SubDate)) = DATEPART(M,IntlSubDate) AND DATEPART(YYYY,dateadd(day,-1,SubDate)) = DATEPART(YYYY,IntlSubDate) 
				 THEN 0 ELSE DATEDIFF(M,IntlSubDate,dateadd(day,-1,SubDate))END )
				 ELSE DATEDIFF(M,IntlSubDate,dateadd(day,-1,SubDate))-1 end
			where TransactionType in ('Cancelled')
		--(8387 row(s) affected)

/*Update DSDayDeferred dates for TransactionType 'Deferred Suspension' */
		Update DataWarehouse.#TGCPlus_CustomerDaily 
		set DSDayDeferred=DATEDIFF(d,IntlSubDate,SubDate)
		where TransactionType in ('Deferred Suspension')
		--(397 row(s) affected)


/*Calculate PreTax amounts for refund and Payments*/
		Select	user_id,
				billing_cycle_period_type,
				service_period_from,
				service_period_to,
				subscription_plan_id,
				sum(case	when type='REFUND' then pre_tax_amount*-1
						when type='PAYMENT' then pre_tax_amount
						end) as pre_tax_amount,
				sum(case	when type='REFUND' then tax_amount*-1
						when type='PAYMENT' then tax_amount
						end) as tax_amount,
				sum(case when type='REFUND' then payment_handler_fee*-1
						when type='PAYMENT' then payment_handler_fee
						end) as payment_handler_fee
		into #TGCPlus_Billing
		from DataWarehouse.Archive.TGCPlus_UserBilling
	--	where completed_at < @SnapshotDate			--- PR 11/30/2016 see if this fixes late billing issues if we rerun the snapshots
		where service_period_from < @SnapshotDate
		group by user_id,billing_cycle_period_type,
		service_period_from,service_period_to,
		subscription_plan_id


/* Update LTD Payment Amt  if pre_tax_amount > $10*/
		Update t1
		set LTDPaidAmt=t2.LTDPaidAmt
		-- select *
		from Datawarehouse.#TGCPlus_CustomerDaily t1
		join (select a.user_id, sum(pre_tax_amount) LTDPaidAmt 
				from #TGCPlus_Billing a
				where a.pre_tax_amount>8 -- change LTDPaidAmt from >10 to >8, because we charge $9.99 for partners
				group by a.user_id) t2
		on t1.CustomerID=t2.user_id


/* Update Paid flag if not cancelled and paid amount >$10 */
		Update Datawarehouse.#TGCPlus_CustomerDaily 
		set PaidFlag=1
		where LTDPaidAmt >8 and PaidFlag=0 -- change LTDPaidAmt from >10 to >8, because we charge $9.99 for partners
		and TransactionType not in ('Cancelled')


/* Cancel Yearly Subscribers who received full refund, set CustStatusFlag = -1 and TransactionType='Cancelled' */
		Update Datawarehouse.#TGCPlus_CustomerDaily  
		set TransactionType='Cancelled',
			CustStatusFlag=-1
		where CustomerID in (select CustomerID from Datawarehouse.#TGCPlus_CustomerDaily 
									where TransactionType not in ('Cancelled') and PaidFlag=0 and SubType='Year'
									and SubPaymentHandler <> 'ROKU'  /* Added this code 8/9/2016 for ROKU Annual Customers whos billing is not showing up Email from Julia*/
									group by CustomerID)


/* Update DS for SubType ='Year' and TransactionType = 'Cancelled' */
		Update Datawarehouse.#TGCPlus_CustomerDaily 
		Set DSDayCancelled=DATEDIFF(d,IntlSubDate,SubDate),
			DSMonthCancelled= case when SubDate = IntlSubDate 
								   then 0
								   when DATEPART(D,dateadd(day,-1,SubDate)) >=DATEPART(D,IntlSubDate) 
								   THEN ( case when DATEPART(M,dateadd(day,-1,SubDate)) = DATEPART(M,IntlSubDate) AND DATEPART(YYYY,dateadd(day,-1,SubDate)) = DATEPART(YYYY,IntlSubDate) 
											   THEN 0 
											   ELSE DATEDIFF(M,IntlSubDate,dateadd(day,-1,SubDate))
											   END )
								  ELSE DATEDIFF(M,IntlSubDate,dateadd(day,-1,SubDate))-1 end
		where TransactionType in ('Cancelled')
		and SubType='Year'



/* Most recent paid date and paid amount*/

		Select a.user_id, a.service_period_from, a.pre_tax_amount 
		into #TGCPlus_BillingLast
		from #TGCPlus_Billing a
		join (select user_id, max(service_period_from) as MaxPaidDate 
						from #TGCPlus_Billing
						where pre_tax_amount>8 -- add pre_tax_amount filter
						group by user_id) b
		on a.user_id=b.user_id and a.service_period_from=b.MaxPaidDate
		where a.pre_tax_amount>8          --change pre_tax_amount from >10 to >8, because we charge $9.99 for partners	



/* Update Most recent paid date and paid amounts*/
		Update t1
		set LastPaidDate = convert(date, t2.service_period_from),
		LastPaidWeek = DataWarehouse.staging.getmonday(t2.service_period_from),
		LastPaidMonth = month(t2.service_period_from),
		LastPaidYear = year(t2.service_period_from),
		LastPaidAmt = t2.pre_tax_amount
		from DataWarehouse.#TGCPlus_CustomerDaily t1
		join #TGCPlus_BillingLast t2
		on t1.CustomerID=t2.user_id

/*Check users who have paid flag =1 and last paid dates is null*/
		Select * from DataWarehouse.Archive.TGCPlus_UserBilling
		where user_id in (select distinct customerid from DataWarehouse.#TGCPlus_CustomerDaily 	where PaidFlag=1 and LastPaidDate is null)
		--and completed_at < @SnapshotDate  --- PR 11/30/2016 see if this fixes late billing issues if we rerun the snapshots
		and service_period_from < @SnapshotDate 
		order by user_id, completed_at		


/* Set Paidflag=0 for those who got free month again when they switched between Roku and Web*/
		Update DataWarehouse.#TGCPlus_CustomerDaily set PaidFlag=0
		where PaidFlag=1 and LastPaidDate is null



/*Daily Data*/
		select a.*
		from DataWarehouse.#TGCPlus_CustomerDaily a
		join Mapping.Vw_TGCPlus_ValidSubscriptionPlan P
		on P.id =a.SubPlanID
		where IntlSubDate between '9/28/2015' and '3/12/2016'
		--and a.SubPlanID in (39,40,43,44,57,58,42,55,67,68,71) /* Added mapping table to filter planid's Mapping.Vw_TGCPlus_ValidSubscriptionPlan*/
		and a.EmailAddress not like '%+%'
		and a.EmailAddress not like '%plustest%' 
		and IntlMDChannel not like '%OfficeDepot%'
		order by CustomerID, IntlSubDate 
		

/* Truncate and load TGCPlus_CustomerSignature_Snapshot*/

 Delete from  Datawarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot
 where AsofDate = @SnapshotDate

		Insert into Datawarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot
		select 
				AsofDate,
				a.CustomerID,
				a.uuid,
				a.EmailAddress,
				a.TGCCustomerID,
				convert(varchar(10),'US') CountryCode,
				a.IntlCampaignID,
				a.IntlCampaignName,
				b.MD_Country as IntlMD_Country,
				b.MD_Audience as IntlMD_Audience,
				a.IntlMDChannel as IntlMD_Channel,
				b.ChannelID as IntlMD_ChannelID,
				b.MD_PromotionType as IntlMD_PromotionType,
				b.MD_PromotionTypeID as IntlMD_PromotionTypeID,
				b.MD_Year as IntlMD_Year,
				a.IntlSubDate,
				a.IntlSubWeek,
				a.IntlSubMonth,
				a.IntlSubYear,
				a.IntlSubPlanID,
				a.IntlSubPlanName,
				a.IntlSubType,
				a.IntlSubPaymentHandler,
				a.SubDate,
				a.SubWeek,
				a.SubMonth,
				a.SubYear,
				a.SubPlanID,
				a.SubPlanName,
				a.SubType,
				a.SubPaymentHandler,
				a.TransactionType,
				a.CustStatusFlag,
				a.PaidFlag,
				a.LTDPaidAmt,
				a.LastPaidDate,
				a.LastPaidWeek,
				a.LastPaidMonth,
				a.LastPaidYear,
				a.LastPaidAmt,
				a.DSDayCancelled,
				a.DSMonthCancelled,
				a.DSDayDeferred,
				a.TGCCust as TGCCustFlag,
				a.TGCCustSegmentFcst as TGCCustSegmentFcst,
				a.TGCCustSegment as TGCCustSegmentFnl,
				a.MaxSeqNum,
				O.FirstName,
				O.LastName,
				Isnull(left(O.Gender,1), 'U') as Gender,
				DATEDIFF(month,O.DateOfBirth,getdate())/12 as Age,
				CASE WHEN (DATEDIFF(month,O.DateOfBirth,getdate())/12) <= 34  then '1: < 35'
					 WHEN (DATEDIFF(month,O.DateOfBirth,getdate())/12) between 35 and 44 then '2: 35-44'
					 WHEN (DATEDIFF(month,O.DateOfBirth,getdate())/12) between 45 and 54 then '3: 45-54'
					 WHEN (DATEDIFF(month,O.DateOfBirth,getdate())/12) between 55 and 64 then '4: 55-64'
					 WHEN (DATEDIFF(month,O.DateOfBirth,getdate())/12) between 65 and 74 then '5: 65-74'
					 WHEN (DATEDIFF(month,O.DateOfBirth,getdate())/12) >= 75 then '6: >= 75'
					 When O.Customerid is not null and O.DateOfBirth  is NULL then '7: No Overlay Available' 
					 ELSE '8: Unknown'
                   END as AgeBin, 
				Case when O.IncomeDescription in ('1: $0-$14,999','2: $15,000 - $19,999',
                                                            '3: $20,000 - $29,999','4: $30,000 - $39,999',
                                                            '5: $40,000 - $49,999')
                                            then '1: < $50,000'
					when O.IncomeDescription in ('6: $50,000 - $74,999') 
											then '2: $50,000 - $74,999'
					when O.IncomeDescription in ('7: $75,000 - $99,999') 
											then '3: $75,000 - $99,999'
					when O.IncomeDescription in ('8: $100,000 - $124,999','9: $125,000 - $149,999') 
                                            then '4: $100,000 - $149,999'
					when O.IncomeDescription in ('10: $150,000 - $174,999','11: $175,000 - $199,999','12: $200,000 - $249,000',
                                                            '13: $250,000+') 
                                            then '5: >= $150,000'
					When O.Customerid is not null then  '6: No Overlay Available'
					else '7: Unknown'
				  End HouseHoldIncomeBin,
				Case  when Education in ('3: Some College')  then '2: Some College'
					when Education in ('4: College')            then '3: College'          
                    when Education in ('5: Graduate School') then '4: Graduate Degree'
                    when Education in ('1: Some High School or Less','2: High School') then '1: High School or Less'
                    when O.Customerid is not null then '5: No Overlay Available'
					else '6: Unknown'
				  End EducationBin,
				Ad.line1 as address1,
				Ad.line2 as address2,
				Ad.line3 as address3,
				Ad.city as city,
				Ad.region as State,
				Ad.country as Country,
				cast(Ad.postalCode as varchar(20))as ZipCode,
				a.RegDate,		-- PR 10/25/2016 added Registration Date to Signature Table
				a.RegMonth,		-- PR 10/25/2016 added Registration Date to Signature Table
				a.RegYear,		-- PR 10/25/2016 added Registration Date to Signature Table
				getdate()
 
		from DataWarehouse.#TGCPlus_CustomerDaily a
		left join DataWarehouse.mapping.vwadcodesall b
		on a.IntlCampaignID=b.adcode
		left join DataWarehouse.Archive.TGCPlus_BillingAddress Ad
		on ad.userId = a.UUId
		left Join DataWarehouse.Mapping.TGCPlus_CustomerOverlay O
		on O.CustomerID = A.CustomerID
		join Mapping.Vw_TGCPlus_ValidSubscriptionPlan P
		on P.id =a.SubPlanID
		where a.IntlSubDate >= '9/28/2015'
		--and a.SubPlanID in (39,40,43,44,57,58,42,55,67,68,71) /* Added mapping table to filter planid's Mapping.Vw_TGCPlus_ValidSubscriptionPlan*/
		and a.EmailAddress not like '%+%'
		and a.EmailAddress not like '%plustest%' 
		and a.IntlMDChannel not like '%OfficeDepot%'
		order by a.CustomerID, a.IntlSubDate 

/* Country update to include Country names from datawarehouse.Mapping.TGCPLusCountry vikram 9/20/2016*/

	 Update C
	 set c.country = Coalesce(m.Country,m1.Country,'ROW') 
	 from Datawarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot c
	 left join datawarehouse.Mapping.TGCPLusCountry m
	 on m.Country = c.country
	 left join datawarehouse.Mapping.TGCPLusCountry m1
	 on m1.Alpha2Code = c.country
	 where AsofDate = dateadd(day,0,convert(date,@SnapshotDate))


End

GO
