SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE Proc [Staging].[SP_Load_TGCPlus_CustomerSignature]
as

Begin


/***************** Subscribers Daily Table *************************/

If object_id ('staging.TGCPlus_CustomerDaily') is not null
drop table staging.TGCPlus_CustomerDaily

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
		into staging.TGCPlus_CustomerDaily
		from DataWarehouse.Marketing.TGCPlus_StatusHistory
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
			from DataWarehouse.Staging.TGCPlus_CustomerDaily a
			join DataWarehouse.Marketing.TGCPlus_StatusHistory b
			on a.CustomerID=b.CustomerID and a.MaxSeqNum=b.TransSeqNum


/*Initial payment handler*/

Update CD
set IntlSubPaymentHandler = Cust.SubPaymentHandler
from DataWarehouse.Staging.TGCPlus_CustomerDaily CD
left Join (select customerid,SubPaymentHandler 
			from DataWarehouse.Marketing.TGCPlus_StatusHistory
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
			from DataWarehouse.Staging.TGCPlus_CustomerDaily a
			where IntlSubPlanName='Beta'
			and SubPlanID in (39,40,43,44,57,58,42,55,67,68) /* Added mapping table to filter planid's Mapping.Vw_TGCPlus_ValidSubscriptionPlan*/
*/

/* Changed after Julia's new code on 4/4/2016*/
			select CustomerID, TransSeqNum 
			into #Beta
			from DataWarehouse.Marketing.TGCPlus_StatusHistory
			where customerid in (select CustomerID from DataWarehouse.Marketing.TGCPlus_StatusHistory
			where IntlSubPlanName='Beta')
			and TransactionType in ('PlanChange','DiffPlanReact')

			select a.*
			into #Beta2
			from DataWarehouse.Marketing.TGCPlus_StatusHistory a
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
			from DataWarehouse.Staging.TGCPlus_CustomerDaily a
			join  #Beta2 b
			on a.customerid=b.customerid
			join Mapping.Vw_TGCPlus_ValidSubscriptionPlan P
			on P.id =b.SubPlanID
			--where b.SubPlanID in (39,40,43,44,57,58,42,55,67,68,71) /* Added mapping table to filter planid's Mapping.Vw_TGCPlus_ValidSubscriptionPlan*/

--(326 row(s) affected)

/*Update Downstream dates for TransactionType 'Cancelled' */
		Update DataWarehouse.Staging.TGCPlus_CustomerDaily 
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
		Update DataWarehouse.Staging.TGCPlus_CustomerDaily 
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
		group by user_id,billing_cycle_period_type,
		service_period_from,service_period_to,
		subscription_plan_id


/* Update LTD Payment Amt  if pre_tax_amount > $10*/
		Update t1
		set LTDPaidAmt=t2.LTDPaidAmt
		-- select *
		from Datawarehouse.staging.TGCPlus_CustomerDaily t1
		join (select a.user_id, sum(pre_tax_amount) LTDPaidAmt 
				from #TGCPlus_Billing a
				where a.pre_tax_amount>8 -- change LTDPaidAmt from >10 to >8, because we charge $9.99 for partners
				group by a.user_id) t2
		on t1.CustomerID=t2.user_id


/* Update Paid flag if not cancelled and paid amount >$10 */
		Update Datawarehouse.staging.TGCPlus_CustomerDaily 
		set PaidFlag=1
		where LTDPaidAmt >8 and PaidFlag=0 -- change LTDPaidAmt from >10 to >8, because we charge $9.99 for partners
		and TransactionType not in ('Cancelled')


/* Cancel Yearly Subscribers who received full refund, set CustStatusFlag = -1 and TransactionType='Cancelled' */
		Update Datawarehouse.staging.TGCPlus_CustomerDaily  
		set TransactionType='Cancelled',
			CustStatusFlag=-1
		where CustomerID in (select CustomerID from Datawarehouse.staging.TGCPlus_CustomerDaily 
									where TransactionType not in ('Cancelled') and PaidFlag=0 and SubType='Year'
									and SubPaymentHandler <> 'ROKU'  /* Added this code 8/9/2016 for ROKU Annual Customers whos billing is not showing up Email from Julia*/
									group by CustomerID)


/* Update DS for SubType ='Year' and TransactionType = 'Cancelled' */
		Update Datawarehouse.staging.TGCPlus_CustomerDaily 
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
		from DataWarehouse.Staging.TGCPlus_CustomerDaily t1
		join #TGCPlus_BillingLast t2
		on t1.CustomerID=t2.user_id

/*Check users who have paid flag =1 and last paid dates is null*/
		Select * from DataWarehouse.Archive.TGCPlus_UserBilling
		where user_id in (select distinct customerid from DataWarehouse.Staging.TGCPlus_CustomerDaily 
		where PaidFlag=1 and LastPaidDate is null)
		order by user_id, completed_at		


/* Set Paidflag=0 for those who got free month again when they switched between Roku and Web*/
		Update DataWarehouse.staging.TGCPlus_CustomerDaily set PaidFlag=0
		where PaidFlag=1 and LastPaidDate is null



/*Daily Data*/
		select a.*
		from DataWarehouse.staging.TGCPlus_CustomerDaily a
		join Mapping.Vw_TGCPlus_ValidSubscriptionPlan P
		on P.id =a.SubPlanID
		where IntlSubDate between '9/28/2015' and '3/12/2016'
		--and a.SubPlanID in (39,40,43,44,57,58,42,55,67,68,71) /* Added mapping table to filter planid's Mapping.Vw_TGCPlus_ValidSubscriptionPlan*/
		and a.EmailAddress not like '%+%'
		and a.EmailAddress not like '%plustest%' 
		and IntlMDChannel not like '%OfficeDepot%'
		order by CustomerID, IntlSubDate 
		

/* Truncate and load TGCPlus_CustomerSignature*/
	Begin 
		Truncate table Datawarehouse.Marketing.TGCPlus_CustomerSignature

		Insert into Datawarehouse.Marketing.TGCPlus_CustomerSignature
		select Distinct
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
				a.RegYear		-- PR 10/25/2016 added Registration Date to Signature Table
		from DataWarehouse.staging.TGCPlus_CustomerDaily a
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
	 from  Datawarehouse.Marketing.TGCPlus_CustomerSignature c
	 left join datawarehouse.Mapping.TGCPLusCountry m
	 on m.Country = c.country
	 left join datawarehouse.Mapping.TGCPLusCountry m1
	 on m1.Alpha2Code = c.country

	End


-- Update registered only customers	  -- PR 11/2/2016
exec Staging.SP_Load_TGCPlus_CustomerSignatureRegs


Declare @SQL nvarchar(1000), @Date Varchar(10) = CONVERT(varchar,  GETDATE(), 112)

If DATEPART(d,getdate()) = 1
/* Create SnapShot*/
Begin 

set @SQL = '
			if object_id (''archive.TGCPlus_CustomerSignature'+ @Date + ''') is null
			select * into archive.TGCPlus_CustomerSignature' + @Date + ' from Marketing.TGCPlus_CustomerSignature'
exec (@SQL)

set @SQL = '
			if object_id (''archive.TGCPlus_CustomerSignature'+ @Date + ''') is null
			select * into archive.TGCPlus_CustomerSignature' + @Date + ' from Marketing.TGCPlus_CustomerSignatureRegs'  -- PR 11/2/2016
exec (@SQL)


End

If datepart(WEEKDAY,getdate()) = 1
/* Create Weekly SnapShot*/
Begin 
	insert into Archive.TGCPlus_CustomerSignature_Wkly
	select * 
	from Marketing.TGCPlus_CustomerSignature

	insert into Archive.TGCPlus_CustomerSignature_Wkly		-- PR 11/2/2016
	select * 
	from Marketing.TGCPlus_CustomerSignatureRegs
End

Drop table #Beta
Drop table #Beta2

END
 



GO
