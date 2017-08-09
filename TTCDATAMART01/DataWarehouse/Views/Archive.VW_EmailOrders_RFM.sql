SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[VW_EmailOrders_RFM] as

-- Main Customer Query
Select Customer.*, 
Campaign.CustomerSegment, Campaign.CustomerSegmentFnl, Campaign.Frequency as CustomerFreq, Campaign.CustomerSince, Campaign.LastOrderDate, 
Campaign.Gender, Campaign.AgeBin, Campaign.EducationBin, Campaign.HouseholdIncomeBin,
R.Recency, F.Frequency, M.Monetary
from
(
Select
CustomerID,
count(*) as Sends, 
sum(isnull(OpenCnt,0)) as OpenCnt,
sum(isnull(ClickCnt,0)) ClickCnt,
sum(isnull(NetOrderAmount,0)) as NetOrderAmount
FROM archive.emailorders (nolock)
where datediff(d, GETDATE(), (cast(StartDate as Date))) <= 90
GROUP BY CUSTOMERID
) as Customer
	left join
(
select 
CustomerID, CustomerSegment, CustomerSegmentFnl, Frequency, CustomerSince, LastOrderDate, 
Gender, AgeBin, EducationBin, HouseholdIncomeBin
from marketing.CampaignCustomerSignature (nolock) 
) Campaign on Customer.CustomerID = Campaign.CustomerID
	left join
(
-- Recency
Select
CustomerID, 
 NTILE(10) OVER(Order by OpenDate) + 1
as Recency

from
(
SELECT 
CustomerID,
max(cast(OpenDateStamp as Date)) OpenDate
FROM archive.emailorders (nolock)
where datediff(d, GETDATE(), (cast(StartDate as Date))) <= 90 
group by CustomerID 
) as agg
where OpenDate is not null
union all
    Select
CustomerID, 
1
as Recency
from
(
SELECT 
CustomerID,
max(cast(OpenDateStamp as Date)) OpenDate
FROM archive.emailorders (nolock)
where datediff(d, GETDATE(), (cast(StartDate as Date))) <= 90 
group by CustomerID 
) as agg
where OpenDate is NULL
) as R on Customer.CustomerID = R.CustomerID
	left join
(
Select
CustomerID, NTILE(10) OVER(Order by ClickCnt) + 1 as Frequency
from
(
SELECT 
CustomerID,
sum(isnull(ClickCnt,0)) ClickCnt
FROM archive.emailorders (nolock)
where datediff(d, GETDATE(), (cast(StartDate as Date))) <= 90 
group by CustomerID 
) as agg
where ClickCnt > 0
union all
Select
CustomerID, 1 as Frequency
from
(
SELECT 
CustomerID,
sum(isnull(ClickCnt,0)) ClickCnt
FROM archive.emailorders (nolock)
where datediff(d, GETDATE(), (cast(StartDate as Date))) <= 90 
group by CustomerID 
having sum(isnull(ClickCnt,0)) = 0
) as agg
) as F on Customer.CustomerID = F.CustomerID
	left join
(
Select
CustomerID, NTILE(10) OVER(Order by MonetaryRatio) + 1 as Monetary
from
(
Select CustomerID, sum(isnull(NetOrderAmount,0)) NetOrderAmount, count(*) Sends, (sum(isnull(NetOrderAmount,0))/count(*)) MonetaryRatio
from archive.emailorders (nolock)
where datediff(d, GETDATE(), (cast(StartDate as Date))) <= 90 
group by CustomerID 
having sum(isnull(NetOrderAmount,0)) > 0
) as agg

union all
Select
CustomerID, 1 as Monetary
from
(
SELECT 
CustomerID, sum(isnull(NetOrderAmount,0)) NetOrderAmount, count(*) Sends, (sum(isnull(NetOrderAmount,0))/count(*)) MonetaryRatio
FROM archive.emailorders (nolock)
where datediff(d, GETDATE(), (cast(StartDate as Date))) <= 90 
group by CustomerID 
having sum(isnull(NetOrderAmount,0)) = 0
) as agg
) as M on Customer.CustomerID = M.CustomerID;
GO
