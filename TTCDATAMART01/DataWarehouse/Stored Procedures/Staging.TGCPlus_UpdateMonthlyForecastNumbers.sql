SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [Staging].[TGCPlus_UpdateMonthlyForecastNumbers]
	@AsOfDate Date = null
AS
-- Proc Name: 	datawarehouse.staging.TGCPlus_UpdateMonthlyForecastNumbers
-- Purpose:	This is a procedure used to update TGC Plus Customer counts for forecast
--
-- Input Parameters: @AsOfDate -- As of Date when the report needs to be updated.
--
		
-- Tables Used:  
-- UPDATEs:
-- Name		Date		Comments
-- Preethi Ramanujam 	10/23/2017	New
--

--- STEP 1: Declare and assign variables
DECLARE @AsOfDunningDate Date


begin
	set nocount on 

    --- If no date is provided, then use 1st of the current month
    IF @AsOfDate IS NULL
        select @AsOfDate = DATEADD(month, DATEDIFF(month, 0, getdate()), 0)
				,@AsOfDunningDate = case when day(getdate()) <= 6 then getdate()
										else Dateadd(day,6,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))
									end
	else 
		select @AsOfDate = DATEADD(month, DATEDIFF(month, 0, @AsOfDate), 0)
				,@AsOfDunningDate = Dateadd(day,6,DATEADD(month, DATEDIFF(month, 0, @AsOfDate), 0))
 

	Print 'AsOfDate = ' + Convert(varchar, @AsOfDate)
   
    --- Update the snapshot table for the @AsOfDate
	exec [Staging].[SP_Load_TGCPlus_CustomerSignature_Snapshot] @AsOfDate

	--- Update snapshot for registration
	exec [Staging].[SP_Load_TGCPlus_CustomerSignatureRegs_SnapShot] @AsOfDate

    --- Update the snapshot table for the @AsOfDunningDate
	exec [Staging].[SP_Load_TGCPlus_CustomerSignature_Snapshot] @AsOfDunningDate

	--- Force status to 'suspended' for those that go through dunning and got suspended
	
		update a
		set a.CustStatusFlag = b.CustStatusFlag
			,a.PaidFlag = b.PaidFlag
			,a.TransactionType = b.TransactionType
			,a.SubDate = dateadd(month,1,a.LastPaidDate)
		-- select ccd.Declinedcode, ccd.DeclinedDate, ccd.RetryStatus, b.TransactionType, b.CustStatusFlag, b.SubDate, b.PaidFlag, b.LastPaidAmt, b.LastPaidDate,a.*
		from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot a
		join
			(select *
			from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot 
			where asofdate = @AsOfDunningDate
			and CustStatusFlag = -1)b on a.customerid = b.CustomerID 
		join
			(select *
			from DataWarehouse.Archive.TGCPLus_CreditcardretryReport
			where RetryStatus = 'SUSPENDED'
			and DeclinedDate >= @AsOfDate) ccd on a.uuid = ccd.UserID
		where a.asofdate = @AsOfDate
		and a.PaidFlag = 1
		and a.LastPaidDate between dateadd(day,-7,EOMONTH(@AsOfDate, -2)) and EOMONTH(getdate(), -2)

		
		-- Load forecast numbers into temp table
		if object_id('Staging.TGCPlus_Actuals_ForForecastTEMP') is not null 
				drop table Staging.TGCPlus_Actuals_ForForecastTEMP

		select cast(DATEADD(mm, DATEDIFF(mm,0,IntlSubDate), 0) as date) as AsofDate,
			1 as AsOfDay,
			IntlSubMonth as AsOfMonth,
			IntlSubYear as AsOfYear,
			convert(varchar,IntlSubYear) + '_' + convert(varchar,IntlSubMonth) AsOfYrMonth,
			IntlSubDate, 
			IntlSubWeek,
			IntlSubMonth,
			IntlSubYear,
			convert(varchar,IntlSubYear) + '_' + convert(varchar,IntlSubMonth) IntlSubYrMonth,
			RegDate, 
			DataWarehouse.Staging.GetMonday(RegDate) as RegWeek,
			RegMonth,
			RegYear,
			convert(varchar,RegYear) + '_' + convert(varchar,RegMonth) RegYrMonth,
			CustomerID, IntlSubType, IntlSubPaymentHandler, 
			convert(varchar,b.billing_cycle_period_multiplier) + '_' +  b.billing_cycle_period_type as IntlSubType2,
			'Initial Subscription' as customerStatus,
			null FlagDefferedSuspends,
			null SubType, null SubPaymentHandler,
			null SubType2, 
			PaidFlag,
			0 as FlagFirstPaid,
			1 as CustFlag,
			'None' CancelTypes,
			case when IntlCampaignName like '%Beta%' then 'Beta'
				else 'NonBeta'
			end as FlagBeta
		into Staging.TGCPlus_Actuals_ForForecastTEMP
		from DataWarehouse.Marketing.TGCPlus_CustomerSignature a
			left join Archive.TGCPlus_SubscriptionPlan b on a.IntlSubPlanID = b.id
			--left join Archive.TGCPlus_SubscriptionPlan c on a.SubPlanID = c.id
		union
		select cast(dateadd(day,-1,AsofDate) as date) AsofDate, 
			day(dateadd(day,-1,AsofDate)) as AsOfDay,
			month(dateadd(day,-1,AsofDate)) as AsOfMonth,
			year(dateadd(day,-1,AsofDate)) as AsOfYear,
			convert(varchar,year(dateadd(day,-1,AsofDate))) + '_' + convert(varchar,month(dateadd(day,-1,AsofDate))) as AsOfYrMonth,
			IntlSubDate, 
			IntlSubWeek,
			IntlSubMonth,
			IntlSubYear, 
			convert(varchar,IntlSubYear) + '_' + convert(varchar,IntlSubMonth) IntlSubYrMonth,
			RegDate, 
			DataWarehouse.Staging.GetMonday(RegDate) as RegWeek,
			RegMonth,
			RegYear,
			convert(varchar,RegYear) + '_' + convert(varchar,RegMonth) RegYrMonth,
				CustomerID, IntlSubType, IntlSubPaymentHandler,
			convert(varchar,b.billing_cycle_period_multiplier) + '_' +  b.billing_cycle_period_type as IntlSubType2,
			case when TransactionType = 'Cancelled' then 'Cancelled'
				else 'Entitled'
			end as customerStatus,
			case when CustStatusFlag = 0 then 1
				else 0
			end as FlagDefferedSuspends,
			SubType, SubPaymentHandler,
			convert(varchar,c.billing_cycle_period_multiplier) + '_' +  c.billing_cycle_period_type as SubType2,
			PaidFlag,
			0 as FlagFirstPaid,
			case when TransactionType = 'Cancelled' then -1
				else 1
			end as CustFlag,
			case when DSMonthCancelled = 0 then 'FreeTrialCancels'
				when DSMonthCancelled > 0 then 'PaidCancels'
				else 'None'
			end as CancelTypes,
			case when IntlCampaignName like '%Beta%' then 'Beta'
			else 'NonBeta'
		end as FlagBeta
		from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot a
			left join Archive.TGCPlus_SubscriptionPlan b on a.IntlSubPlanID = b.id
			left join Archive.TGCPlus_SubscriptionPlan c on a.SubPlanID = c.id
		where DATEPART(DAY,AsofDate) = 1
		union
		select cast(dateadd(day,-1,AsofDate) as date) AsofDate, 
			day(dateadd(day,-1,AsofDate)) as AsOfDay,
			month(dateadd(day,-1,AsofDate)) as AsOfMonth,
			year(dateadd(day,-1,AsofDate)) as AsOfYear,
			convert(varchar,year(dateadd(day,-1,AsofDate))) + '_' + convert(varchar,month(dateadd(day,-1,AsofDate))) as AsOfYrMonth,
			IntlSubDate, 
			IntlSubWeek,
			IntlSubMonth,
			IntlSubYear, 
			convert(varchar,IntlSubYear) + '_' + convert(varchar,IntlSubMonth) IntlSubYrMonth,
			RegDate, 
			DataWarehouse.Staging.GetMonday(RegDate) as RegWeek,
			RegMonth,
			RegYear,
			convert(varchar,RegYear) + '_' + convert(varchar,RegMonth) RegYrMonth,
			CustomerID, IntlSubType, IntlSubPaymentHandler,
			convert(varchar,b.billing_cycle_period_multiplier) + '_' +  b.billing_cycle_period_type as IntlSubType2,
			'RegisteredOnly' as customerStatus,
			case when CustStatusFlag = 0 then 1
				else 0
			end as FlagDefferedSuspends,
			SubType, SubPaymentHandler,
			convert(varchar,c.billing_cycle_period_multiplier) + '_' +  c.billing_cycle_period_type as SubType2,
			PaidFlag,
			0 as FlagFirstPaid,
			null as CustFlag,
			'N/A' as CancelTypes,
			case when IntlCampaignName like '%Beta%' then 'Beta'
			else 'NonBeta'
		end as FlagBeta
		from DataWarehouse.Marketing.TGCPlus_CustomerSignatureRegs_Snapshot	a
			left join Archive.TGCPlus_SubscriptionPlan b on a.IntlSubPlanID = b.id
			left join Archive.TGCPlus_SubscriptionPlan c on a.SubPlanID = c.id
		where DATEPART(DAY,AsofDate) = 1
		order by AsofDate, IntlSubDate, CustomerID

		update a
		set a.FlagFirstPaid = 1
		from Staging.TGCPlus_Actuals_ForForecastTEMP a join
			(select CustomerID, min(asofdate) AsofDate
			from Staging.TGCPlus_Actuals_ForForecastTEMP
			where PaidFlag = 1
			and customerStatus <> 'Initial Subscription'
			group by CustomerID)b on a.CustomerID = b.CustomerID
							and a.AsofDate = b.AsofDate


		update Staging.TGCPlus_Actuals_ForForecastTEMP
		set IntlSubType2 = case when IntlSubType2 = '1_MONTH' then 'MONTH'
								when intlsubtype2 = '1_YEAR' then 'YEAR'
								else Intlsubtype2
								end,
			 SubType2 = case when SubType2 = '1_MONTH' then 'MONTH'
								when SubType2 = '1_YEAR' then 'YEAR'
								else SubType2
								end


	-- Reload the forecast table
	   if object_id('marketing.TGCPlus_Actuals_ForForecast') is not null 
				drop table marketing.TGCPlus_Actuals_ForForecast
    
		select *
		into Datawarehouse.marketing.TGCPlus_Actuals_ForForecast
		from Staging.TGCPlus_Actuals_ForForecastTEMP order by AsofDate


	-- Reload the forecast summary table
		 if object_id('marketing.TGCPlus_Actuals_ForForecastsmry') is not null 
				drop table marketing.TGCPlus_Actuals_ForForecastsmry
    

		select AsofDate, AsOfDay, AsOfMonth, AsOfYear,	AsOfYrMonth,
			IntlSubDate, IntlSubWeek, IntlSubMonth,	IntlSubYear, 	IntlSubYrMonth,
			RegDate, 	RegWeek,	RegMonth,	RegYear,	RegYrMonth,
			IntlSubType, IntlSubPaymentHandler, IntlSubType2,
			customerStatus,
			FlagDefferedSuspends,
			SubType, SubPaymentHandler, SubType2,
			PaidFlag,
			CustFlag,
			CancelTypes,
			FlagBeta,
			FlagFirstPaid,
			count(CustomerID) CustCount
		into Datawarehouse.marketing.TGCPlus_Actuals_ForForecastSmry
		from Datawarehouse.marketing.TGCPlus_Actuals_ForForecast
		group by AsofDate, 	AsOfDay,	AsOfMonth,	AsOfYear,	AsOfYrMonth,
			IntlSubDate, 	IntlSubWeek,	IntlSubMonth,	IntlSubYear, 	IntlSubYrMonth,
			RegDate, 	RegWeek,	RegMonth,	RegYear,	RegYrMonth,
			IntlSubType, IntlSubPaymentHandler, IntlSubType2,
			customerStatus,
			FlagDefferedSuspends,
			SubType, SubPaymentHandler, SubType2,
			PaidFlag,
			CustFlag,
			CancelTypes,
			FlagBeta,
			FlagFirstPaid

end
GO
