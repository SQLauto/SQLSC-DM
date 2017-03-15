SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [Staging].[SP_Load_TGCplus_StatusHistory]
as

Begin


Declare @DMLastUpdateESTDateTime Datetime


select @DMLastUpdateESTDateTime = isnull(Max(DMLastUpdateESTDateTime),getdate()) from DataWarehouse.Archive.TGCPlus_PaymentAuthorizationStatus

select @DMLastUpdateESTDateTime

/********** Base Table without Pending records *****************/

If OBJECT_ID('Staging.TGCPlus_Customer') is not null
drop table Datawarehouse.Staging.TGCPlus_Customer

	select distinct
	dateadd(day,-1,convert(date,@DMLastUpdateESTDateTime)) as AsofDate,
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
	into Datawarehouse.staging.TGCPlus_Customer						
	from DataWarehouse.Archive.TGCPlus_PaymentAuthorizationStatus a						
	where a.pas_state not in ('Pending')	
	--(34877 row(s) affected)

/********** Delete records that don't start with 'Completed' and re-rank *****************/

	Delete C 
	from Datawarehouse.staging.TGCPlus_Customer C
	inner join	(select min(SeqNum)SeqNum,Customerid from Datawarehouse.staging.TGCPlus_Customer
				where pas_state = 'Completed'
				group by Customerid) D
				on c.customerid = D.CustomerID and C.SeqNum<D.SeqNum
	--127
				 

	Update C1
	Set C1.SeqNum = C2.SeqNum
	from Datawarehouse.staging.TGCPlus_Customer C1
	inner join (select rank() over (partition by customerid order by pas_created_at, pas_id) as SeqNum,customerid,pas_created_at,pas_id 
				From Datawarehouse.staging.TGCPlus_Customer) C2
				on C1.CustomerID=C2.customerid and C1.pas_created_at = C2.pas_created_at and C1.pas_id = C2.pas_id
	inner join (select Customerid from Datawarehouse.staging.TGCPlus_Customer 
				group by Customerid 
				having min(seqNum)<>1)C3
				on C3.CustomerID = C1.CustomerID
	--140
	

/********** Delete customers where seq = 1 and pas_state Suspended or payment handler issue *****************/
	
	Delete from Datawarehouse.staging.TGCPlus_Customer  
	where  CustomerID in (select CustomerID from  Datawarehouse.staging.TGCPlus_Customer
						 where SeqNum=1 and pas_state<>'Completed')

/********** Update prior status and calculate type of transation *****************/
		update a
		set a.prior_pas_state = b.pas_state,
			a.prior_pas_plan_id = b.SubPlanID,
			a.prior_pas_payment_handler = b.pas_payment_handler
		from Datawarehouse.staging.TGCPlus_Customer	a 
		join Datawarehouse.staging.TGCPlus_Customer b 
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
		from Datawarehouse.staging.TGCPlus_Customer	a

/********** Delete TransactionType ='PaymentChange' and redo previous steps *****************/


While exists (select * from Datawarehouse.staging.TGCPlus_Customer	where TransactionType ='PaymentChange')

Begin
		Delete from Datawarehouse.staging.TGCPlus_Customer
		where TransactionType ='PaymentChange'


		Update C1
		Set C1.SeqNum = C2.SeqNum
		from Datawarehouse.staging.TGCPlus_Customer C1
		inner join (select rank() over (partition by customerid order by pas_created_at, pas_id) as SeqNum,customerid,pas_created_at,pas_id 
					From Datawarehouse.staging.TGCPlus_Customer) C2
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
		from Datawarehouse.staging.TGCPlus_Customer	a		

select * from Datawarehouse.staging.TGCPlus_Customer	
where TransactionType ='PaymentChange'

END
 
/************** Suspended where TransactionType='Payment Handler Issue' *****************/

update Datawarehouse.staging.TGCPlus_Customer set TransactionType='Suspended'
-- select * from Datawarehouse.staging.TGCPlus_Customer
where TransactionType='Payment Handler Issue'
--(322 row(s) affected)


/************** Add Cancel records to the Plan Change people *****************/
Insert into Datawarehouse.staging.TGCPlus_Customer 
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
	from Datawarehouse.staging.TGCPlus_Customer a
	join (select * from Datawarehouse.staging.TGCPlus_Customer where TransactionType='PlanChange') b
	on a.CustomerID=b.CustomerID and a.SeqNum=b.SeqNum-1


	--select * from Datawarehouse.staging.TGCPlus_Customer  where TransactionType = 'CancelOldPlan'


/************* Final Subscription Table *****************/

If OBJECT_ID('Staging.TGCPlus_CustomerFinal') is not null
drop table Datawarehouse.Staging.TGCPlus_CustomerFinal

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
		into Datawarehouse.Staging.TGCPlus_CustomerFinal						
		from Datawarehouse.staging.TGCPlus_Customer a						
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
		from Datawarehouse.Staging.TGCPlus_CustomerFinal a
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
		from Datawarehouse.Staging.TGCPlus_CustomerFinal a
		join DataWarehouse.Marketing.CampaignCustomerSignature b
		on a.TGCCustomerID=b.CustomerID
		--(8915 row(s) affected)


	/*Load to Final table*/

		Begin
		Truncate table Datawarehouse.Marketing.TGCPlus_StatusHistory 

		insert into Datawarehouse.Marketing.TGCPlus_StatusHistory 
		select * from Datawarehouse.Staging.TGCPlus_CustomerFinal 
		END

		Select max(Asofdate)Asofdate,Count(*)Counts from Datawarehouse.Marketing.TGCPlus_StatusHistory

END
GO
