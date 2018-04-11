SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [Archive].[vw_Plus_MonthyPaidSubs_CountsTEST] as

	-- Get Stripe, Roku and Amazon Payment customers
	Select AsofDate
		,AsOfMonth
		,AsOfYear
		,AsOfYrMonth
		,SubPaymentHandler
		,SubType
		,SubType2
		,LastPaidYrMonth, LastPaidAmt
		,sum(CustCount) Customers
	from Marketing.TGCPlus_Actuals_ForForecastSmryTEST
	where CustomerStatus = 'Entitled' 
	and SubPaymentHandler in ('Roku','Stripe','Amazon Payments') 
	and PaidFlag = 1
	group by AsofDate
		,AsOfMonth
		,AsOfYear
		,AsOfYrMonth
		,SubPaymentHandler
		,SubType
		,SubType2
		,LastPaidYrMonth,LastPaidAmt
	union all
	-- Get iOS numbers
	Select ReportDate as AsOfDate
		,month(ReportDate) as AsOfMonth
		,Year(ReportDate) as AsOfYear
		,convert(varchar,Year(ReportDate)) + '_' + convert(varchar, month(ReportDate)) as AsOfYrMonth
		,'iOS' as SubPaymentHandler
		,case when SubscriptionDuration = '1 Year' then 'YEAR' else 'MONTH' end as SubType
		,case when SubscriptionDuration = '1 Year' then 'YEAR' else 'MONTH' end as SubType2
		,null LastPaidYrMonth, null LastPaidAmt
		,sum(ActiveSubscriptions) Customers 
	from archive.tgcplus_ios_report (nolock)
	where ReportDate in (Select distinct DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, ReportDate) + 1, 0)) 
							from archive.tgcplus_ios_report (nolock))
	group by ReportDate
		,month(ReportDate)
		,convert(varchar,Year(ReportDate)) + '_' + convert(varchar, month(ReportDate))
		,case when SubscriptionDuration = '1 Year' then 'YEAR' else 'MONTH' end 
		,case when SubscriptionDuration = '1 Year' then 'YEAR' else 'MONTH' end 
	union all
	-- Get Android Numbers
	select cast(DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, TransactionDate) + 1, 0)) as date) ReportDate
		,month(TransactionDate) as AsOfMonth
		,Year(TransactionDate) as AsofYear
		,convert(varchar,Year(TransactionDate)) + '_' + convert(varchar,month(TransactionDate)) as AsOfYrMonth
		   ,'Android' as SubPaymentHandler
		   ,case when ProductTitle like '%Annual%'  then 'YEAR' else 'MONTH' end as SubType
		   ,case when ProductTitle like '%Annual%'  then 'YEAR' else 'MONTH' end as SubType2
		,null LastPaidYrMonth, null LastPaidAmt
		   ,sum(case when TransactionType = 'Charge' then 1 else -1 end ) PaidCustomers
	--     ,sum(case when TransactionType = 'Charge refund' then 1 else 0 end) RefundCustomers
	from archive.Tgcplus_Android_PlayApps (nolock)
	where TransactionType in ('Charge refund','Charge')
	group by cast(DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, TransactionDate) + 1, 0)) as date)
			,month(TransactionDate)
			,Year(TransactionDate)
			,convert(varchar,Year(TransactionDate)) + '_' + convert(varchar,month(TransactionDate))
			,case when ProductTitle like '%Annual%' then 'YEAR' else 'MONTH' end
			,case when ProductTitle like '%Annual%' then 'YEAR' else 'MONTH' end
	-- Get ROKU numbers from Portal
	union all
	select 
		b.AsOfDate as ReportDate
		,month(b.AsOfDate) as AsOfMonth
		,Year(b.AsOfDate) as AsOfYear
		,convert(varchar,Year(b.AsOfDate)) + '_' + convert(varchar, month(b.AsOfDate)) as AsOfYrMonth
		,'Roku Portal' As SubPaymentHandler
		,case when a.product_code like '%annual%'  then 'YEAR' 
			when a.product_code like '%MONTH%' then 'MONTH' 
			ELSE 'Other'
		end as SubType
		,case when a.product_code like '%annual%'  then 'YEAR' 
			when a.product_code like '%MONTH%' then 'MONTH' 
			ELSE 'Other'
		end as SubType2
		,null LastPaidYrMonth, null LastPaidAmt
		,sum(case when transaction_type = 'Purchase' and amount > 0 then 1 
			when transaction_type = 'reversal' then -1
		else 0 end) PaidCustomers
	from DataWarehouse.Archive.TGCPLus_Roku_transactions a 
		join (select cast(a.date as date) as AsOfDate
				from MarketingCubes..DimDate a 
				join (select YEAR, month, max(day) MaxDay
					from MarketingCubes..DimDate
					where date between '9/28/2015' and getdate()
					group by Year, Month)b on a.Year = b.Year
										and a.Month = b.Month
										and a.Day = b.MaxDay)b on a.event_date < b.asofdate
															and a.expiration_date >= b.AsOfDate
	group by b.AsOfDate
		,month(b.AsOfDate)
		,Year(b.AsOfDate)
		,convert(varchar,Year(b.AsOfDate)) + '_' + convert(varchar, month(b.AsOfDate))
		,case when a.product_code like '%annual%'  then 'YEAR' 
			when a.product_code like '%MONTH%' then 'MONTH' 
			else 'Other'
		end
		,case when a.product_code like '%annual%'  then 'YEAR' 
			when a.product_code like '%MONTH%' then 'MONTH' 
			else 'Other'
		end
		,Year(b.AsOfDate)







GO
