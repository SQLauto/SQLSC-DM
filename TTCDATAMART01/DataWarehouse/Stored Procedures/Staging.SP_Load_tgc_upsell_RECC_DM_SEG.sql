SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [Staging].[SP_Load_tgc_upsell_RECC_DM_SEG]  
as  
Begin  
  
/****************************Create base table for  DeepSwamp Multi's*********************************/  
  
--DeepSwamp Multis  
  
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
where NewSeg in (31,34,37)  
and comboid not like '%highschool%') t1  
join  
(select distinct CustomerID from  
DataWarehouse.Marketing.DMPurchaseOrders  
where BillingCountryCode in ('US','USA')  
--and convert(date,DateOrdered) < '6/29/2017'  
) t2 on  
t1.CustomerID=t2.CustomerID  
--(632715 row(s) affected)  
  
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
t3.NetOrderAmount LastSales,  
t3.TotalCourseQuantity LastUnits,  
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
t3.LastSales,  
t3.LastUnits,  
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
ClickCnt = (case when ClickCnt is null then 0 else ClickCnt end)   
from  
#final t1  
left outer join  
DataWarehouse.Mapping.GENDER_LOOKUP t2 on  
upper(t1.FirstName)=upper(t2.FirstName)  
  
  
  
If object_id ('Datawarehouse.staging.tgc_upsell_RECC_DM_SEG') is not null  
Drop table Datawarehouse.staging.tgc_upsell_RECC_DM_SEG  
  
  
select CustomerID,  
(case when Gender is not null then Gender else 'U' end) Gender,  
LastSales,  
LastUnits,  
LTDOrders,  
MediaFormatPreference,  
OrderSourcePreference,  
CustomerSegmentFnlPrior,  
FlagEmail,  
FlagMail,  
ClickCnt,  
convert(int, round(datediff(day,DateOfBirth,getdate())/365.25-0.5,0)) age,  
datediff(month, LastDateOrdered, getdate()) RecencyMonths,  
Cast(null as varchar(20)) as Segment,  
getdate() as DMLastupdated  
into Datawarehouse.staging.tgc_upsell_RECC_DM_SEG  
from #final  
  
--alter table Datawarehouse.staging.tgc_upsell_RECC_DM_SEG  
--add Segment varchar(20)  
  
  
update a  
set Segment=  
(case when (RecencyMonths>=75.5 and FlagMail< 0.5) then 'SEGDM1'  
when (RecencyMonths>=75.5 and FlagMail>=0.5 and RecencyMonths>=130.5) then 'SEGDM2'  
when (RecencyMonths>=75.5 and FlagMail>=0.5 and RecencyMonths< 130.5 and Gender='U') then 'SEGDM3'  
when (RecencyMonths>=75.5 and FlagMail>=0.5 and RecencyMonths< 130.5 and Gender in ('F','M') and age< 55.5 and LTDOrders< 2.5) then 'SEGDM4'  
when (RecencyMonths>=75.5 and FlagMail>=0.5 and RecencyMonths< 130.5 and Gender in ('F','M') and age< 55.5 and LTDOrders>=2.5 and FlagEmail< 0.5) then 'SEGDM5'  
when (RecencyMonths>=75.5 and FlagMail>=0.5 and RecencyMonths< 130.5 and Gender in ('F','M') and age< 55.5 and LTDOrders>=2.5 and FlagEmail>=0.5) then 'SEGDM6'  
when (RecencyMonths>=75.5 and FlagMail>=0.5 and RecencyMonths< 130.5 and Gender in ('F','M') and age>=55.5 and age>=84.5) then 'SEGDM7'  
when (RecencyMonths>=75.5 and FlagMail>=0.5 and RecencyMonths< 130.5 and Gender in ('F','M') and age>=55.5 and age< 84.5 and RecencyMonths>=103.5) then 'SEGDM8'  
when (RecencyMonths>=75.5 and FlagMail>=0.5 and RecencyMonths< 130.5 and Gender in ('F','M') and age>=55.5 and age< 84.5 and RecencyMonths< 103.5 and LTDOrders< 3.5) then 'SEGDM9'  
when (RecencyMonths>=75.5 and FlagMail>=0.5 and RecencyMonths< 130.5 and Gender in ('F','M') and age>=55.5 and age< 84.5 and RecencyMonths< 103.5 and LTDOrders>=3.5 and ClickCnt>=3.5 and CustomerSegmentFnlPrior in ('Active_Multi','Else')) then 'SEGDM10'  
when (RecencyMonths>=75.5 and FlagMail>=0.5 and RecencyMonths< 130.5 and Gender in ('F','M') and age>=55.5 and age< 84.5 and RecencyMonths< 103.5 and LTDOrders>=3.5 and ClickCnt>=3.5 and CustomerSegmentFnlPrior='Inactive_Multi') then 'SEGDM11'  
when (RecencyMonths>=75.5 and FlagMail>=0.5 and RecencyMonths< 130.5 and Gender in ('F','M') and age>=55.5 and age< 84.5 and RecencyMonths< 103.5 and LTDOrders>=3.5 and ClickCnt< 3.5) then 'SEGDM12'  
when (RecencyMonths< 75.5 and FlagMail< 0.5 and RecencyMonths>=49.5) then 'SEGDM13'  
when (RecencyMonths< 75.5 and FlagMail< 0.5 and RecencyMonths< 49.5 and LTDOrders< 3.5) then 'SEGDM14'  
when (RecencyMonths< 75.5 and FlagMail< 0.5 and RecencyMonths< 49.5 and LTDOrders>=3.5 and LTDOrders< 6.5) then 'SEGDM15'  
when (RecencyMonths< 75.5 and FlagMail< 0.5 and RecencyMonths< 49.5 and LTDOrders>=3.5 and LTDOrders>=6.5) then 'SEGDM16'  
when (RecencyMonths< 75.5 and FlagMail>=0.5 and LTDOrders< 2.5 and age< 51.5 and age< 42.5) then 'SEGDM17'  
when (RecencyMonths< 75.5 and FlagMail>=0.5 and LTDOrders< 2.5 and age< 51.5 and age>=42.5 and RecencyMonths>=45.5) then 'SEGDM18'  
when (RecencyMonths< 75.5 and FlagMail>=0.5 and LTDOrders< 2.5 and age< 51.5 and age>=42.5 and RecencyMonths< 45.5) then 'SEGDM19'  
when (RecencyMonths< 75.5 and FlagMail>=0.5 and LTDOrders< 2.5 and age>=51.5 and RecencyMonths>=58.5) then 'SEGDM20'  
when (RecencyMonths< 75.5 and FlagMail>=0.5 and LTDOrders< 2.5 and age>=51.5 and RecencyMonths< 58.5 and LTDOrders< 1.5) then 'SEGDM21'  
when (RecencyMonths< 75.5 and FlagMail>=0.5 and LTDOrders< 2.5 and age>=51.5 and RecencyMonths< 58.5 and LTDOrders>=1.5 and RecencyMonths>=42.5 and Gender in ('F','U') and age< 62.5) then 'SEGDM22'  
when (RecencyMonths< 75.5 and FlagMail>=0.5 and LTDOrders< 2.5 and age>=51.5 and RecencyMonths< 58.5 and LTDOrders>=1.5 and RecencyMonths>=42.5 and Gender in ('F','U') and age>=62.5) then 'SEGDM23'  
when (RecencyMonths< 75.5 and FlagMail>=0.5 and LTDOrders< 2.5 and age>=51.5 and RecencyMonths< 58.5 and LTDOrders>=1.5 and RecencyMonths>=42.5 and Gender='M') then 'SEGDM24'  
when (RecencyMonths< 75.5 and FlagMail>=0.5 and LTDOrders< 2.5 and age>=51.5 and RecencyMonths< 58.5 and LTDOrders>=1.5 and RecencyMonths< 42.5) then 'SEGDM25'  
when (RecencyMonths< 75.5 and FlagMail>=0.5 and LTDOrders>=2.5 and RecencyMonths>=40.5 and age>=84.5 and age>=89.5) then 'SEGDM26'  
when (RecencyMonths< 75.5 and FlagMail>=0.5 and LTDOrders>=2.5 and RecencyMonths>=40.5 and age>=84.5 and age< 89.5) then 'SEGDM27'  
when (RecencyMonths< 75.5 and FlagMail>=0.5 and LTDOrders>=2.5 and RecencyMonths>=40.5 and age< 84.5 and Gender in ('F','M')) then 'SEGDM28'  
when (RecencyMonths< 75.5 and FlagMail>=0.5 and LTDOrders>=2.5 and RecencyMonths< 40.5) then 'SEGDM29'  
else 'NULL' end)  
from Datawarehouse.staging.tgc_upsell_RECC_DM_SEG a  
  
update a  
set Segment='SEGDMNULL'  
from Datawarehouse.staging.tgc_upsell_RECC_DM_SEG a  
where Segment is null or Segment='NULL'  
--(118236 row(s) affected)  
  
  --find all the segments whose counts are less than 100  
--and assign them into NULL segment  
--drop table #Segment  
select Segment, count(*) count  
into #Segment  
from Datawarehouse.staging.tgc_upsell_RECC_DM_SEG  
group by Segment  
having count(*) < 100  
--(0 row(s) affected)  
  
update a  
set Segment='SEGIMNULL'  
from Datawarehouse.staging.tgc_upsell_RECC_DM_SEG a  
where a.Segment in (select Segment from #Segment)  
  
--select top 1000 * from  
--Datawarehouse.staging.tgc_upsell_RECC_DM_SEG  
  
select count(*), Segment  
from Datawarehouse.staging.tgc_upsell_RECC_DM_SEG  
group by Segment  
order by Segment  
  
  
  
  
End
GO
