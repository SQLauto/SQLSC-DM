SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE View [Archive].[Vw_TGCplus_Android_Weekly]
as
select cast(OrderWeekStart as date)OrderWeekStart,Dateadd(d,6,cast(OrderWeekStart as date))OrderWeekEnd,'Monthly' as planType
, count(distinct Case when FinancialStatus = 'Charged' then  OrderNumber else null end)    PaidCustomerCounts
, -1* count(distinct Case when FinancialStatus = 'Refund' then  OrderNumber else null end) RefundedCustomerCounts
, count(distinct Case when FinancialStatus = 'Charged' then  OrderNumber else null end) + -1 * count(distinct Case when FinancialStatus = 'Refund' then  OrderNumber else null end) NetCustomerCounts
from 
(
select Cast(OrderChargedDate as date) OrderDate,[Staging].[GetSunday](Cast(OrderChargedDate as date))OrderWeekStart, Dateadd(m,-1,Cast(OrderChargedDate as date)) as OrderDatePriorMonth
from Datawarehouse.Archive.Tgcplus_Android_Salesreport
where SKUID like '%Month%'
--and FinancialStatus = 'Charged'
and year(OrderChargedDate)>2016
group by Cast(OrderChargedDate as date)  ,[Staging].[GetSunday](Cast(OrderChargedDate as date)) , Dateadd(m,-1,Cast(OrderChargedDate as date))  
) A
left join 
(
select *
from Datawarehouse.Archive.Tgcplus_Android_Salesreport
where SKUID like '%Month%'
--and FinancialStatus = 'Charged'
)A2
on Cast(A2.OrderChargedDate as date) between OrderDatePriorMonth and OrderDate
group by OrderWeekStart

union

select cast(OrderWeekStart as date),Dateadd(d,6,cast(OrderWeekStart as date))OrderWeekEnd,'Yearly' as planType
, count(distinct Case when FinancialStatus = 'Charged' then  OrderNumber else null end)    PaidCustomerCounts
, -1* count(distinct Case when FinancialStatus = 'Refund' then  OrderNumber else null end) RefundedCustomerCounts
, count(distinct Case when FinancialStatus = 'Charged' then  OrderNumber else null end) + -1 * count(distinct Case when FinancialStatus = 'Refund' then  OrderNumber else null end) NetCustomerCounts
from 
(
select Cast(OrderChargedDate as date) OrderDate,[Staging].[GetSunday](Cast(OrderChargedDate as date))OrderWeekStart, Dateadd(year,-1,Cast(OrderChargedDate as date)) as OrderDatePriorYear
from Datawarehouse.Archive.Tgcplus_Android_Salesreport
where (SKUID like '%annual%' or   SKUID like '%year%')
--and FinancialStatus = 'Charged'
and year(OrderChargedDate)>2016
group by Cast(OrderChargedDate as date)  ,[Staging].[GetSunday](Cast(OrderChargedDate as date)) , Dateadd(year,-1,Cast(OrderChargedDate as date))  
) A
left join 
(
select *
from Datawarehouse.Archive.Tgcplus_Android_Salesreport
where (SKUID like '%annual%' or   SKUID like '%year%')
--and FinancialStatus = 'Charged'
)A2
on Cast(A2.OrderChargedDate as date) between OrderDatePriorYear and OrderDate
group by OrderWeekStart


GO
