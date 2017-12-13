SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [Staging].[SP_Load_tgc_upsell_RECC_AM_SEG]
as
Begin

/****************************Create base table for Active Multi's*********************************/


--Active Multi
select t1.*
into #base
from
(select distinct CustomerID,
FirstName,
Gender,
PreferredCategory2,
DateOfBirth,
MediaFormatPreference,
OrderSourcePreference,
FlagEmail,
FlagMail,
EmailAddress
from DataWarehouse.marketing.CampaignCustomerSignature a
where NewSeg in (3,4,5,8,9,10)
and comboid not like '%highschool%') t1
join
(select distinct CustomerID from
DataWarehouse.Marketing.DMPurchaseOrders
where BillingCountryCode in ('US','USA')
--and convert(date,DateOrdered) < '6/29/2017'
) t2 on
t1.CustomerID=t2.CustomerID
--(329400 row(s) affected)

--Intl Purchase
--drop table #IntlPurchase
select t1.CustomerID,
t2.DateOrdered IntlDateOrdered 
into #IntlPurchase
from #base t1
join
DataWarehouse.Marketing.DMPurchaseOrders t2 on
t1.CustomerID=t2.CustomerID
and t2.SequenceNum=1
--and convert(date,t2.DateOrdered) < '6/29/2017'


--Last Purchase
--drop table #LastPurchase
select t1.CustomerID,
t3.DateOrdered LastDateOrdered,
t3.CustomerSegmentFnlPrior CustomerSegmentFnlPrior
into #LastPurchase
from
#base t1
join
(select CustomerID, max(SequenceNum) as SequenceNumMax 
 from DataWarehouse.Marketing.DMPurchaseOrders
where BillingCountryCode in ('US','USA')
--and convert(date,DateOrdered) < '6/29/2017'
group by CustomerID) t2
on t1.CustomerID=t2.CustomerID
join
DataWarehouse.Marketing.DMPurchaseOrders t3 on
t1.CustomerID=t3.CustomerID and t2.SequenceNumMax=t3.SequenceNum


--Purchase in past 12 months
--drop table #Seg12m1
select t1.CustomerID,
count(*) Seg12mOrders,
sum(NetOrderAmount) Seg12mSales
into #Seg12m1
from
#base t1
join
(select CustomerID,NetOrderAmount
from DataWarehouse.Marketing.DMPurchaseOrders
where BillingCountryCode in ('US','USA')
and convert(date,DateOrdered) between dateadd(year,-1,getdate()) and getdate()) t2
on t1.CustomerID=t2.CustomerID
group by t1.CustomerID


--drop table #Seg12m2
select t1.CustomerID,
count(*) Seg12mEmailOrders,
sum(NetOrderAmount) Seg12mEmailSales
into #Seg12m2
from
#base t1
join
(select CustomerID,NetOrderAmount
from DataWarehouse.Marketing.DMPurchaseOrders
where BillingCountryCode in ('US','USA')
and convert(date,DateOrdered) between  dateadd(year,-1,getdate()) and getdate()
and FlagEmailOrder=1) t2
on t1.CustomerID=t2.CustomerID
group by t1.CustomerID


--Purchase in past 60 months
--drop table #Seg60m1
select t1.CustomerID,
count(*) Seg60mOrders,
sum(NetOrderAmount) Seg60mSales
into #Seg60m1
from
#base t1
join
(select CustomerID,NetOrderAmount
from DataWarehouse.Marketing.DMPurchaseOrders
where BillingCountryCode in ('US','USA')
and convert(date,DateOrdered) between dateadd(year,-5,getdate()) and getdate()) t2
on t1.CustomerID=t2.CustomerID
group by t1.CustomerID


--drop table #Seg60m2
select t1.CustomerID,
count(*) Seg60mEmailOrders,
sum(NetOrderAmount) Seg60mEmailSales
into #Seg60m2
from
#base t1
join
(select CustomerID,NetOrderAmount
from DataWarehouse.Marketing.DMPurchaseOrders
where BillingCountryCode in ('US','USA')
and convert(date,DateOrdered) between dateadd(year,-5,getdate()) and getdate()
and FlagEmailOrder=1) t2
on t1.CustomerID=t2.CustomerID
group by t1.CustomerID


--Total Purchase
-- drop table #LTDPurchases
select t1.CustomerID,
count(*) LTDOrders,
sum(NetOrderAmount) LTDSales
into #LTDPurchases
from
#base t1
join
(select CustomerID,NetOrderAmount
from DataWarehouse.Marketing.DMPurchaseOrders
where BillingCountryCode in ('US','USA')
--and convert(date,DateOrdered) < '6/29/2017'
) t2
on t1.CustomerID=t2.CustomerID
group by t1.CustomerID


-- Email Click Information in the past 3 months
-- drop table #EmailTemp
select a.CustomerID,
       b.datestamp,
       b.ttype
       into #EmailTemp
       from #base a
       left outer join
       LstMgr.dbo.SM_TRACKING_LOG b on
       datestamp between dateadd(month, -3, getdate()) and getdate()
       and a.EmailAddress is not null
       and upper(a.EmailAddress) = upper(b.Email)


-- drop table #EmailHistoryTmp
select t1.CustomerID, count(*) EmailReceived
       into #EmailHistoryTmp
       from #base t1
       left outer join
       DataWarehouse.Archive.EmailHistory t2 on
       t1.CustomerID=t2.CustomerID
       and StartDate between dateadd(month, -3, getdate()) and getdate()
       group by t1.CustomerID



-- drop table #EmailClick
select CustomerID,
       count(*) ClickCnt
       into #EmailClick
       from #EmailTemp
       where DateStamp is not null
       and ttype='click'
       group by CustomerID



-- drop table #final
select t1.*,
t2.IntlDateOrdered,
t3.LastDateOrdered,
t3.CustomerSegmentFnlPrior,
t4.Seg12mOrders,
t4.Seg12mSales,
t5.Seg12mEmailOrders,
t5.Seg12mEmailSales,
t6.Seg60mOrders,
t6.Seg60mSales,
t7.Seg60mEmailOrders,
t7.Seg60mEmailSales,
t8.ClickCnt, 
t10.EmailReceived,
t11.LTDOrders
into #final
from 
#base t1
left outer join
#IntlPurchase t2 on
t1.CustomerID=t2.CustomerID
left outer join
#LastPurchase t3 on
t1.CustomerID=t3.CustomerID
left outer join
#Seg12m1 t4 on
t1.CustomerID=t4.CustomerID
left outer join
#Seg12m2 t5 on
t1.CustomerID=t5.CustomerID
left outer join
#Seg60m1 t6 on
t1.CustomerID=t6.CustomerID
left outer join
#Seg60m2 t7 on
t1.CustomerID=t7.CustomerID
left outer join
#EmailClick t8 on
t1.CustomerID=t8.CustomerID
left outer join
#EmailHistoryTmp t10 on
t1.CustomerID=t10.CustomerID
left outer join
#LTDPurchases t11 on
t1.CustomerID=t11.CustomerID



update t1 
set t1.Gender = (case when (t1.Gender not in ('F','M')) then t2.Gender else t1.Gender end),
Seg12mOrders = (case when Seg12mOrders is null then 0 else Seg12mOrders end),
Seg12mSales = (case when Seg12mSales is null then 0 else Seg12mSales end),
Seg12mEmailOrders = (case when Seg12mEmailOrders is null then 0 else Seg12mEmailOrders end),
Seg60mOrders = (case when Seg60mOrders is null then 0 else Seg60mOrders end),
Seg60mSales = (case when Seg60mSales is null then 0 else Seg60mSales end),
Seg60mEmailOrders = (case when Seg60mEmailOrders is null then 0 else Seg60mEmailOrders end),
ClickCnt = (case when ClickCnt is null then 0 else ClickCnt end) 
from
#final t1
left outer join
DataWarehouse.Mapping.GENDER_LOOKUP t2 on
upper(t1.FirstName)=upper(t2.FirstName)


If object_id ('Datawarehouse.staging.tgc_upsell_RECC_AM_SEG') is not null
drop table Datawarehouse.staging.tgc_upsell_RECC_AM_SEG

select CustomerID,
(case when Gender is not null then Gender else 'U' end) Gender,
MediaFormatPreference,
OrderSourcePreference,
PreferredCategory2,
CustomerSegmentFnlPrior,
FlagEmail,
FlagMail,
convert(int, round(datediff(day,DateOfBirth,getdate())/365.25-0.5,0)) age,
datediff(month, LastDateOrdered, getdate()) RecencyMonths,
datediff(month, IntlDateOrdered, getdate()) TenureMonths,
Seg12mOrders,
Seg12mSales,
(case when Seg12mOrders=0 then 0 else Seg12mEmailOrders*1.0/Seg12mOrders end) Seg12mEmailOrderRatio,
Seg60mOrders,
Seg60mSales,
(case when Seg60mOrders=0 then 0 else Seg60mEmailOrders*1.0/Seg60mOrders end) Seg60mEmailOrderRatio,
(case when EmailReceived=0 then 0 else ClickCnt*1.0/EmailReceived end) ClickRatio,
round((datediff(month, IntlDateOrdered, getdate())-datediff(month, LastDateOrdered, getdate()))*1.0/LTDOrders,1) TTB
,cast(null as varchar(20))Segment 
,getdate() as DMlastupdated
into Datawarehouse.staging.tgc_upsell_RECC_AM_SEG

--into testsummary.dbo.JXU_RECC_AM_SEG_20170629_DEL
from #final



update Datawarehouse.staging.tgc_upsell_RECC_AM_SEG
set ClickRatio = (case when ClickRatio>1 then 1 else ClickRatio end),
OrderSourcePreference=(case when OrderSourcePreference not in ('P','W','M') then 'X' else OrderSourcePreference end),
MediaFormatPreference=(case when MediaFormatPreference not in ('C','D','DL','DV') then 'X' else MediaFormatPreference end),
CustomerSegmentFnlPrior=(case when CustomerSegmentFnlPrior not in ('Active_Multi','Inactive_Multi') then 'Else' else CustomerSegmentFnlPrior end)




--alter table Datawarehouse.staging.tgc_upsell_RECC_AM_SEG
--add Segment varchar(20)

update a
set Segment=
(case when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior in ('Else','Inactive_Multi')) then 'SEGAMAHMH1'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior in ('Active_Multi') and RecencyMonths>=4.5 and Seg60mOrders< 4.5) then 'SEGAMAHMH2'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior in ('Active_Multi') and RecencyMonths>=4.5 and Seg60mOrders>=4.5 and RecencyMonths>=6.5 and TenureMonths< 101.5) then 'SEGAMAHMH3'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior in ('Active_Multi') and RecencyMonths>=4.5 and Seg60mOrders>=4.5 and RecencyMonths>=6.5 and TenureMonths>=101.5) then 'SEGAMAHMH4'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior in ('Active_Multi') and RecencyMonths>=4.5 and Seg60mOrders>=4.5 and RecencyMonths< 6.5) then 'SEGAMAHMH5'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior in ('Active_Multi') and RecencyMonths< 4.5 and Seg12mOrders< 3.5 and TTB>=12.55) then 'SEGAMAHMH6'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior in ('Active_Multi') and RecencyMonths< 4.5 and Seg12mOrders< 3.5 and TTB< 12.55 and Seg12mSales< 329.7 and Seg60mOrders< 3.5) then 'SEGAMAHMH7'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior in ('Active_Multi') and RecencyMonths< 4.5 and Seg12mOrders< 3.5 and TTB< 12.55 and Seg12mSales< 329.7 and Seg60mOrders>=3.5 and Seg12mSales< 215.4 and MediaFormatPreference in ('D','DV')) then 'SEGAMAHMH8'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior in ('Active_Multi') and RecencyMonths< 4.5 and Seg12mOrders< 3.5 and TTB< 12.55 and Seg12mSales< 329.7 and Seg60mOrders>=3.5 and Seg12mSales< 215.4 and MediaFormatPreference in ('C','DL')) then 'SEGAMAHMH9'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior in ('Active_Multi') and RecencyMonths< 4.5 and Seg12mOrders< 3.5 and TTB< 12.55 and Seg12mSales< 329.7 and Seg60mOrders>=3.5 and Seg12mSales>=215.4) then 'SEGAMAHMH10'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior in ('Active_Multi') and RecencyMonths< 4.5 and Seg12mOrders< 3.5 and TTB< 12.55 and Seg12mSales>=329.7) then 'SEGAMAHMH11'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior in ('Active_Multi') and RecencyMonths< 4.5 and Seg12mOrders>=3.5) then 'SEGAMAHMH12'
when (Seg60mOrders>=5.5 and Seg12mOrders< 2.5 and Seg60mOrders< 9.5 and CustomerSegmentFnlPrior in ('Else','Inactive_Multi') and TenureMonths< 166.5 and Seg60mOrders< 7.5) then 'SEGAMAHMH13'
when (Seg60mOrders>=5.5 and Seg12mOrders< 2.5 and Seg60mOrders< 9.5 and CustomerSegmentFnlPrior in ('Else','Inactive_Multi') and TenureMonths< 166.5 and Seg60mOrders>=7.5 and ClickRatio< 0.01361) then 'SEGAMAHMH14'
when (Seg60mOrders>=5.5 and Seg12mOrders< 2.5 and Seg60mOrders< 9.5 and CustomerSegmentFnlPrior in ('Else','Inactive_Multi') and TenureMonths< 166.5 and Seg60mOrders>=7.5 and ClickRatio>=0.01361) then 'SEGAMAHMH15'
when (Seg60mOrders>=5.5 and Seg12mOrders< 2.5 and Seg60mOrders< 9.5 and CustomerSegmentFnlPrior in ('Else','Inactive_Multi') and TenureMonths>=166.5) then 'SEGAMAHMH16'
when (Seg60mOrders>=5.5 and Seg12mOrders< 2.5 and Seg60mOrders< 9.5 and CustomerSegmentFnlPrior in ('Active_Multi') and RecencyMonths>=8.5 and ClickRatio< 0.01325 and TenureMonths< 60.5) then 'SEGAMAHMH17'
when (Seg60mOrders>=5.5 and Seg12mOrders< 2.5 and Seg60mOrders< 9.5 and CustomerSegmentFnlPrior in ('Active_Multi') and RecencyMonths>=8.5 and ClickRatio< 0.01325 and TenureMonths>=60.5 and Seg60mEmailOrderRatio>=0.1944) then 'SEGAMAHMH18'
when (Seg60mOrders>=5.5 and Seg12mOrders< 2.5 and Seg60mOrders< 9.5 and CustomerSegmentFnlPrior in ('Active_Multi') and RecencyMonths>=8.5 and ClickRatio< 0.01325 and TenureMonths>=60.5 and Seg60mEmailOrderRatio< 0.1944) then 'SEGAMAHMH19'
when (Seg60mOrders>=5.5 and Seg12mOrders< 2.5 and Seg60mOrders< 9.5 and CustomerSegmentFnlPrior in ('Active_Multi') and RecencyMonths>=8.5 and ClickRatio>=0.01325) then 'SEGAMAHMH20'
when (Seg60mOrders>=5.5 and Seg12mOrders< 2.5 and Seg60mOrders< 9.5 and CustomerSegmentFnlPrior in ('Active_Multi') and RecencyMonths< 8.5) then 'SEGAMAHMH21'
when (Seg60mOrders>=5.5 and Seg12mOrders< 2.5 and Seg60mOrders>=9.5) then 'SEGAMAHMH22'
when (Seg60mOrders>=5.5 and Seg12mOrders>=2.5) then 'SEGAMAHMH23'
else 'NULL' end)
from Datawarehouse.staging.tgc_upsell_RECC_AM_SEG a
where a.PreferredCategory2 in ('AH','MH')


update a
set Segment=
(case  when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior='Else') then 'SEGAMECPRHS1'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and Seg12mSales< 124.9 and Seg60mOrders< 3.5) then 'SEGAMECPRHS2'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and Seg12mSales< 124.9 and Seg60mOrders>=3.5 and age< 54.5) then 'SEGAMECPRHS3'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and Seg12mSales< 124.9 and Seg60mOrders>=3.5 and age>=54.5 and TenureMonths< 107.5) then 'SEGAMECPRHS4'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and Seg12mSales< 124.9 and Seg60mOrders>=3.5 and age>=54.5 and TenureMonths>=107.5) then 'SEGAMECPRHS5'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and Seg12mSales>=124.9 and ClickRatio< 0.02649 and RecencyMonths>=4.5) then 'SEGAMECPRHS6'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and Seg12mSales>=124.9 and ClickRatio< 0.02649 and RecencyMonths< 4.5 and TTB>=3.9 and Seg60mSales< 478.2) then 'SEGAMECPRHS7'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and Seg12mSales>=124.9 and ClickRatio< 0.02649 and RecencyMonths< 4.5 and TTB>=3.9 and Seg60mSales>=478.2) then 'SEGAMECPRHS8'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and Seg12mSales>=124.9 and ClickRatio< 0.02649 and RecencyMonths< 4.5 and TTB< 3.9) then 'SEGAMECPRHS9'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and Seg12mSales>=124.9 and ClickRatio>=0.02649 and FlagEmail< 0.5 and Seg60mOrders< 3.5) then 'SEGAMECPRHS10'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and Seg12mSales>=124.9 and ClickRatio>=0.02649 and FlagEmail< 0.5 and Seg60mOrders>=3.5) then 'SEGAMECPRHS11'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and Seg12mSales>=124.9 and ClickRatio>=0.02649 and FlagEmail>=0.5) then 'SEGAMECPRHS12'
when (Seg60mOrders>=5.5 and Seg60mOrders< 11.5 and Seg12mSales< 364.6 and CustomerSegmentFnlPrior in ('Else','Inactive_Multi') and RecencyMonths>=2.5 and Seg60mSales< 830.2) then 'SEGAMECPRHS13'
when (Seg60mOrders>=5.5 and Seg60mOrders< 11.5 and Seg12mSales< 364.6 and CustomerSegmentFnlPrior in ('Else','Inactive_Multi') and RecencyMonths>=2.5 and Seg60mSales>=830.2) then 'SEGAMECPRHS14'
when (Seg60mOrders>=5.5 and Seg60mOrders< 11.5 and Seg12mSales< 364.6 and CustomerSegmentFnlPrior in ('Else','Inactive_Multi') and RecencyMonths< 2.5) then 'SEGAMECPRHS15'
when (Seg60mOrders>=5.5 and Seg60mOrders< 11.5 and Seg12mSales< 364.6 and CustomerSegmentFnlPrior='Active_Multi' and RecencyMonths>=4.5 and ClickRatio< 0.02759 and age< 52.5) then 'SEGAMECPRHS16'
when (Seg60mOrders>=5.5 and Seg60mOrders< 11.5 and Seg12mSales< 364.6 and CustomerSegmentFnlPrior='Active_Multi' and RecencyMonths>=4.5 and ClickRatio< 0.02759 and age>=52.5 and TenureMonths< 71.5 and Seg60mEmailOrderRatio>=0.2361) then 'SEGAMECPRHS17'
when (Seg60mOrders>=5.5 and Seg60mOrders< 11.5 and Seg12mSales< 364.6 and CustomerSegmentFnlPrior='Active_Multi' and RecencyMonths>=4.5 and ClickRatio< 0.02759 and age>=52.5 and TenureMonths< 71.5 and Seg60mEmailOrderRatio< 0.2361) then 'SEGAMECPRHS18'
when (Seg60mOrders>=5.5 and Seg60mOrders< 11.5 and Seg12mSales< 364.6 and CustomerSegmentFnlPrior='Active_Multi' and RecencyMonths>=4.5 and ClickRatio< 0.02759 and age>=52.5 and TenureMonths>=71.5) then 'SEGAMECPRHS19'
when (Seg60mOrders>=5.5 and Seg60mOrders< 11.5 and Seg12mSales< 364.6 and CustomerSegmentFnlPrior='Active_Multi' and RecencyMonths>=4.5 and ClickRatio>=0.02759) then 'SEGAMECPRHS20'
when (Seg60mOrders>=5.5 and Seg60mOrders< 11.5 and Seg12mSales< 364.6 and CustomerSegmentFnlPrior='Active_Multi' and RecencyMonths< 4.5) then 'SEGAMECPRHS21'
when (Seg60mOrders>=5.5 and Seg60mOrders< 11.5 and Seg12mSales>=364.6) then 'SEGAMECPRHS22'
when (Seg60mOrders>=5.5 and Seg60mOrders>=11.5) then 'SEGAMECPRHS23'
else 'NULL' end)
from Datawarehouse.staging.tgc_upsell_RECC_AM_SEG a
where a.PreferredCategory2 in ('EC','PR','HS')

 update a
set Segment=
(case  when (Seg60mOrders< 4.5 and Seg60mOrders< 2.5 and ClickRatio< 0.01274) then 'SEGAMFW1'
when (Seg60mOrders< 4.5 and Seg60mOrders< 2.5 and ClickRatio>=0.01274 and FlagEmail< 0.5) then 'SEGAMFW2'
when (Seg60mOrders< 4.5 and Seg60mOrders< 2.5 and ClickRatio>=0.01274 and FlagEmail>=0.5 and ClickRatio< 0.06712) then 'SEGAMFW3'
when (Seg60mOrders< 4.5 and Seg60mOrders< 2.5 and ClickRatio>=0.01274 and FlagEmail>=0.5 and ClickRatio>=0.06712 and ClickRatio< 0.1606 and age>=63.5) then 'SEGAMFW4'
when (Seg60mOrders< 4.5 and Seg60mOrders< 2.5 and ClickRatio>=0.01274 and FlagEmail>=0.5 and ClickRatio>=0.06712 and ClickRatio< 0.1606 and age< 63.5) then 'SEGAMFW5'
when (Seg60mOrders< 4.5 and Seg60mOrders< 2.5 and ClickRatio>=0.01274 and FlagEmail>=0.5 and ClickRatio>=0.06712 and ClickRatio>=0.1606) then 'SEGAMFW6'
when (Seg60mOrders< 4.5 and Seg60mOrders>=2.5 and ClickRatio< 0.00625 and Seg12mSales< 129) then 'SEGAMFW7'
when (Seg60mOrders< 4.5 and Seg60mOrders>=2.5 and ClickRatio< 0.00625 and Seg12mSales>=129 and Seg60mOrders< 3.5 and RecencyMonths>=3.5) then 'SEGAMFW8'
when (Seg60mOrders< 4.5 and Seg60mOrders>=2.5 and ClickRatio< 0.00625 and Seg12mSales>=129 and Seg60mOrders< 3.5 and RecencyMonths< 3.5 and Seg12mOrders< 2.5) then 'SEGAMFW9'
when (Seg60mOrders< 4.5 and Seg60mOrders>=2.5 and ClickRatio< 0.00625 and Seg12mSales>=129 and Seg60mOrders< 3.5 and RecencyMonths< 3.5 and Seg12mOrders>=2.5) then 'SEGAMFW10'
when (Seg60mOrders< 4.5 and Seg60mOrders>=2.5 and ClickRatio< 0.00625 and Seg12mSales>=129 and Seg60mOrders>=3.5 and RecencyMonths>=6.5 and Gender in ('F','U')) then 'SEGAMFW11'
when (Seg60mOrders< 4.5 and Seg60mOrders>=2.5 and ClickRatio< 0.00625 and Seg12mSales>=129 and Seg60mOrders>=3.5 and RecencyMonths>=6.5 and Gender='M') then 'SEGAMFW12'
when (Seg60mOrders< 4.5 and Seg60mOrders>=2.5 and ClickRatio< 0.00625 and Seg12mSales>=129 and Seg60mOrders>=3.5 and RecencyMonths< 6.5) then 'SEGAMFW13'
when (Seg60mOrders< 4.5 and Seg60mOrders>=2.5 and ClickRatio>=0.00625 and Seg12mOrders< 2.5 and FlagEmail< 0.5 and Seg60mSales< 404.7) then 'SEGAMFW14'
when (Seg60mOrders< 4.5 and Seg60mOrders>=2.5 and ClickRatio>=0.00625 and Seg12mOrders< 2.5 and FlagEmail< 0.5 and Seg60mSales>=404.7) then 'SEGAMFW15'
when (Seg60mOrders< 4.5 and Seg60mOrders>=2.5 and ClickRatio>=0.00625 and Seg12mOrders< 2.5 and FlagEmail>=0.5 and ClickRatio< 0.05003 and Seg60mSales< 269.8) then 'SEGAMFW16'
when (Seg60mOrders< 4.5 and Seg60mOrders>=2.5 and ClickRatio>=0.00625 and Seg12mOrders< 2.5 and FlagEmail>=0.5 and ClickRatio< 0.05003 and Seg60mSales>=269.8) then 'SEGAMFW17'
when (Seg60mOrders< 4.5 and Seg60mOrders>=2.5 and ClickRatio>=0.00625 and Seg12mOrders< 2.5 and FlagEmail>=0.5 and ClickRatio>=0.05003) then 'SEGAMFW18'
when (Seg60mOrders< 4.5 and Seg60mOrders>=2.5 and ClickRatio>=0.00625 and Seg12mOrders>=2.5) then 'SEGAMFW19'
when (Seg60mOrders>=4.5 and Seg60mOrders< 11.5 and Seg12mSales< 140.4 and Seg60mOrders< 6.5 and Seg12mSales< 41.94) then 'SEGAMFW20'
when (Seg60mOrders>=4.5 and Seg60mOrders< 11.5 and Seg12mSales< 140.4 and Seg60mOrders< 6.5 and Seg12mSales>=41.94 and ClickRatio< 0.02685 and Seg60mOrders< 5.5 and Gender in ('F','U')) then 'SEGAMFW21'
when (Seg60mOrders>=4.5 and Seg60mOrders< 11.5 and Seg12mSales< 140.4 and Seg60mOrders< 6.5 and Seg12mSales>=41.94 and ClickRatio< 0.02685 and Seg60mOrders< 5.5 and Gender='M' and TTB>=7.15) then 'SEGAMFW22'
when (Seg60mOrders>=4.5 and Seg60mOrders< 11.5 and Seg12mSales< 140.4 and Seg60mOrders< 6.5 and Seg12mSales>=41.94 and ClickRatio< 0.02685 and Seg60mOrders< 5.5 and Gender='M' and TTB< 7.15) then 'SEGAMFW23'
when (Seg60mOrders>=4.5 and Seg60mOrders< 11.5 and Seg12mSales< 140.4 and Seg60mOrders< 6.5 and Seg12mSales>=41.94 and ClickRatio< 0.02685 and Seg60mOrders>=5.5) then 'SEGAMFW24'
when (Seg60mOrders>=4.5 and Seg60mOrders< 11.5 and Seg12mSales< 140.4 and Seg60mOrders< 6.5 and Seg12mSales>=41.94 and ClickRatio>=0.02685 and Seg12mSales< 104.9 and OrderSourcePreference in ('M','P')) then 'SEGAMFW25'
when (Seg60mOrders>=4.5 and Seg60mOrders< 11.5 and Seg12mSales< 140.4 and Seg60mOrders< 6.5 and Seg12mSales>=41.94 and ClickRatio>=0.02685 and Seg12mSales< 104.9 and OrderSourcePreference='W') then 'SEGAMFW26'
when (Seg60mOrders>=4.5 and Seg60mOrders< 11.5 and Seg12mSales< 140.4 and Seg60mOrders< 6.5 and Seg12mSales>=41.94 and ClickRatio>=0.02685 and Seg12mSales>=104.9) then 'SEGAMFW27'
when (Seg60mOrders>=4.5 and Seg60mOrders< 11.5 and Seg12mSales< 140.4 and Seg60mOrders>=6.5) then 'SEGAMFW28'
when (Seg60mOrders>=4.5 and Seg60mOrders< 11.5 and Seg12mSales>=140.4) then 'SEGAMFW29'
when (Seg60mOrders>=4.5 and Seg60mOrders>=11.5) then 'SEGAMFW30'
else 'NULL' end)
from Datawarehouse.staging.tgc_upsell_RECC_AM_SEG a
where a.PreferredCategory2 in ('FW')


update a
set Segment=
(case when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior in ('Else','Inactive_Multi') and Seg60mSales< 218.7) then 'SEGAMLITPH1'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior in ('Else','Inactive_Multi') and Seg60mSales>=218.7 and ClickRatio< 0.006494) then 'SEGAMLITPH2'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior in ('Else','Inactive_Multi') and Seg60mSales>=218.7 and ClickRatio>=0.006494 and RecencyMonths>=7.5) then 'SEGAMLITPH3'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior in ('Else','Inactive_Multi') and Seg60mSales>=218.7 and ClickRatio>=0.006494 and RecencyMonths< 7.5 and TTB>=6.05) then 'SEGAMLITPH4'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior in ('Else','Inactive_Multi') and Seg60mSales>=218.7 and ClickRatio>=0.006494 and RecencyMonths< 7.5 and TTB< 6.05) then 'SEGAMLITPH5'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior='Active_Multi' and Seg60mOrders< 3.5 and TenureMonths>=9.5 and Seg60mSales< 213.8) then 'SEGAMLITPH6'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior='Active_Multi' and Seg60mOrders< 3.5 and TenureMonths>=9.5 and Seg60mSales>=213.8 and Gender='F') then 'SEGAMLITPH7'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior='Active_Multi' and Seg60mOrders< 3.5 and TenureMonths>=9.5 and Seg60mSales>=213.8 and Gender in ('M','U') and TenureMonths< 85.5) then 'SEGAMLITPH8'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior='Active_Multi' and Seg60mOrders< 3.5 and TenureMonths>=9.5 and Seg60mSales>=213.8 and Gender in ('M','U') and TenureMonths>=85.5) then 'SEGAMLITPH9'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior='Active_Multi' and Seg60mOrders< 3.5 and TenureMonths< 9.5) then 'SEGAMLITPH10'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior='Active_Multi' and Seg60mOrders>=3.5 and ClickRatio< 0.01361 and RecencyMonths>=3.5 and MediaFormatPreference in ('C','DL','DV')) then 'SEGAMLITPH11'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior='Active_Multi' and Seg60mOrders>=3.5 and ClickRatio< 0.01361 and RecencyMonths>=3.5 and MediaFormatPreference='D' and Seg60mSales< 530.5) then 'SEGAMLITPH12'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior='Active_Multi' and Seg60mOrders>=3.5 and ClickRatio< 0.01361 and RecencyMonths>=3.5 and MediaFormatPreference='D' and Seg60mSales>=530.5) then 'SEGAMLITPH13'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior='Active_Multi' and Seg60mOrders>=3.5 and ClickRatio< 0.01361 and RecencyMonths< 3.5) then 'SEGAMLITPH14'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior='Active_Multi' and Seg60mOrders>=3.5 and ClickRatio>=0.01361 and Seg12mSales< 192.6 and MediaFormatPreference in ('C','DL','DV')) then 'SEGAMLITPH15'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior='Active_Multi' and Seg60mOrders>=3.5 and ClickRatio>=0.01361 and Seg12mSales< 192.6 and MediaFormatPreference='D') then 'SEGAMLITPH16'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior='Active_Multi' and Seg60mOrders>=3.5 and ClickRatio>=0.01361 and Seg12mSales>=192.6) then 'SEGAMLITPH17'
when (Seg60mOrders>=5.5 and Seg12mOrders< 3.5 and Seg60mOrders< 10.5 and Seg12mSales< 69.94 and ClickRatio< 0.04774 and TenureMonths< 86.5) then 'SEGAMLITPH18'
when (Seg60mOrders>=5.5 and Seg12mOrders< 3.5 and Seg60mOrders< 10.5 and Seg12mSales< 69.94 and ClickRatio< 0.04774 and TenureMonths>=86.5 and TenureMonths< 131.5) then 'SEGAMLITPH19'
when (Seg60mOrders>=5.5 and Seg12mOrders< 3.5 and Seg60mOrders< 10.5 and Seg12mSales< 69.94 and ClickRatio< 0.04774 and TenureMonths>=86.5 and TenureMonths>=131.5) then 'SEGAMLITPH20'
when (Seg60mOrders>=5.5 and Seg12mOrders< 3.5 and Seg60mOrders< 10.5 and Seg12mSales< 69.94 and ClickRatio>=0.04774) then 'SEGAMLITPH21'
when (Seg60mOrders>=5.5 and Seg12mOrders< 3.5 and Seg60mOrders< 10.5 and Seg12mSales>=69.94 and Seg60mOrders< 7.5 and ClickRatio< 0.02649 and Seg60mEmailOrderRatio>=0.4643) then 'SEGAMLITPH22'
when (Seg60mOrders>=5.5 and Seg12mOrders< 3.5 and Seg60mOrders< 10.5 and Seg12mSales>=69.94 and Seg60mOrders< 7.5 and ClickRatio< 0.02649 and Seg60mEmailOrderRatio< 0.4643 and Seg60mSales< 715.8 and TenureMonths< 77.5) then 'SEGAMLITPH23'
when (Seg60mOrders>=5.5 and Seg12mOrders< 3.5 and Seg60mOrders< 10.5 and Seg12mSales>=69.94 and Seg60mOrders< 7.5 and ClickRatio< 0.02649 and Seg60mEmailOrderRatio< 0.4643 and Seg60mSales< 715.8 and TenureMonths>=77.5) then 'SEGAMLITPH24'
when (Seg60mOrders>=5.5 and Seg12mOrders< 3.5 and Seg60mOrders< 10.5 and Seg12mSales>=69.94 and Seg60mOrders< 7.5 and ClickRatio< 0.02649 and Seg60mEmailOrderRatio< 0.4643 and Seg60mSales>=715.8) then 'SEGAMLITPH25'
when (Seg60mOrders>=5.5 and Seg12mOrders< 3.5 and Seg60mOrders< 10.5 and Seg12mSales>=69.94 and Seg60mOrders< 7.5 and ClickRatio>=0.02649) then 'SEGAMLITPH26'
when (Seg60mOrders>=5.5 and Seg12mOrders< 3.5 and Seg60mOrders< 10.5 and Seg12mSales>=69.94 and Seg60mOrders>=7.5) then 'SEGAMLITPH27'
when (Seg60mOrders>=5.5 and Seg12mOrders< 3.5 and Seg60mOrders>=10.5) then 'SEGAMLITPH28'
when (Seg60mOrders>=5.5 and Seg12mOrders>=3.5) then 'SEGAMLITPH29'
else 'NULL' end)
from Datawarehouse.staging.tgc_upsell_RECC_AM_SEG a
where a.PreferredCategory2 in ('LIT','PH')


update a
set Segment=
(case when (Seg60mOrders< 5.5 and Seg60mOrders< 2.5 and RecencyMonths>=3.5) then 'SEGAMSCIMTH1'
when (Seg60mOrders< 5.5 and Seg60mOrders< 2.5 and RecencyMonths< 3.5 and Seg12mOrders< 1.5) then 'SEGAMSCIMTH2'
when (Seg60mOrders< 5.5 and Seg60mOrders< 2.5 and RecencyMonths< 3.5 and Seg12mOrders>=1.5 and RecencyMonths>=2.5) then 'SEGAMSCIMTH3'
when (Seg60mOrders< 5.5 and Seg60mOrders< 2.5 and RecencyMonths< 3.5 and Seg12mOrders>=1.5 and RecencyMonths< 2.5 and ClickRatio< 0.01342) then 'SEGAMSCIMTH4'
when (Seg60mOrders< 5.5 and Seg60mOrders< 2.5 and RecencyMonths< 3.5 and Seg12mOrders>=1.5 and RecencyMonths< 2.5 and ClickRatio>=0.01342 and TenureMonths>=7.5) then 'SEGAMSCIMTH5'
when (Seg60mOrders< 5.5 and Seg60mOrders< 2.5 and RecencyMonths< 3.5 and Seg12mOrders>=1.5 and RecencyMonths< 2.5 and ClickRatio>=0.01342 and TenureMonths< 7.5) then 'SEGAMSCIMTH6'
when (Seg60mOrders< 5.5 and Seg60mOrders>=2.5 and Seg12mOrders< 1.5 and Seg60mOrders< 3.5) then 'SEGAMSCIMTH7'
when (Seg60mOrders< 5.5 and Seg60mOrders>=2.5 and Seg12mOrders< 1.5 and Seg60mOrders>=3.5 and Seg60mSales< 189.8) then 'SEGAMSCIMTH8'
when (Seg60mOrders< 5.5 and Seg60mOrders>=2.5 and Seg12mOrders< 1.5 and Seg60mOrders>=3.5 and Seg60mSales>=189.8 and ClickRatio< 0.01266) then 'SEGAMSCIMTH9'
when (Seg60mOrders< 5.5 and Seg60mOrders>=2.5 and Seg12mOrders< 1.5 and Seg60mOrders>=3.5 and Seg60mSales>=189.8 and ClickRatio>=0.01266 and CustomerSegmentFnlPrior in ('Else','Inactive_Multi')) then 'SEGAMSCIMTH10'
when (Seg60mOrders< 5.5 and Seg60mOrders>=2.5 and Seg12mOrders< 1.5 and Seg60mOrders>=3.5 and Seg60mSales>=189.8 and ClickRatio>=0.01266 and CustomerSegmentFnlPrior='Active_Multi' and FlagEmail< 0.5) then 'SEGAMSCIMTH11'
when (Seg60mOrders< 5.5 and Seg60mOrders>=2.5 and Seg12mOrders< 1.5 and Seg60mOrders>=3.5 and Seg60mSales>=189.8 and ClickRatio>=0.01266 and CustomerSegmentFnlPrior='Active_Multi' and FlagEmail>=0.5) then 'SEGAMSCIMTH12'
when (Seg60mOrders< 5.5 and Seg60mOrders>=2.5 and Seg12mOrders>=1.5 and RecencyMonths>=4.5 and Seg60mOrders< 3.5) then 'SEGAMSCIMTH13'
when (Seg60mOrders< 5.5 and Seg60mOrders>=2.5 and Seg12mOrders>=1.5 and RecencyMonths>=4.5 and Seg60mOrders>=3.5 and ClickRatio< 0.01342 and Gender in ('F','U')) then 'SEGAMSCIMTH14'
when (Seg60mOrders< 5.5 and Seg60mOrders>=2.5 and Seg12mOrders>=1.5 and RecencyMonths>=4.5 and Seg60mOrders>=3.5 and ClickRatio< 0.01342 and Gender='M' and Seg12mSales< 246.7) then 'SEGAMSCIMTH15'
when (Seg60mOrders< 5.5 and Seg60mOrders>=2.5 and Seg12mOrders>=1.5 and RecencyMonths>=4.5 and Seg60mOrders>=3.5 and ClickRatio< 0.01342 and Gender='M' and Seg12mSales>=246.7) then 'SEGAMSCIMTH16'
when (Seg60mOrders< 5.5 and Seg60mOrders>=2.5 and Seg12mOrders>=1.5 and RecencyMonths>=4.5 and Seg60mOrders>=3.5 and ClickRatio>=0.01342) then 'SEGAMSCIMTH17'
when (Seg60mOrders< 5.5 and Seg60mOrders>=2.5 and Seg12mOrders>=1.5 and RecencyMonths< 4.5 and Seg12mOrders< 3.5 and ClickRatio< 0.03922 and Seg12mSales< 294.8 and age< 64.5) then 'SEGAMSCIMTH18'
when (Seg60mOrders< 5.5 and Seg60mOrders>=2.5 and Seg12mOrders>=1.5 and RecencyMonths< 4.5 and Seg12mOrders< 3.5 and ClickRatio< 0.03922 and Seg12mSales< 294.8 and age>=64.5 and Seg60mSales< 279.8) then 'SEGAMSCIMTH19'
when (Seg60mOrders< 5.5 and Seg60mOrders>=2.5 and Seg12mOrders>=1.5 and RecencyMonths< 4.5 and Seg12mOrders< 3.5 and ClickRatio< 0.03922 and Seg12mSales< 294.8 and age>=64.5 and Seg60mSales>=279.8) then 'SEGAMSCIMTH20'
when (Seg60mOrders< 5.5 and Seg60mOrders>=2.5 and Seg12mOrders>=1.5 and RecencyMonths< 4.5 and Seg12mOrders< 3.5 and ClickRatio< 0.03922 and Seg12mSales>=294.8) then 'SEGAMSCIMTH21'
when (Seg60mOrders< 5.5 and Seg60mOrders>=2.5 and Seg12mOrders>=1.5 and RecencyMonths< 4.5 and Seg12mOrders< 3.5 and ClickRatio>=0.03922) then 'SEGAMSCIMTH22'
when (Seg60mOrders< 5.5 and Seg60mOrders>=2.5 and Seg12mOrders>=1.5 and RecencyMonths< 4.5 and Seg12mOrders>=3.5) then 'SEGAMSCIMTH23'
when (Seg60mOrders>=5.5 and Seg12mOrders< 2.5 and Seg60mOrders< 8.5 and CustomerSegmentFnlPrior in ('Else','Inactive_Multi') and TenureMonths< 100.5) then 'SEGAMSCIMTH24'
when (Seg60mOrders>=5.5 and Seg12mOrders< 2.5 and Seg60mOrders< 8.5 and CustomerSegmentFnlPrior in ('Else','Inactive_Multi') and TenureMonths>=100.5 and TTB>=8.75) then 'SEGAMSCIMTH25'
when (Seg60mOrders>=5.5 and Seg12mOrders< 2.5 and Seg60mOrders< 8.5 and CustomerSegmentFnlPrior in ('Else','Inactive_Multi') and TenureMonths>=100.5 and TTB< 8.75) then 'SEGAMSCIMTH26'
when (Seg60mOrders>=5.5 and Seg12mOrders< 2.5 and Seg60mOrders< 8.5 and CustomerSegmentFnlPrior='Active_Multi' and Seg12mSales< 140.2 and ClickRatio< 0.01342 and Seg60mSales< 474.4) then 'SEGAMSCIMTH27'
when (Seg60mOrders>=5.5 and Seg12mOrders< 2.5 and Seg60mOrders< 8.5 and CustomerSegmentFnlPrior='Active_Multi' and Seg12mSales< 140.2 and ClickRatio< 0.01342 and Seg60mSales>=474.4) then 'SEGAMSCIMTH28'
when (Seg60mOrders>=5.5 and Seg12mOrders< 2.5 and Seg60mOrders< 8.5 and CustomerSegmentFnlPrior='Active_Multi' and Seg12mSales< 140.2 and ClickRatio>=0.01342) then 'SEGAMSCIMTH29'
when (Seg60mOrders>=5.5 and Seg12mOrders< 2.5 and Seg60mOrders< 8.5 and CustomerSegmentFnlPrior='Active_Multi' and Seg12mSales>=140.2) then 'SEGAMSCIMTH30'
when (Seg60mOrders>=5.5 and Seg12mOrders< 2.5 and Seg60mOrders>=8.5) then 'SEGAMSCIMTH31'
when (Seg60mOrders>=5.5 and Seg12mOrders>=2.5) then 'SEGAMSCIMTH32'
else 'NULL' end)
from Datawarehouse.staging.tgc_upsell_RECC_AM_SEG a
where a.PreferredCategory2 in ('SCI','MTH')


  update a
set Segment=
(case when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior in ('Else','Inactive_Multi')) then 'SEGRL1'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior='Active_Multi' and RecencyMonths>=3.5 and Seg60mOrders< 3.5) then 'SEGRL2'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior='Active_Multi' and RecencyMonths>=3.5 and Seg60mOrders>=3.5 and Seg12mSales< 160.1 and TenureMonths< 83.5) then 'SEGRL3'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior='Active_Multi' and RecencyMonths>=3.5 and Seg60mOrders>=3.5 and Seg12mSales< 160.1 and TenureMonths>=83.5) then 'SEGRL4'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior='Active_Multi' and RecencyMonths>=3.5 and Seg60mOrders>=3.5 and Seg12mSales>=160.1) then 'SEGRL5'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior='Active_Multi' and RecencyMonths< 3.5 and Seg12mOrders< 2.5 and Seg60mSales< 254.2) then 'SEGRL6'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior='Active_Multi' and RecencyMonths< 3.5 and Seg12mOrders< 2.5 and Seg60mSales>=254.2) then 'SEGRL7'
when (Seg60mOrders< 5.5 and CustomerSegmentFnlPrior='Active_Multi' and RecencyMonths< 3.5 and Seg12mOrders>=2.5) then 'SEGRL8'
when (Seg60mOrders>=5.5 and Seg12mOrders< 3.5 and Seg60mOrders< 8.5 and Seg12mSales< 160.8 and ClickRatio< 0.01325 and CustomerSegmentFnlPrior in ('Else','Inactive_Multi')) then 'SEGRL9'
when (Seg60mOrders>=5.5 and Seg12mOrders< 3.5 and Seg60mOrders< 8.5 and Seg12mSales< 160.8 and ClickRatio< 0.01325 and CustomerSegmentFnlPrior='Active_Multi' and TenureMonths< 59.5) then 'SEGRL10'
when (Seg60mOrders>=5.5 and Seg12mOrders< 3.5 and Seg60mOrders< 8.5 and Seg12mSales< 160.8 and ClickRatio< 0.01325 and CustomerSegmentFnlPrior='Active_Multi' and TenureMonths>=59.5) then 'SEGRL11'
when (Seg60mOrders>=5.5 and Seg12mOrders< 3.5 and Seg60mOrders< 8.5 and Seg12mSales< 160.8 and ClickRatio>=0.01325) then 'SEGRL12'
when (Seg60mOrders>=5.5 and Seg12mOrders< 3.5 and Seg60mOrders< 8.5 and Seg12mSales>=160.8) then 'SEGRL13'
when (Seg60mOrders>=5.5 and Seg12mOrders< 3.5 and Seg60mOrders>=8.5) then 'SEGRL14'
when (Seg60mOrders>=5.5 and Seg12mOrders>=3.5) then 'SEGRL15'
else 'NULL' end)
from Datawarehouse.staging.tgc_upsell_RECC_AM_SEG a
where a.PreferredCategory2 in ('RL')


update a
set Segment=
(case   when (Seg60mOrders< 4.5 and CustomerSegmentFnlPrior='Else') then 'SEGAMVAMSC1'
when (Seg60mOrders< 4.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and Seg12mSales< 157.1 and TTB>=28.1) then 'SEGAMVAMSC2'
when (Seg60mOrders< 4.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and Seg12mSales< 157.1 and TTB< 28.1 and TenureMonths< 100.5) then 'SEGAMVAMSC3'
when (Seg60mOrders< 4.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and Seg12mSales< 157.1 and TTB< 28.1 and TenureMonths>=100.5 and Seg12mSales< 71.22) then 'SEGAMVAMSC4'
when (Seg60mOrders< 4.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and Seg12mSales< 157.1 and TTB< 28.1 and TenureMonths>=100.5 and Seg12mSales>=71.22) then 'SEGAMVAMSC5'
when (Seg60mOrders< 4.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and Seg12mSales>=157.1 and ClickRatio< 0.01342 and RecencyMonths>=3.5) then 'SEGAMVAMSC6'
when (Seg60mOrders< 4.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and Seg12mSales>=157.1 and ClickRatio< 0.01342 and RecencyMonths< 3.5) then 'SEGAMVAMSC7'
when (Seg60mOrders< 4.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and Seg12mSales>=157.1 and ClickRatio>=0.01342) then 'SEGAMVAMSC8'
when (Seg60mOrders>=4.5 and Seg60mOrders< 8.5 and Seg12mSales< 283.3 and Seg60mOrders< 6.5 and Seg12mSales< 132.7 and ClickRatio< 0.01325) then 'SEGAMVAMSC9'
when (Seg60mOrders>=4.5 and Seg60mOrders< 8.5 and Seg12mSales< 283.3 and Seg60mOrders< 6.5 and Seg12mSales< 132.7 and ClickRatio>=0.01325) then 'SEGAMVAMSC10'
when (Seg60mOrders>=4.5 and Seg60mOrders< 8.5 and Seg12mSales< 283.3 and Seg60mOrders< 6.5 and Seg12mSales>=132.7) then 'SEGAMVAMSC11'
when (Seg60mOrders>=4.5 and Seg60mOrders< 8.5 and Seg12mSales< 283.3 and Seg60mOrders>=6.5) then 'SEGAMVAMSC12'
when (Seg60mOrders>=4.5 and Seg60mOrders< 8.5 and Seg12mSales>=283.3) then 'SEGAMVAMSC13'
when (Seg60mOrders>=4.5 and Seg60mOrders>=8.5) then 'SEGAMVAMSC14'
else 'NULL' end)
from Datawarehouse.staging.tgc_upsell_RECC_AM_SEG a
where a.PreferredCategory2 in ('VA','MSC')


update a
set Segment='SEGAMNULL'
from Datawarehouse.staging.tgc_upsell_RECC_AM_SEG a
where Segment is null or Segment='NULL'
--(1497 row(s) affected)

  --find all the segments whose counts are less than 100
--and assign them into NULL segment
--drop table #Segment
select Segment, count(*) count
into #Segment
from Datawarehouse.staging.tgc_upsell_RECC_AM_SEG
group by Segment
having count(*) < 100
--(0 row(s) affected)

update a
set Segment='SEGAMNULL'
from Datawarehouse.staging.tgc_upsell_RECC_AM_SEG a
where a.Segment in (select Segment from #Segment)

--select top 1000 * from
--Datawarehouse.staging.tgc_upsell_RECC_AM_SEG


select count(*), Segment
from Datawarehouse.staging.tgc_upsell_RECC_AM_SEG
group by Segment
order by Segment




End
GO
