SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [Staging].[SP_Load_tgc_upsell_RECC_IM_SEG]  
as  
Begin  
  
/****************************Create base table for In-Active Multi's*********************************/  
  
-- drop table #base  
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
where NewSeg in (13,14,15,18,19,20,23,24,25,28)  
and comboid not like '%highschool%') t1  
join  
(select distinct CustomerID from  
DataWarehouse.Marketing.DMPurchaseOrders  
where BillingCountryCode in ('US','USA')  
--and convert(date,DateOrdered) < '6/29/2017'  
) t2 on  
t1.CustomerID=t2.CustomerID  
--(369269 row(s) affected)  
  
  
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
  
  
  
--Purchase in past 36 months  
--drop table #Seg36m1  
select t1.CustomerID,  
count(*) Seg36mOrders,  
sum(NetOrderAmount) Seg36mSales  
into #Seg36m1  
from  
#base t1  
join  
(select CustomerID,NetOrderAmount  
from DataWarehouse.Marketing.DMPurchaseOrders  
where BillingCountryCode in ('US','USA')  
and convert(date,DateOrdered) between dateadd(year,-3,getdate()) and getdate()) t2  
on t1.CustomerID=t2.CustomerID  
group by t1.CustomerID  
  
  
--drop table #Seg36m2  
select t1.CustomerID,  
count(*) Seg36mEmailOrders,  
sum(NetOrderAmount) Seg36mEmailSales  
into #Seg36m2  
from  
#base t1  
join  
(select CustomerID,NetOrderAmount  
from DataWarehouse.Marketing.DMPurchaseOrders  
where BillingCountryCode in ('US','USA')  
and convert(date,DateOrdered) between  dateadd(year,-3,getdate()) and getdate()  
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
--(78071948 row(s) affected)  
  
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
t4.Seg36mOrders,  
t4.Seg36mSales,  
t5.Seg36mEmailOrders,  
t5.Seg36mEmailSales,  
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
#Seg36m1 t4 on  
t1.CustomerID=t4.CustomerID  
left outer join  
#Seg36m2 t5 on  
t1.CustomerID=t5.CustomerID   
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
Seg36mOrders = (case when Seg36mOrders is null then 0 else Seg36mOrders end),  
Seg36mSales = (case when Seg36mSales is null then 0 else Seg36mSales end),  
Seg36mEmailOrders = (case when Seg36mEmailOrders is null then 0 else Seg36mEmailOrders end),  
ClickCnt = (case when ClickCnt is null then 0 else ClickCnt end)   
from  
#final t1  
left outer join  
DataWarehouse.Mapping.GENDER_LOOKUP t2 on  
upper(t1.FirstName)=upper(t2.FirstName)  
  
if object_id ('Datawarehouse.staging.tgc_upsell_RECC_IM_SEG') is not null  
Drop table Datawarehouse.staging.tgc_upsell_RECC_IM_SEG  
  
-- drop table Datawarehouse.staging.tgc_upsell_RECC_IM_SEG  
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
Seg36mOrders,  
Seg36mSales,  
(case when Seg36mOrders=0 then 0 else Seg36mEmailOrders*1.0/Seg36mOrders end) Seg36mEmailOrderRatio,  
(case when EmailReceived=0 then 0 else ClickCnt*1.0/EmailReceived end) ClickRatio,  
round((datediff(month, IntlDateOrdered, getdate())-datediff(month, LastDateOrdered, getdate()))*1.0/LTDOrders,1) TTB  
,Cast(null as varchar(20)) as Segment  
,Getdate() as DMlastupdated  
into Datawarehouse.staging.tgc_upsell_RECC_IM_SEG  
from #final  
  
  
update Datawarehouse.staging.tgc_upsell_RECC_IM_SEG  
set ClickRatio = (case when ClickRatio>1 then 1 else ClickRatio end),  
OrderSourcePreference=(case when OrderSourcePreference not in ('P','W','M') then 'X' else OrderSourcePreference end),  
MediaFormatPreference=(case when MediaFormatPreference not in ('C','D','DL','DV') then 'X' else MediaFormatPreference end),  
CustomerSegmentFnlPrior=(case when CustomerSegmentFnlPrior not in ('Active_Multi','Inactive_Multi') then 'Else' else CustomerSegmentFnlPrior end)  
  
  
--alter table Datawarehouse.staging.tgc_upsell_RECC_IM_SEG  
--add Segment varchar(20)  
  
  
update a  
set Segment=  
(case  when (RecencyMonths>=16.5 and CustomerSegmentFnlPrior='Else') then 'SEGIMAHMH1'  
when (RecencyMonths>=16.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=23.5 and FlagMail< 0.5) then 'SEGIMAHMH2'  
when (RecencyMonths>=16.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=23.5 and FlagMail>=0.5 and age>=86.5) then 'SEGIMAHMH3'  
when (RecencyMonths>=16.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=23.5 and FlagMail>=0.5 and age< 86.5 and TenureMonths< 76.5) then 'SEGIMAHMH4'  
when (RecencyMonths>=16.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=23.5 and FlagMail>=0.5 and age< 86.5 and TenureMonths>=76.5 and TTB>=11.45) then 'SEGIMAHMH5'  
when (RecencyMonths>=16.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=23.5 and FlagMail>=0.5 and age< 86.5 and TenureMonths>=76.5 and TTB< 11.45 and RecencyMonths>=32.5) then 'SEGIMAHMH6'  
when (RecencyMonths>=16.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=23.5 and FlagMail>=0.5 and age< 86.5 and TenureMonths>=76.5 and TTB< 11.45 and RecencyMonths< 32.5 and Seg36mSales< 84.82) then 'SEGIMAHMH7'  
when (RecencyMonths>=16.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=23.5 and FlagMail>=0.5 and age< 86.5 and TenureMonths>=76.5 and TTB< 11.45 and RecencyMonths< 32.5 and Seg36mSales>=84.82) then 'SEGIMAHMH8'  
when (RecencyMonths>=16.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 23.5 and FlagMail< 0.5) then 'SEGIMAHMH9'  
when (RecencyMonths>=16.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 23.5 and FlagMail>=0.5 and Seg36mSales< 127.4) then 'SEGIMAHMH10'  
when (RecencyMonths>=16.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 23.5 and FlagMail>=0.5 and Seg36mSales>=127.4 and TenureMonths< 50.5 and age< 51.5) then 'SEGIMAHMH11'  
when (RecencyMonths>=16.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 23.5 and FlagMail>=0.5 and Seg36mSales>=127.4 and TenureMonths< 50.5 and age>=51.5 and ClickRatio>=0.447) then 'SEGIMAHMH12'  
when (RecencyMonths>=16.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 23.5 and FlagMail>=0.5 and Seg36mSales>=127.4 and TenureMonths< 50.5 and age>=51.5 and ClickRatio< 0.447 and Seg36mEmailOrderRatio>=0.6202) then 
'SEGIMAHMH13'  
when (RecencyMonths>=16.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 23.5 and FlagMail>=0.5 and Seg36mSales>=127.4 and TenureMonths< 50.5 and age>=51.5 and ClickRatio< 0.447 and Seg36mEmailOrderRatio< 0.6202) then 
'SEGIMAHMH14'  
when (RecencyMonths>=16.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 23.5 and FlagMail>=0.5 and Seg36mSales>=127.4 and TenureMonths>=50.5 and TTB>=15.45) then 'SEGIMAHMH15'  
when (RecencyMonths>=16.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 23.5 and FlagMail>=0.5 and Seg36mSales>=127.4 and TenureMonths>=50.5 and TTB< 15.45) then 'SEGIMAHMH16'  
when (RecencyMonths< 16.5 and Seg36mOrders< 3.5 and CustomerSegmentFnlPrior='Else' and RecencyMonths>=11.5) then 'SEGIMAHMH17'  
when (RecencyMonths< 16.5 and Seg36mOrders< 3.5 and CustomerSegmentFnlPrior='Else' and RecencyMonths< 11.5 and ClickRatio< 0.007042) then 'SEGIMAHMH18'  
when (RecencyMonths< 16.5 and Seg36mOrders< 3.5 and CustomerSegmentFnlPrior='Else' and RecencyMonths< 11.5 and ClickRatio>=0.007042 and FlagEmail< 0.5) then 'SEGIMAHMH19'  
when (RecencyMonths< 16.5 and Seg36mOrders< 3.5 and CustomerSegmentFnlPrior='Else' and RecencyMonths< 11.5 and ClickRatio>=0.007042 and FlagEmail>=0.5) then 'SEGIMAHMH20'  
when (RecencyMonths< 16.5 and Seg36mOrders< 3.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi')) then 'SEGIMAHMH21'  
when (RecencyMonths< 16.5 and Seg36mOrders>=3.5) then 'SEGIMAHMH22'  
else 'NULL' end)  
from Datawarehouse.staging.tgc_upsell_RECC_IM_SEG a  
where a.PreferredCategory2 in ('AH','MH')  
  
  
  
update a  
set Segment=  
(case when (Seg36mOrders< 3.5 and CustomerSegmentFnlPrior='Else' and RecencyMonths>=19.5) then 'SEGIMECPRHS1'  
when (Seg36mOrders< 3.5 and CustomerSegmentFnlPrior='Else' and RecencyMonths< 19.5 and ClickRatio< 0.007042) then 'SEGIMECPRHS2'  
when (Seg36mOrders< 3.5 and CustomerSegmentFnlPrior='Else' and RecencyMonths< 19.5 and ClickRatio>=0.007042 and Seg36mSales< 110.4) then 'SEGIMECPRHS3'  
when (Seg36mOrders< 3.5 and CustomerSegmentFnlPrior='Else' and RecencyMonths< 19.5 and ClickRatio>=0.007042 and Seg36mSales>=110.4) then 'SEGIMECPRHS4'  
when (Seg36mOrders< 3.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=18.5 and FlagMail< 0.5) then 'SEGIMECPRHS5'  
when (Seg36mOrders< 3.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=18.5 and FlagMail>=0.5 and TenureMonths< 67.5 and ClickRatio< 0.01419) then 'SEGIMECPRHS6'  
when (Seg36mOrders< 3.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=18.5 and FlagMail>=0.5 and TenureMonths< 67.5 and ClickRatio>=0.01419 and ClickRatio>=0.5592) then 'SEGIMECPRHS7'  
when (Seg36mOrders< 3.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=18.5 and FlagMail>=0.5 and TenureMonths< 67.5 and ClickRatio>=0.01419 and ClickRatio< 0.5592) then 'SEGIMECPRHS8'  
when (Seg36mOrders< 3.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=18.5 and FlagMail>=0.5 and TenureMonths>=67.5 and RecencyMonths>=31.5) then 'SEGIMECPRHS9'  
when (Seg36mOrders< 3.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=18.5 and FlagMail>=0.5 and TenureMonths>=67.5 and RecencyMonths< 31.5 and TTB>=22.4) then 'SEGIMECPRHS10'  
when (Seg36mOrders< 3.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=18.5 and FlagMail>=0.5 and TenureMonths>=67.5 and RecencyMonths< 31.5 and TTB< 22.4 and Seg36mSales< 74.93) then 'SEGIMECPRHS11'  
when (Seg36mOrders< 3.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=18.5 and FlagMail>=0.5 and TenureMonths>=67.5 and RecencyMonths< 31.5 and TTB< 22.4 and Seg36mSales>=74.93) then 'SEGIMECPRHS12'  
when (Seg36mOrders< 3.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 18.5 and TenureMonths< 65.5 and Seg36mSales< 189.7 and ClickRatio< 0.02837 and TenureMonths< 39.5) then 'SEGIMECPRHS13'  
when (Seg36mOrders< 3.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 18.5 and TenureMonths< 65.5 and Seg36mSales< 189.7 and ClickRatio< 0.02837 and TenureMonths>=39.5) then 'SEGIMECPRHS14'  
when (Seg36mOrders< 3.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 18.5 and TenureMonths< 65.5 and Seg36mSales< 189.7 and ClickRatio>=0.02837) then 'SEGIMECPRHS15'  
when (Seg36mOrders< 3.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 18.5 and TenureMonths< 65.5 and Seg36mSales>=189.7) then 'SEGIMECPRHS16'  
when (Seg36mOrders< 3.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 18.5 and TenureMonths>=65.5) then 'SEGIMECPRHS17'  
when (Seg36mOrders>=3.5 and RecencyMonths>=16.5 and TenureMonths< 41.5 and TTB< 1.85) then 'SEGIMECPRHS18'  
when (Seg36mOrders>=3.5 and RecencyMonths>=16.5 and TenureMonths< 41.5 and TTB>=1.85) then 'SEGIMECPRHS19'  
when (Seg36mOrders>=3.5 and RecencyMonths>=16.5 and TenureMonths>=41.5) then 'SEGIMECPRHS20'  
when (Seg36mOrders>=3.5 and RecencyMonths< 16.5) then 'SEGIMECPRHS21'  
else 'NULL' end)  
from Datawarehouse.staging.tgc_upsell_RECC_IM_SEG a  
where a.PreferredCategory2 in ('EC','PR','HS')  
  
  
  
update a  
set Segment=  
(case when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior='Else' and RecencyMonths>=13.5) then 'SEGIMFW1'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior='Else' and RecencyMonths< 13.5 and ClickRatio< 0.007042) then 'SEGIMFW2'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior='Else' and RecencyMonths< 13.5 and ClickRatio>=0.007042 and FlagEmail< 0.5) then 'SEGIMFW3'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior='Else' and RecencyMonths< 13.5 and ClickRatio>=0.007042 and FlagEmail>=0.5) then 'SEGIMFW4'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=21.5) then 'SEGIMFW5'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 21.5 and Seg36mSales< 128.4 and RecencyMonths>=11.5) then 'SEGIMFW6'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 21.5 and Seg36mSales< 128.4 and RecencyMonths< 11.5) then 'SEGIMFW7'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 21.5 and Seg36mSales>=128.4 and RecencyMonths>=12.5 and TenureMonths< 53.5) then 'SEGIMFW8'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 21.5 and Seg36mSales>=128.4 and RecencyMonths>=12.5 and TenureMonths>=53.5 and TTB>=12.15) then 'SEGIMFW9'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 21.5 and Seg36mSales>=128.4 and RecencyMonths>=12.5 and TenureMonths>=53.5 and TTB< 12.15) then 'SEGIMFW10'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 21.5 and Seg36mSales>=128.4 and RecencyMonths< 12.5) then 'SEGIMFW11'  
when (Seg36mOrders>=2.5 and Seg36mOrders< 4.5 and RecencyMonths>=14.5 and TenureMonths< 35.5) then 'SEGIMFW12'  
when (Seg36mOrders>=2.5 and Seg36mOrders< 4.5 and RecencyMonths>=14.5 and TenureMonths>=35.5 and Seg36mSales< 269.6 and ClickRatio< 0.007042 and TenureMonths< 65.5) then 'SEGIMFW13'  
when (Seg36mOrders>=2.5 and Seg36mOrders< 4.5 and RecencyMonths>=14.5 and TenureMonths>=35.5 and Seg36mSales< 269.6 and ClickRatio< 0.007042 and TenureMonths>=65.5) then 'SEGIMFW14'  
when (Seg36mOrders>=2.5 and Seg36mOrders< 4.5 and RecencyMonths>=14.5 and TenureMonths>=35.5 and Seg36mSales< 269.6 and ClickRatio>=0.007042) then 'SEGIMFW15'  
when (Seg36mOrders>=2.5 and Seg36mOrders< 4.5 and RecencyMonths>=14.5 and TenureMonths>=35.5 and Seg36mSales>=269.6) then 'SEGIMFW16'  
when (Seg36mOrders>=2.5 and Seg36mOrders< 4.5 and RecencyMonths< 14.5 and TenureMonths< 44.5 and Seg36mSales< 214.8 and ClickRatio< 0.01419) then 'SEGIMFW17'  
when (Seg36mOrders>=2.5 and Seg36mOrders< 4.5 and RecencyMonths< 14.5 and TenureMonths< 44.5 and Seg36mSales< 214.8 and ClickRatio>=0.01419) then 'SEGIMFW18'  
when (Seg36mOrders>=2.5 and Seg36mOrders< 4.5 and RecencyMonths< 14.5 and TenureMonths< 44.5 and Seg36mSales>=214.8) then 'SEGIMFW19'  
when (Seg36mOrders>=2.5 and Seg36mOrders< 4.5 and RecencyMonths< 14.5 and TenureMonths>=44.5) then 'SEGIMFW20'  
when (Seg36mOrders>=2.5 and Seg36mOrders>=4.5) then 'SEGIMFW21'  
else 'NULL' end)  
from Datawarehouse.staging.tgc_upsell_RECC_IM_SEG a  
where a.PreferredCategory2 in ('FW')  
  
  
  
update a  
set Segment=  
(case when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior='Else') then 'SEGIMLITPH1'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=25.5 and FlagMail< 0.5) then 'SEGIMLITPH2'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=25.5 and FlagMail>=0.5 and age>=82.5) then 'SEGIMLITPH3'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=25.5 and FlagMail>=0.5 and age< 82.5 and FlagEmail< 0.5) then 'SEGIMLITPH4'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=25.5 and FlagMail>=0.5 and age< 82.5 and FlagEmail>=0.5 and ClickRatio< 0.01482) then 'SEGIMLITPH5'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=25.5 and FlagMail>=0.5 and age< 82.5 and FlagEmail>=0.5 and ClickRatio>=0.01482) then 'SEGIMLITPH6'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 25.5 and Seg36mSales< 110.9 and FlagMail< 0.5) then 'SEGIMLITPH7'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 25.5 and Seg36mSales< 110.9 and FlagMail>=0.5 and RecencyMonths>=12.5 and Seg36mSales< 50.64) then 'SEGIMLITPH8'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 25.5 and Seg36mSales< 110.9 and FlagMail>=0.5 and RecencyMonths>=12.5 and Seg36mSales>=50.64 and TenureMonths< 87.5) then 'SEGIMLITPH9'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 25.5 and Seg36mSales< 110.9 and FlagMail>=0.5 and RecencyMonths>=12.5 and Seg36mSales>=50.64 and TenureMonths>=87.5) then 'SEGIMLITPH10'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 25.5 and Seg36mSales< 110.9 and FlagMail>=0.5 and RecencyMonths< 12.5) then 'SEGIMLITPH11'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 25.5 and Seg36mSales>=110.9 and FlagMail< 0.5) then 'SEGIMLITPH12'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 25.5 and Seg36mSales>=110.9 and FlagMail>=0.5) then 'SEGIMLITPH13'  
when (Seg36mOrders>=2.5 and RecencyMonths>=17.5 and RecencyMonths>=22.5 and TTB< 1.75) then 'SEGIMLITPH14'  
when (Seg36mOrders>=2.5 and RecencyMonths>=17.5 and RecencyMonths>=22.5 and TTB>=1.75 and RecencyMonths>=29.5) then 'SEGIMLITPH15'  
when (Seg36mOrders>=2.5 and RecencyMonths>=17.5 and RecencyMonths>=22.5 and TTB>=1.75 and RecencyMonths< 29.5 and FlagEmail< 0.5) then 'SEGIMLITPH16'  
when (Seg36mOrders>=2.5 and RecencyMonths>=17.5 and RecencyMonths>=22.5 and TTB>=1.75 and RecencyMonths< 29.5 and FlagEmail>=0.5) then 'SEGIMLITPH17'  
when (Seg36mOrders>=2.5 and RecencyMonths>=17.5 and RecencyMonths< 22.5 and TenureMonths< 49.5 and ClickRatio< 0.01527 and Seg36mSales< 409.8) then 'SEGIMLITPH18'  
when (Seg36mOrders>=2.5 and RecencyMonths>=17.5 and RecencyMonths< 22.5 and TenureMonths< 49.5 and ClickRatio< 0.01527 and Seg36mSales>=409.8) then 'SEGIMLITPH19'  
when (Seg36mOrders>=2.5 and RecencyMonths>=17.5 and RecencyMonths< 22.5 and TenureMonths< 49.5 and ClickRatio>=0.01527) then 'SEGIMLITPH20'  
when (Seg36mOrders>=2.5 and RecencyMonths>=17.5 and RecencyMonths< 22.5 and TenureMonths>=49.5) then 'SEGIMLITPH21'  
when (Seg36mOrders>=2.5 and RecencyMonths< 17.5) then 'SEGIMLITPH22'  
else 'NULL' end)  
from Datawarehouse.staging.tgc_upsell_RECC_IM_SEG a  
where a.PreferredCategory2 in ('LIT','PH')  
  
  
update a  
set Segment=  
(case when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior='Else' and RecencyMonths>=23.5) then 'SEGIMRL1'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior='Else' and RecencyMonths< 23.5 and FlagMail< 0.5) then 'SEGIMRL2'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior='Else' and RecencyMonths< 23.5 and FlagMail>=0.5 and ClickRatio< 0.01399) then 'SEGIMRL3'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior='Else' and RecencyMonths< 23.5 and FlagMail>=0.5 and ClickRatio>=0.01399 and FlagEmail< 0.5) then 'SEGIMRL4'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior='Else' and RecencyMonths< 23.5 and FlagMail>=0.5 and ClickRatio>=0.01399 and FlagEmail>=0.5) then 'SEGIMRL5'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=20.5 and FlagMail< 0.5) then 'SEGIMRL6'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=20.5 and FlagMail>=0.5 and Seg36mSales< 125.6) then 'SEGIMRL7'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=20.5 and FlagMail>=0.5 and Seg36mSales>=125.6 and RecencyMonths>=23.5 and TenureMonths< 94.5) then 'SEGIMRL8'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=20.5 and FlagMail>=0.5 and Seg36mSales>=125.6 and RecencyMonths>=23.5 and TenureMonths>=94.5 and FlagEmail< 0.5) then 'SEGIMRL9'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=20.5 and FlagMail>=0.5 and Seg36mSales>=125.6 and RecencyMonths>=23.5 and TenureMonths>=94.5 and FlagEmail>=0.5) then 'SEGIMRL10'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=20.5 and FlagMail>=0.5 and Seg36mSales>=125.6 and RecencyMonths< 23.5) then 'SEGIMRL11'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 20.5) then 'SEGIMRL12'  
when (Seg36mOrders>=2.5 and RecencyMonths>=16.5 and TenureMonths< 45.5 and RecencyMonths>=22.5) then 'SEGIMRL13'  
when (Seg36mOrders>=2.5 and RecencyMonths>=16.5 and TenureMonths< 45.5 and RecencyMonths< 22.5 and Seg36mSales< 284.7 and Seg36mOrders< 3.5) then 'SEGIMRL14'  
when (Seg36mOrders>=2.5 and RecencyMonths>=16.5 and TenureMonths< 45.5 and RecencyMonths< 22.5 and Seg36mSales< 284.7 and Seg36mOrders>=3.5) then 'SEGIMRL15'  
when (Seg36mOrders>=2.5 and RecencyMonths>=16.5 and TenureMonths< 45.5 and RecencyMonths< 22.5 and Seg36mSales>=284.7 and TTB< 1.35) then 'SEGIMRL16'  
when (Seg36mOrders>=2.5 and RecencyMonths>=16.5 and TenureMonths< 45.5 and RecencyMonths< 22.5 and Seg36mSales>=284.7 and TTB>=1.35) then 'SEGIMRL17'  
when (Seg36mOrders>=2.5 and RecencyMonths>=16.5 and TenureMonths>=45.5 and age>=76.5) then 'SEGIMRL18'  
when (Seg36mOrders>=2.5 and RecencyMonths>=16.5 and TenureMonths>=45.5 and age< 76.5) then 'SEGIMRL19'  
when (Seg36mOrders>=2.5 and RecencyMonths< 16.5) then 'SEGIMRL20'  
else 'NULL' end)  
from Datawarehouse.staging.tgc_upsell_RECC_IM_SEG a  
where a.PreferredCategory2 in ('RL')  
  
  
update a  
set Segment=  
(case when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior='Else' and RecencyMonths>=17.5) then 'SEGIMSCIMTH1'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior='Else' and RecencyMonths< 17.5 and ClickRatio< 0.01399 and Seg36mSales< 194.8) then 'SEGIMSCIMTH2'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior='Else' and RecencyMonths< 17.5 and ClickRatio< 0.01399 and Seg36mSales>=194.8 and age< 55.5) then 'SEGIMSCIMTH3'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior='Else' and RecencyMonths< 17.5 and ClickRatio< 0.01399 and Seg36mSales>=194.8 and age>=55.5 and Gender in ('F','U')) then 'SEGIMSCIMTH4'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior='Else' and RecencyMonths< 17.5 and ClickRatio< 0.01399 and Seg36mSales>=194.8 and age>=55.5 and Gender='M') then 'SEGIMSCIMTH5'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior='Else' and RecencyMonths< 17.5 and ClickRatio>=0.01399 and FlagEmail< 0.5 and Seg36mSales< 219.8) then 'SEGIMSCIMTH6'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior='Else' and RecencyMonths< 17.5 and ClickRatio>=0.01399 and FlagEmail< 0.5 and Seg36mSales>=219.8) then 'SEGIMSCIMTH7'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior='Else' and RecencyMonths< 17.5 and ClickRatio>=0.01399 and FlagEmail>=0.5) then 'SEGIMSCIMTH8'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=21.5 and FlagMail< 0.5) then 'SEGIMSCIMTH9'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=21.5 and FlagMail>=0.5 and RecencyMonths>=26.5) then 'SEGIMSCIMTH10'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=21.5 and FlagMail>=0.5 and RecencyMonths< 26.5 and TenureMonths< 76.5) then 'SEGIMSCIMTH11'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=21.5 and FlagMail>=0.5 and RecencyMonths< 26.5 and TenureMonths>=76.5 and Seg36mSales< 107.4 and OrderSourcePreference in ('W','X')) then 'SEGIMSC
IMTH12'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=21.5 and FlagMail>=0.5 and RecencyMonths< 26.5 and TenureMonths>=76.5 and Seg36mSales< 107.4 and OrderSourcePreference in ('M','P')) then 'SEGIMSCI
MTH13'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=21.5 and FlagMail>=0.5 and RecencyMonths< 26.5 and TenureMonths>=76.5 and Seg36mSales>=107.4) then 'SEGIMSCIMTH14'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 21.5 and Seg36mSales< 65.94 and TenureMonths< 99.5) then 'SEGIMSCIMTH15'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 21.5 and Seg36mSales< 65.94 and TenureMonths>=99.5) then 'SEGIMSCIMTH16'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 21.5 and Seg36mSales>=65.94 and FlagMail< 0.5) then 'SEGIMSCIMTH17'  
when (Seg36mOrders< 2.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 21.5 and Seg36mSales>=65.94 and FlagMail>=0.5) then 'SEGIMSCIMTH18'  
when (Seg36mOrders>=2.5 and RecencyMonths>=17.5 and TTB< 2.05) then 'SEGIMSCIMTH19'  
when (Seg36mOrders>=2.5 and RecencyMonths>=17.5 and TTB>=2.05 and RecencyMonths>=25.5) then 'SEGIMSCIMTH20'  
when (Seg36mOrders>=2.5 and RecencyMonths>=17.5 and TTB>=2.05 and RecencyMonths< 25.5 and TenureMonths< 40.5 and ClickRatio< 0.0146) then 'SEGIMSCIMTH21'  
when (Seg36mOrders>=2.5 and RecencyMonths>=17.5 and TTB>=2.05 and RecencyMonths< 25.5 and TenureMonths< 40.5 and ClickRatio>=0.0146) then 'SEGIMSCIMTH22'  
when (Seg36mOrders>=2.5 and RecencyMonths>=17.5 and TTB>=2.05 and RecencyMonths< 25.5 and TenureMonths>=40.5) then 'SEGIMSCIMTH23'  
when (Seg36mOrders>=2.5 and RecencyMonths< 17.5) then 'SEGIMSCIMTH24'  
else 'NULL' end)  
from Datawarehouse.staging.tgc_upsell_RECC_IM_SEG a  
where a.PreferredCategory2 in ('SCI','MTH')  
  
  
  
 update a  
set Segment=  
(case when (RecencyMonths>=16.5 and CustomerSegmentFnlPrior='Else') then 'SEGIMVAMSC1'  
when (RecencyMonths>=16.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=25.5 and FlagMail< 0.5) then 'SEGIMVAMSC2'  
when (RecencyMonths>=16.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=25.5 and FlagMail>=0.5 and ClickRatio>=0.5165) then 'SEGIMVAMSC3'  
when (RecencyMonths>=16.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=25.5 and FlagMail>=0.5 and ClickRatio< 0.5165 and ClickRatio< 0.007042 and TenureMonths< 80.5) then 'SEGIMVAMSC4'  
when (RecencyMonths>=16.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=25.5 and FlagMail>=0.5 and ClickRatio< 0.5165 and ClickRatio< 0.007042 and TenureMonths>=80.5 and TTB>=11.55) then 'SEGIMVAMSC5'  
when (RecencyMonths>=16.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=25.5 and FlagMail>=0.5 and ClickRatio< 0.5165 and ClickRatio< 0.007042 and TenureMonths>=80.5 and TTB< 11.55) then 'SEGIMVAMSC6'  
when (RecencyMonths>=16.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths>=25.5 and FlagMail>=0.5 and ClickRatio< 0.5165 and ClickRatio>=0.007042) then 'SEGIMVAMSC7'  
when (RecencyMonths>=16.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 25.5 and FlagMail< 0.5) then 'SEGIMVAMSC8'  
when (RecencyMonths>=16.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 25.5 and FlagMail>=0.5 and TenureMonths< 58.5 and ClickRatio< 0.01439 and TenureMonths< 34.5) then 'SEGIMVAMSC9'  
when (RecencyMonths>=16.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 25.5 and FlagMail>=0.5 and TenureMonths< 58.5 and ClickRatio< 0.01439 and TenureMonths>=34.5 and TTB>=4.55) then 'SEGIMVAMSC10'  
when (RecencyMonths>=16.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 25.5 and FlagMail>=0.5 and TenureMonths< 58.5 and ClickRatio< 0.01439 and TenureMonths>=34.5 and TTB< 4.55) then 'SEGIMVAMSC11'  
when (RecencyMonths>=16.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 25.5 and FlagMail>=0.5 and TenureMonths< 58.5 and ClickRatio>=0.01439) then 'SEGIMVAMSC12'  
when (RecencyMonths>=16.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 25.5 and FlagMail>=0.5 and TenureMonths>=58.5 and TTB>=13.75 and TenureMonths< 145.5 and RecencyMonths>=19.5) then 'SEGIMVAMSC13'  
when (RecencyMonths>=16.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 25.5 and FlagMail>=0.5 and TenureMonths>=58.5 and TTB>=13.75 and TenureMonths< 145.5 and RecencyMonths< 19.5) then 'SEGIMVAMSC14'  
when (RecencyMonths>=16.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 25.5 and FlagMail>=0.5 and TenureMonths>=58.5 and TTB>=13.75 and TenureMonths>=145.5) then 'SEGIMVAMSC15'  
when (RecencyMonths>=16.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 25.5 and FlagMail>=0.5 and TenureMonths>=58.5 and TTB< 13.75 and age>=80.5) then 'SEGIMVAMSC16'  
when (RecencyMonths>=16.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi') and RecencyMonths< 25.5 and FlagMail>=0.5 and TenureMonths>=58.5 and TTB< 13.75 and age< 80.5) then 'SEGIMVAMSC17'  
when (RecencyMonths< 16.5 and CustomerSegmentFnlPrior='Else' and RecencyMonths>=14.5) then 'SEGIMVAMSC18'  
when (RecencyMonths< 16.5 and CustomerSegmentFnlPrior='Else' and RecencyMonths< 14.5 and Seg36mSales< 87.64) then 'SEGIMVAMSC19'  
when (RecencyMonths< 16.5 and CustomerSegmentFnlPrior='Else' and RecencyMonths< 14.5 and Seg36mSales>=87.64 and age>=71.5) then 'SEGIMVAMSC20'  
when (RecencyMonths< 16.5 and CustomerSegmentFnlPrior='Else' and RecencyMonths< 14.5 and Seg36mSales>=87.64 and age< 71.5 and age< 66.5 and ClickRatio< 0.01419) then 'SEGIMVAMSC21'  
when (RecencyMonths< 16.5 and CustomerSegmentFnlPrior='Else' and RecencyMonths< 14.5 and Seg36mSales>=87.64 and age< 71.5 and age< 66.5 and ClickRatio>=0.01419) then 'SEGIMVAMSC22'  
when (RecencyMonths< 16.5 and CustomerSegmentFnlPrior='Else' and RecencyMonths< 14.5 and Seg36mSales>=87.64 and age< 71.5 and age>=66.5) then 'SEGIMVAMSC23'  
when (RecencyMonths< 16.5 and CustomerSegmentFnlPrior in ('Active_Multi','Inactive_Multi')) then 'SEGIMVAMSC24'  
else 'NULL' end)  
from Datawarehouse.staging.tgc_upsell_RECC_IM_SEG a  
where a.PreferredCategory2 in ('VA','MSC')  
  
  
update a  
set Segment='SEGIMNULL'  
from Datawarehouse.staging.tgc_upsell_RECC_IM_SEG a  
where Segment is null or Segment='NULL'  
--(6697 row(s) affected)  
  
--find all the segments whose counts are less than 100  
--and assign them into NULL segment  
--drop table #Segment  
select Segment, count(*) count  
into #Segment  
from Datawarehouse.staging.tgc_upsell_RECC_IM_SEG  
group by Segment  
having count(*) < 100  
--(4 row(s) affected)  
  
update a  
set Segment='SEGIMNULL'  
from Datawarehouse.staging.tgc_upsell_RECC_IM_SEG a  
where a.Segment in (select Segment from #Segment)  
  
  
--select top 1000 * from  
--Datawarehouse.staging.tgc_upsell_RECC_IM_SEG  
  
select count(*), Segment  
from Datawarehouse.staging.tgc_upsell_RECC_IM_SEG  
group by Segment  
order by Segment  
  
  
  
  
  
  
  
  
End
GO
