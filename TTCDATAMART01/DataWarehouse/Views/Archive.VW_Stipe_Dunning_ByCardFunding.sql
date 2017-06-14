SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE View [Archive].[VW_Stipe_Dunning_ByCardFunding]
as

--By CreditFunding
select AllStripetransactions.*,DistinctUserUUID_StripeSuccess,DistinctUserUUID_StripeFailures,DistinctUserUUID_StripeFailuresInDunning,DistinctUserUUID_StripeFailuresDunningSuccess from 
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
where CardTrials > 1   or status = 'paid'
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
--where AllStripetransactions.CardFunding = 'credit'
--order by 1,2
GO
