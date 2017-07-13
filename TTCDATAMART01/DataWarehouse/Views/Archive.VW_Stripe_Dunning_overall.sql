SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE View [Archive].[VW_Stripe_Dunning_overall]
as

/*
--Overall
select AllStripetransactions.CreatedYear,	AllStripetransactions.CreatedMonth	
,sum(DistinctUserUUID_AllStripetransactions)DistinctUserUUID_AllStripetransactions
,sum(DistinctUserUUID_StripeSuccess) DistinctUserUUID_StripeSuccess
,sum(DistinctUserUUID_StripeFailures) DistinctUserUUID_StripeFailures
,sum(DistinctUserUUID_StripeFailuresInDunning) DistinctUserUUID_StripeFailuresInDunning
,sum(DistinctUserUUID_StripeFailuresDunningSuccess )DistinctUserUUID_StripeFailuresDunningSuccess
from 
(select year(created)CreatedYear, month(created)CreatedMonth,CardFunding, count(distinct userId_metadata) as DistinctUserUUID_AllStripetransactions 
from Archive.Stripe_AllTransactions_Report
group by  year(created) , month(created),CardFunding ) AllStripetransactions

left join (select year(created)CreatedYear, month(created)CreatedMonth,CardFunding , count(distinct userId_metadata) as DistinctUserUUID_StripeSuccess 
from Archive.Stripe_Success_Report
group by  year(created) , month(created),CardFunding  ) StripeSuccess
on AllStripetransactions.CreatedYear = StripeSuccess.CreatedYear 
and AllStripetransactions.CreatedMonth = StripeSuccess.CreatedMonth
and AllStripetransactions.CardFunding = StripeSuccess.CardFunding

left join (select year(created)CreatedYear, month(created)CreatedMonth,CardFunding , count(distinct userId_metadata) as DistinctUserUUID_StripeFailures 
from Archive.Stripe_Failures_Report
group by  year(created) , month(created),CardFunding  )StripeFailures 
on AllStripetransactions.CreatedYear = StripeFailures.CreatedYear 
and AllStripetransactions.CreatedMonth = StripeFailures.CreatedMonth
and AllStripetransactions.CardFunding = StripeFailures.CardFunding

left join (select year(created)CreatedYear, month(created)CreatedMonth,CardFunding , count(distinct userId_metadata) as DistinctUserUUID_StripeFailuresInDunning 
from Archive.Stripe_Failures_Report   
where CardTrials > 1   or Status = 'Paid'
group by  year(created) , month(created),CardFunding  ) StripeFailuresInDunning 
on AllStripetransactions.CreatedYear = StripeFailuresInDunning.CreatedYear 
and AllStripetransactions.CreatedMonth = StripeFailuresInDunning.CreatedMonth
and AllStripetransactions.CardFunding = StripeFailuresInDunning.CardFunding

left join (select year(created)CreatedYear, month(created)CreatedMonth,CardFunding , count(distinct userId_metadata) as DistinctUserUUID_StripeFailuresDunningSuccess 
from Archive.Stripe_Failures_Report   
where status = 'paid'  
group by  year(created) , month(created),CardFunding  )StripeFailuresDunningSuccess  
on AllStripetransactions.CreatedYear = StripeFailuresDunningSuccess.CreatedYear 
and AllStripetransactions.CreatedMonth = StripeFailuresDunningSuccess.CreatedMonth
and AllStripetransactions.CardFunding = StripeFailuresDunningSuccess.CardFunding
group by AllStripetransactions.CreatedYear,	AllStripetransactions.CreatedMonth	
--order by 1,2

*/ 

--Overall
select AllStripetransactions.CreatedYear,	AllStripetransactions.CreatedMonth, AllStripetransactions.subtype, AllStripetransactions.IntlSubPlanID, AllStripetransactions.IntlMD_Channel, 	AllStripetransactions.IntlMD_Country
,sum(DistinctUserUUID_AllStripetransactions)DistinctUserUUID_AllStripetransactions
,sum(DistinctUserUUID_StripeSuccess) DistinctUserUUID_StripeSuccess
,sum(DistinctUserUUID_StripeFailures) DistinctUserUUID_StripeFailures
,sum(DistinctUserUUID_StripeFailuresInDunning) DistinctUserUUID_StripeFailuresInDunning
,sum(DistinctUserUUID_StripeFailuresDunningSuccess )DistinctUserUUID_StripeFailuresDunningSuccess
from 
(select year(created)CreatedYear, month(created)CreatedMonth,CardFunding, c.subtype,c.IntlSubPlanID,c.IntlMD_Channel,c.IntlMD_Country, count(distinct userId_metadata) as DistinctUserUUID_AllStripetransactions 
from Archive.Stripe_AllTransactions_Report R
join Datawarehouse.marketing.TGCPLus_Customersignature c
on c.uuid = r.userId_metadata   
group by  year(created) , month(created),CardFunding, c.subtype,c.IntlSubPlanID,c.IntlMD_Channel,c.IntlMD_Country ) AllStripetransactions

left join (select year(created)CreatedYear, month(created)CreatedMonth,CardFunding, c.subtype,c.IntlSubPlanID,c.IntlMD_Channel,c.IntlMD_Country , count(distinct userId_metadata) as DistinctUserUUID_StripeSuccess 
from Archive.Stripe_Success_Report R
join Datawarehouse.marketing.TGCPLus_Customersignature c
on c.uuid = r.userId_metadata   
group by  year(created) , month(created),CardFunding, c.subtype,c.IntlSubPlanID,c.IntlMD_Channel,c.IntlMD_Country  ) StripeSuccess
on AllStripetransactions.CreatedYear = StripeSuccess.CreatedYear 
and AllStripetransactions.CreatedMonth = StripeSuccess.CreatedMonth
and AllStripetransactions.CardFunding = StripeSuccess.CardFunding
and AllStripetransactions.subtype = StripeSuccess.subtype
and AllStripetransactions.IntlSubPlanID = StripeSuccess.IntlSubPlanID
and AllStripetransactions.IntlMD_Channel = StripeSuccess.IntlMD_Channel
and AllStripetransactions.IntlMD_Country = StripeSuccess.IntlMD_Country

left join (select year(created)CreatedYear, month(created)CreatedMonth,CardFunding, c.subtype,c.IntlSubPlanID,c.IntlMD_Channel,c.IntlMD_Country , count(distinct userId_metadata) as DistinctUserUUID_StripeFailures 
from Archive.Stripe_Failures_Report R
join Datawarehouse.marketing.TGCPLus_Customersignature c
on c.uuid = r.userId_metadata   
group by  year(created) , month(created),CardFunding , c.subtype,c.IntlSubPlanID,c.IntlMD_Channel,c.IntlMD_Country )StripeFailures 
on AllStripetransactions.CreatedYear = StripeFailures.CreatedYear 
and AllStripetransactions.CreatedMonth = StripeFailures.CreatedMonth
and AllStripetransactions.CardFunding = StripeFailures.CardFunding
and AllStripetransactions.subtype = StripeFailures.subtype
and AllStripetransactions.IntlSubPlanID = StripeFailures.IntlSubPlanID
and AllStripetransactions.IntlMD_Channel = StripeFailures.IntlMD_Channel
and AllStripetransactions.IntlMD_Country = StripeFailures.IntlMD_Country

left join (select year(created)CreatedYear, month(created)CreatedMonth,CardFunding, c.subtype,c.IntlSubPlanID,c.IntlMD_Channel,c.IntlMD_Country , count(distinct userId_metadata) as DistinctUserUUID_StripeFailuresInDunning 
from Archive.Stripe_Failures_Report R
join Datawarehouse.marketing.TGCPLus_Customersignature c
on c.uuid = r.userId_metadata      
where CardTrials > 1   or Status = 'Paid'
group by  year(created) , month(created),CardFunding , c.subtype,c.IntlSubPlanID,c.IntlMD_Channel,c.IntlMD_Country ) StripeFailuresInDunning 
on AllStripetransactions.CreatedYear = StripeFailuresInDunning.CreatedYear 
and AllStripetransactions.CreatedMonth = StripeFailuresInDunning.CreatedMonth
and AllStripetransactions.CardFunding = StripeFailuresInDunning.CardFunding
and AllStripetransactions.subtype = StripeFailuresInDunning.subtype
and AllStripetransactions.IntlSubPlanID = StripeFailuresInDunning.IntlSubPlanID
and AllStripetransactions.IntlMD_Channel = StripeFailuresInDunning.IntlMD_Channel
and AllStripetransactions.IntlMD_Country = StripeFailuresInDunning.IntlMD_Country

left join (select year(created)CreatedYear, month(created)CreatedMonth,CardFunding , c.subtype,c.IntlSubPlanID,c.IntlMD_Channel,c.IntlMD_Country, count(distinct userId_metadata) as DistinctUserUUID_StripeFailuresDunningSuccess 
from Archive.Stripe_Failures_Report R
join Datawarehouse.marketing.TGCPLus_Customersignature c
on c.uuid = r.userId_metadata      
where status = 'paid'  
group by  year(created) , month(created),CardFunding, c.subtype,c.IntlSubPlanID,c.IntlMD_Channel,c.IntlMD_Country  )StripeFailuresDunningSuccess  
on AllStripetransactions.CreatedYear = StripeFailuresDunningSuccess.CreatedYear 
and AllStripetransactions.CreatedMonth = StripeFailuresDunningSuccess.CreatedMonth
and AllStripetransactions.CardFunding = StripeFailuresDunningSuccess.CardFunding
and AllStripetransactions.subtype = StripeFailuresDunningSuccess.subtype
and AllStripetransactions.IntlSubPlanID = StripeFailuresDunningSuccess.IntlSubPlanID
and AllStripetransactions.IntlMD_Channel = StripeFailuresDunningSuccess.IntlMD_Channel
and AllStripetransactions.IntlMD_Country = StripeFailuresDunningSuccess.IntlMD_Country

group by AllStripetransactions.CreatedYear,	AllStripetransactions.CreatedMonth, AllStripetransactions.subtype, AllStripetransactions.IntlSubPlanID, AllStripetransactions.IntlMD_Channel, 	AllStripetransactions.IntlMD_Country
--order by 1,2



GO
