SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE View [Archive].[Vw_TGCPlus_BetaUserSummary]
as
select 	year(a.joined) YearRegistered
	,month(a.joined) MonthRegistered
	,datawarehouse.Staging.GetMonday(a.joined) WeekRegistered
	,CAST(a.Joined as Date) DateRegistered
	,year(a.entitled_dt) YearSubscribed
	,month(a.entitled_dt) MonthSubscribed
	,datawarehouse.Staging.GetMonday(a.entitled_dt) WeekSubscribed
	,CAST(a.entitled_dt AS date) DateSubscribed
	,a.campaign
	,case when a.subscription_plan_id = 0 then 1 else 0 end as RegisteredOnly
	,a.subscription_plan_id
	,b.name as Subscription_Plan
	,b.visible
	,count( a.uuid) CustCount
from DataWarehouse.Archive.TGCPlus_User a left join
	DataWarehouse.Archive.TGCPlus_SubscriptionPlan b on a.subscription_plan_id = b.id
where a.joined >= '7/1/2015'
and a.email not like '%+%'
and a.email not like '%teachco%'	
and b.name like '%beta%'
group by 	year(a.joined) 
	,month(a.joined) 
	,datawarehouse.Staging.GetMonday(a.joined)
	,CAST(a.Joined as Date) 
	,year(a.entitled_dt) 
	,month(a.entitled_dt) 
	,datawarehouse.Staging.GetMonday(a.entitled_dt)
	,CAST(a.entitled_dt AS date)
	,a.campaign
	,case when a.subscription_plan_id = 0 then 1 else 0 end
	,a.subscription_plan_id
	,b.name
	,b.visible




GO
