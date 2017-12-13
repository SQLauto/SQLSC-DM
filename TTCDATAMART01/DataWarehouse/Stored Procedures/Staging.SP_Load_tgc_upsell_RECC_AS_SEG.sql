SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [Staging].[SP_Load_tgc_upsell_RECC_AS_SEG]  
as  
Begin  
  
/****************************Create base table for  Active Singles's*********************************/  
  
--Active Singles  
  
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
where NewSeg in (1,2,6,7)  
and comboid not like '%highschool%') t1  
join  
(select distinct CustomerID from  
DataWarehouse.Marketing.DMPurchaseOrders  
where BillingCountryCode in ('US','USA')  
--and convert(date,DateOrdered) < '6/29/2017'  
) t2 on  
t1.CustomerID=t2.CustomerID  
--(149429 row(s) affected)  
  
  
--Last Purchase  
--drop table #LastPurchase  
select t1.CustomerID,  
t3.DateOrdered LastDateOrdered,  
t3.NetOrderAmount LastSales,  
t3.TotalCourseQuantity Units  
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
  
  
-- drop table #EmailOpen  
select CustomerID,  
       count(*) OpenCnt  
       into #EmailOpen  
       from #EmailTemp  
       where DateStamp is not null  
       and ttype='open'  
       group by CustomerID  
  
  
  
-- drop table #final  
select t1.*,  
t3.LastDateOrdered,  
t3.LastSales,  
t3.Units,   
t8.ClickCnt,  
t9.OpenCnt,  
t10.EmailReceived  
into #final  
from   
#base t1  
left outer join  
#LastPurchase t3 on  
t1.CustomerID=t3.CustomerID  
left outer join  
#EmailClick t8 on  
t1.CustomerID=t8.CustomerID  
left outer join  
#EmailOpen t9 on  
t1.CustomerID=t9.CustomerID  
left outer join  
#EmailHistoryTmp t10 on  
t1.CustomerID=t10.CustomerID  
  
  
  
update t1   
set t1.Gender = (case when (t1.Gender not in ('F','M')) then t2.Gender else t1.Gender end),  
ClickCnt = (case when ClickCnt is null then 0 else ClickCnt end)   
from  
#final t1  
left outer join  
DataWarehouse.Mapping.GENDER_LOOKUP t2 on  
upper(t1.FirstName)=upper(t2.FirstName)  
  
  
  
  
if object_id('Datawarehouse.staging.tgc_upsell_RECC_AS_SEG') is not null  
drop table Datawarehouse.staging.tgc_upsell_RECC_AS_SEG  
  
select CustomerID,  
(case when Gender is not null then Gender else 'U' end) Gender,  
MediaFormatPreference,  
OrderSourcePreference,  
PreferredCategory2,  
FlagEmail,  
FlagMail,  
ClickCnt,  
convert(int, round(datediff(day,DateOfBirth,getdate())/365.25-0.5,0)) age,  
datediff(month, LastDateOrdered, getdate()) RecencyMonths,  
LastSales,  
Units,  
cast(null as varchar(20)) as Segment,  
Getdate() as DMlastupdated  
into Datawarehouse.staging.tgc_upsell_RECC_AS_SEG  
from #final  
  
update Datawarehouse.staging.tgc_upsell_RECC_AS_SEG  
set ClickCnt = (case when ClickCnt is null then 0 else ClickCnt end),  
OrderSourcePreference=(case when OrderSourcePreference not in ('P','W','M') then 'X' else OrderSourcePreference end),  
MediaFormatPreference=(case when MediaFormatPreference not in ('C','D','DL','DV') then 'X' else MediaFormatPreference end)  
  
  
--alter table Datawarehouse.staging.tgc_upsell_RECC_AS_SEG  
--add Segment varchar(20)  
  
update a  
set Segment=  
(case when (ClickCnt< 1.5 and RecencyMonths>=5.5 and LastSales< 87.43 and FlagMail< 0.5) then 'SEGAS1'  
when (ClickCnt< 1.5 and RecencyMonths>=5.5 and LastSales< 87.43 and FlagMail>=0.5 and Gender in ('F','U') and ClickCnt< 0.5) then 'SEGAS2'  
when (ClickCnt< 1.5 and RecencyMonths>=5.5 and LastSales< 87.43 and FlagMail>=0.5 and Gender in ('F','U') and ClickCnt>=0.5 and FlagEmail< 0.5) then 'SEGAS3'  
when (ClickCnt< 1.5 and RecencyMonths>=5.5 and LastSales< 87.43 and FlagMail>=0.5 and Gender in ('F','U') and ClickCnt>=0.5 and FlagEmail>=0.5) then 'SEGAS4'  
when (ClickCnt< 1.5 and RecencyMonths>=5.5 and LastSales< 87.43 and FlagMail>=0.5 and Gender='M' and age< 51.5) then 'SEGAS5'  
when (ClickCnt< 1.5 and RecencyMonths>=5.5 and LastSales< 87.43 and FlagMail>=0.5 and Gender='M' and age>=51.5 and FlagEmail< 0.5) then 'SEGAS6'  
when (ClickCnt< 1.5 and RecencyMonths>=5.5 and LastSales< 87.43 and FlagMail>=0.5 and Gender='M' and age>=51.5 and FlagEmail>=0.5 and ClickCnt< 0.5 and PreferredCategory2 in (' ','EC','FW','LIT','MSC','MTH','PR','RL','VA')) then 'SEGAS7'  
when (ClickCnt< 1.5 and RecencyMonths>=5.5 and LastSales< 87.43 and FlagMail>=0.5 and Gender='M' and age>=51.5 and FlagEmail>=0.5 and ClickCnt< 0.5 and PreferredCategory2 in ('AH','HS','MH','PH','SCI')) then 'SEGAS8'  
when (ClickCnt< 1.5 and RecencyMonths>=5.5 and LastSales< 87.43 and FlagMail>=0.5 and Gender='M' and age>=51.5 and FlagEmail>=0.5 and ClickCnt>=0.5) then 'SEGAS9'  
when (ClickCnt< 1.5 and RecencyMonths>=5.5 and LastSales>=87.43 and ClickCnt< 0.5 and FlagEmail< 0.5) then 'SEGAS10'  
when (ClickCnt< 1.5 and RecencyMonths>=5.5 and LastSales>=87.43 and ClickCnt< 0.5 and FlagEmail>=0.5 and LastSales< 208.5 and age< 53.5) then 'SEGAS11'  
when (ClickCnt< 1.5 and RecencyMonths>=5.5 and LastSales>=87.43 and ClickCnt< 0.5 and FlagEmail>=0.5 and LastSales< 208.5 and age>=53.5 and Gender in ('F','U')) then 'SEGAS12'  
when (ClickCnt< 1.5 and RecencyMonths>=5.5 and LastSales>=87.43 and ClickCnt< 0.5 and FlagEmail>=0.5 and LastSales< 208.5 and age>=53.5 and Gender='M' and PreferredCategory2 in ('EC','HS','MH','PH','RL')) then 'SEGAS13'  
when (ClickCnt< 1.5 and RecencyMonths>=5.5 and LastSales>=87.43 and ClickCnt< 0.5 and FlagEmail>=0.5 and LastSales< 208.5 and age>=53.5 and Gender='M' and PreferredCategory2 in ('AH','FW','LIT','MSC','MTH','PR','SCI','VA')) then 'SEGAS14'  
when (ClickCnt< 1.5 and RecencyMonths>=5.5 and LastSales>=87.43 and ClickCnt< 0.5 and FlagEmail>=0.5 and LastSales>=208.5) then 'SEGAS15'  
when (ClickCnt< 1.5 and RecencyMonths>=5.5 and LastSales>=87.43 and ClickCnt>=0.5 and FlagEmail< 0.5 and Gender in ('F','U')) then 'SEGAS16'  
when (ClickCnt< 1.5 and RecencyMonths>=5.5 and LastSales>=87.43 and ClickCnt>=0.5 and FlagEmail< 0.5 and Gender='M') then 'SEGAS17'  
when (ClickCnt< 1.5 and RecencyMonths>=5.5 and LastSales>=87.43 and ClickCnt>=0.5 and FlagEmail>=0.5) then 'SEGAS18'  
when (ClickCnt< 1.5 and RecencyMonths< 5.5 and RecencyMonths>=1.5 and ClickCnt< 0.5 and LastSales< 91.44 and Gender in ('F','U')) then 'SEGAS19'  
when (ClickCnt< 1.5 and RecencyMonths< 5.5 and RecencyMonths>=1.5 and ClickCnt< 0.5 and LastSales< 91.44 and Gender='M' and age< 61.5) then 'SEGAS20'  
when (ClickCnt< 1.5 and RecencyMonths< 5.5 and RecencyMonths>=1.5 and ClickCnt< 0.5 and LastSales< 91.44 and Gender='M' and age>=61.5 and age>=75.5) then 'SEGAS21'  
when (ClickCnt< 1.5 and RecencyMonths< 5.5 and RecencyMonths>=1.5 and ClickCnt< 0.5 and LastSales< 91.44 and Gender='M' and age>=61.5 and age< 75.5) then 'SEGAS22'  
when (ClickCnt< 1.5 and RecencyMonths< 5.5 and RecencyMonths>=1.5 and ClickCnt< 0.5 and LastSales>=91.44 and FlagEmail< 0.5) then 'SEGAS23'  
when (ClickCnt< 1.5 and RecencyMonths< 5.5 and RecencyMonths>=1.5 and ClickCnt< 0.5 and LastSales>=91.44 and FlagEmail>=0.5 and LastSales< 235.8 and Gender='F' and PreferredCategory2 in ('EC','HS','LIT','MH','SCI')) then 'SEGAS24'  
when (ClickCnt< 1.5 and RecencyMonths< 5.5 and RecencyMonths>=1.5 and ClickCnt< 0.5 and LastSales>=91.44 and FlagEmail>=0.5 and LastSales< 235.8 and Gender='F' and PreferredCategory2 in ('AH','FW','MSC','MTH','PH','PR','RL','VA')) then 'SEGAS25'  
when (ClickCnt< 1.5 and RecencyMonths< 5.5 and RecencyMonths>=1.5 and ClickCnt< 0.5 and LastSales>=91.44 and FlagEmail>=0.5 and LastSales< 235.8 and Gender in ('M','U')) then 'SEGAS26'  
when (ClickCnt< 1.5 and RecencyMonths< 5.5 and RecencyMonths>=1.5 and ClickCnt< 0.5 and LastSales>=91.44 and FlagEmail>=0.5 and LastSales>=235.8) then 'SEGAS27'  
when (ClickCnt< 1.5 and RecencyMonths< 5.5 and RecencyMonths>=1.5 and ClickCnt>=0.5 and FlagEmail< 0.5 and LastSales< 122.4 and Gender in ('F','U')) then 'SEGAS28'  
when (ClickCnt< 1.5 and RecencyMonths< 5.5 and RecencyMonths>=1.5 and ClickCnt>=0.5 and FlagEmail< 0.5 and LastSales< 122.4 and Gender='M' and age>=79.5) then 'SEGAS29'  
when (ClickCnt< 1.5 and RecencyMonths< 5.5 and RecencyMonths>=1.5 and ClickCnt>=0.5 and FlagEmail< 0.5 and LastSales< 122.4 and Gender='M' and age< 79.5) then 'SEGAS30'  
when (ClickCnt< 1.5 and RecencyMonths< 5.5 and RecencyMonths>=1.5 and ClickCnt>=0.5 and FlagEmail< 0.5 and LastSales>=122.4) then 'SEGAS31'  
when (ClickCnt< 1.5 and RecencyMonths< 5.5 and RecencyMonths>=1.5 and ClickCnt>=0.5 and FlagEmail>=0.5) then 'SEGAS32'  
when (ClickCnt< 1.5 and RecencyMonths< 5.5 and RecencyMonths< 1.5) then 'SEGAS33'  
when (ClickCnt>=1.5) then 'SEGAS34'  
else 'NULL' end)  
from Datawarehouse.staging.tgc_upsell_RECC_AS_SEG a  
  
  
update a  
set Segment='SEGASNULL'  
from Datawarehouse.staging.tgc_upsell_RECC_AS_SEG a  
where Segment is null or Segment='NULL'  
--(7117 row(s) affected)  
  
  --find all the segments whose counts are less than 100  
--and assign them into NULL segment  
--drop table #Segment  
select Segment, count(*) count  
into #Segment  
from Datawarehouse.staging.tgc_upsell_RECC_AS_SEG  
group by Segment  
having count(*) < 100  
--(4 row(s) affected)  
  
update a  
set Segment='SEGIMNULL'  
from Datawarehouse.staging.tgc_upsell_RECC_AS_SEG a  
where a.Segment in (select Segment from #Segment)  
  
--select top 1000 * from  
--Datawarehouse.staging.tgc_upsell_RECC_AS_SEG  
  
select count(*), Segment  
from Datawarehouse.staging.tgc_upsell_RECC_AS_SEG  
group by Segment  
order by Segment  
  
  
  
End
GO
