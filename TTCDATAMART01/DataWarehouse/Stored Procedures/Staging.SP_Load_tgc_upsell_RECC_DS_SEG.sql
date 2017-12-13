SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [Staging].[SP_Load_tgc_upsell_RECC_DS_SEG]  
as  
Begin  
  
/****************************Create base table for Deep Swamp Single's*********************************/  
  
--Deep Swamp Singles  
  
  
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
where NewSeg in (11,12,16,17,21,22,26,27,29,30,32,33,35,36,38,39)  
and comboid not like '%highschool%') t1  
join  
(select distinct CustomerID from  
DataWarehouse.Marketing.DMPurchaseOrders  
where BillingCountryCode in ('US','USA')  
--and convert(date,DateOrdered) < '6/29/2017'  
) t2 on  
t1.CustomerID=t2.CustomerID  
--(1311039 row(s) affected)  
  
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
  
  
-- drop table #final  
select t1.*,  
t3.LastDateOrdered,  
t3.LastSales,  
t3.Units,   
t8.ClickCnt,  
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
  
if object_id('Datawarehouse.staging.tgc_upsell_RECC_DS_SEG') is not null   
Drop table Datawarehouse.staging.tgc_upsell_RECC_DS_SEG  
  
  
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
Cast(null as varchar(20)) as Segment,  
getdate() as DMlastupdated  
into Datawarehouse.staging.tgc_upsell_RECC_DS_SEG  
from #final  
  
  
update Datawarehouse.staging.tgc_upsell_RECC_DS_SEG  
set ClickCnt = (case when ClickCnt is null then 0 else ClickCnt end),  
OrderSourcePreference=(case when OrderSourcePreference not in ('P','W','M') then 'X' else OrderSourcePreference end),  
MediaFormatPreference=(case when MediaFormatPreference not in ('C','D','DL','DV') then 'X' else MediaFormatPreference end)  
  
  
--alter table Datawarehouse.staging.tgc_upsell_RECC_DS_SEG  
--add Segment varchar(20)  
  
update a  
set Segment=  
(case when (RecencyMonths>=79.5 and FlagMail< 0.5) then 'SEGDS1'  
when (RecencyMonths>=79.5 and FlagMail>=0.5 and age< 51.5) then 'SEGDS2'  
when (RecencyMonths>=79.5 and FlagMail>=0.5 and age>=51.5 and age>=86.5) then 'SEGDS3'  
when (RecencyMonths>=79.5 and FlagMail>=0.5 and age>=51.5 and age< 86.5 and RecencyMonths>=115.5) then 'SEGDS4'  
when (RecencyMonths>=79.5 and FlagMail>=0.5 and age>=51.5 and age< 86.5 and RecencyMonths< 115.5 and FlagEmail< 0.5 and age< 59.5) then 'SEGDS5'  
when (RecencyMonths>=79.5 and FlagMail>=0.5 and age>=51.5 and age< 86.5 and RecencyMonths< 115.5 and FlagEmail< 0.5 and age>=59.5 and age>=81.5) then 'SEGDS6'  
when (RecencyMonths>=79.5 and FlagMail>=0.5 and age>=51.5 and age< 86.5 and RecencyMonths< 115.5 and FlagEmail< 0.5 and age>=59.5 and age< 81.5 and Gender in ('F','U')) then 'SEGDS7'  
when (RecencyMonths>=79.5 and FlagMail>=0.5 and age>=51.5 and age< 86.5 and RecencyMonths< 115.5 and FlagEmail< 0.5 and age>=59.5 and age< 81.5 and Gender='M' and Units< 1.5) then 'SEGDS8'  
when (RecencyMonths>=79.5 and FlagMail>=0.5 and age>=51.5 and age< 86.5 and RecencyMonths< 115.5 and FlagEmail< 0.5 and age>=59.5 and age< 81.5 and Gender='M' and Units>=1.5) then 'SEGDS9'  
when (RecencyMonths>=79.5 and FlagMail>=0.5 and age>=51.5 and age< 86.5 and RecencyMonths< 115.5 and FlagEmail>=0.5 and PreferredCategory2 in ('EC','HS','MH','MTH','SCI')) then 'SEGDS10'  
when (RecencyMonths>=79.5 and FlagMail>=0.5 and age>=51.5 and age< 86.5 and RecencyMonths< 115.5 and FlagEmail>=0.5 and PreferredCategory2 in (' ','AH','LIT','MSC','PH','RL','VA')) then 'SEGDS11'  
when (RecencyMonths< 79.5 and FlagMail< 0.5) then 'SEGDS12'  
when (RecencyMonths< 79.5 and FlagMail>=0.5 and ClickCnt< 1.5 and OrderSourcePreference='X') then 'SEGDS13'  
when (RecencyMonths< 79.5 and FlagMail>=0.5 and ClickCnt< 1.5 and OrderSourcePreference in ('M','P','W') and RecencyMonths>=39.5 and age< 48.5 and FlagEmail< 0.5) then 'SEGDS14'  
when (RecencyMonths< 79.5 and FlagMail>=0.5 and ClickCnt< 1.5 and OrderSourcePreference in ('M','P','W') and RecencyMonths>=39.5 and age< 48.5 and FlagEmail>=0.5 and Units< 1.5) then 'SEGDS15'  
when (RecencyMonths< 79.5 and FlagMail>=0.5 and ClickCnt< 1.5 and OrderSourcePreference in ('M','P','W') and RecencyMonths>=39.5 and age< 48.5 and FlagEmail>=0.5 and Units>=1.5 and PreferredCategory2 in ('AH','EC','HS','LIT','MH','SCI')) then 'SEGDS16'  
when (RecencyMonths< 79.5 and FlagMail>=0.5 and ClickCnt< 1.5 and OrderSourcePreference in ('M','P','W') and RecencyMonths>=39.5 and age< 48.5 and FlagEmail>=0.5 and Units>=1.5 and PreferredCategory2 in ('MSC','MTH','PH','RL','VA')) then 'SEGDS17'  
when (RecencyMonths< 79.5 and FlagMail>=0.5 and ClickCnt< 1.5 and OrderSourcePreference in ('M','P','W') and RecencyMonths>=39.5 and age>=48.5 and age>=83.5) then 'SEGDS18'  
when (RecencyMonths< 79.5 and FlagMail>=0.5 and ClickCnt< 1.5 and OrderSourcePreference in ('M','P','W') and RecencyMonths>=39.5 and age>=48.5 and age< 83.5 and Gender in ('F','U') and Units< 1.5) then 'SEGDS19'  
when (RecencyMonths< 79.5 and FlagMail>=0.5 and ClickCnt< 1.5 and OrderSourcePreference in ('M','P','W') and RecencyMonths>=39.5 and age>=48.5 and age< 83.5 and Gender in ('F','U') and Units>=1.5) then 'SEGDS20'  
when (RecencyMonths< 79.5 and FlagMail>=0.5 and ClickCnt< 1.5 and OrderSourcePreference in ('M','P','W') and RecencyMonths>=39.5 and age>=48.5 and age< 83.5 and Gender='M' and age< 57.5 and FlagEmail< 0.5) then 'SEGDS21'  
when (RecencyMonths< 79.5 and FlagMail>=0.5 and ClickCnt< 1.5 and OrderSourcePreference in ('M','P','W') and RecencyMonths>=39.5 and age>=48.5 and age< 83.5 and Gender='M' and age< 57.5 and FlagEmail>=0.5) then 'SEGDS22'  
when (RecencyMonths< 79.5 and FlagMail>=0.5 and ClickCnt< 1.5 and OrderSourcePreference in ('M','P','W') and RecencyMonths>=39.5 and age>=48.5 and age< 83.5 and Gender='M' and age>=57.5) then 'SEGDS23'  
when (RecencyMonths< 79.5 and FlagMail>=0.5 and ClickCnt< 1.5 and OrderSourcePreference in ('M','P','W') and RecencyMonths< 39.5 and RecencyMonths>=12.5 and LastSales< 29.19 and PreferredCategory2 in ('HS','MTH') and RecencyMonths< 19.5) then 'SEGDS24'  
when (RecencyMonths< 79.5 and FlagMail>=0.5 and ClickCnt< 1.5 and OrderSourcePreference in ('M','P','W') and RecencyMonths< 39.5 and RecencyMonths>=12.5 and LastSales< 29.19 and PreferredCategory2 in ('HS','MTH') and RecencyMonths>=19.5) then 'SEGDS25'  
when (RecencyMonths< 79.5 and FlagMail>=0.5 and ClickCnt< 1.5 and OrderSourcePreference in ('M','P','W') and RecencyMonths< 39.5 and RecencyMonths>=12.5 and LastSales< 29.19 and PreferredCategory2 in ('AH','EC','FW','LIT','MH','MSC','PH','PR','RL','SCI','
VA') and age< 50.5 and PreferredCategory2 in ('FW','LIT','MH','PH','PR','SCI')) then 'SEGDS26'  
when (RecencyMonths< 79.5 and FlagMail>=0.5 and ClickCnt< 1.5 and OrderSourcePreference in ('M','P','W') and RecencyMonths< 39.5 and RecencyMonths>=12.5 and LastSales< 29.19 and PreferredCategory2 in ('AH','EC','FW','LIT','MH','MSC','PH','PR','RL','SCI','
VA') and age< 50.5 and PreferredCategory2 in ('AH','EC','MSC','RL','VA')) then 'SEGDS27'  
when (RecencyMonths< 79.5 and FlagMail>=0.5 and ClickCnt< 1.5 and OrderSourcePreference in ('M','P','W') and RecencyMonths< 39.5 and RecencyMonths>=12.5 and LastSales< 29.19 and PreferredCategory2 in ('AH','EC','FW','LIT','MH','MSC','PH','PR','RL','SCI','
VA') and age>=50.5) then 'SEGDS28'  
when (RecencyMonths< 79.5 and FlagMail>=0.5 and ClickCnt< 1.5 and OrderSourcePreference in ('M','P','W') and RecencyMonths< 39.5 and RecencyMonths>=12.5 and LastSales>=29.19 and Units< 1.5 and age< 53.5 and RecencyMonths>=26.5) then 'SEGDS29'  
when (RecencyMonths< 79.5 and FlagMail>=0.5 and ClickCnt< 1.5 and OrderSourcePreference in ('M','P','W') and RecencyMonths< 39.5 and RecencyMonths>=12.5 and LastSales>=29.19 and Units< 1.5 and age< 53.5 and RecencyMonths< 26.5) then 'SEGDS30'  
when (RecencyMonths< 79.5 and FlagMail>=0.5 and ClickCnt< 1.5 and OrderSourcePreference in ('M','P','W') and RecencyMonths< 39.5 and RecencyMonths>=12.5 and LastSales>=29.19 and Units< 1.5 and age>=53.5) then 'SEGDS31'  
when (RecencyMonths< 79.5 and FlagMail>=0.5 and ClickCnt< 1.5 and OrderSourcePreference in ('M','P','W') and RecencyMonths< 39.5 and RecencyMonths>=12.5 and LastSales>=29.19 and Units>=1.5) then 'SEGDS32'  
when (RecencyMonths< 79.5 and FlagMail>=0.5 and ClickCnt< 1.5 and OrderSourcePreference in ('M','P','W') and RecencyMonths< 39.5 and RecencyMonths< 12.5) then 'SEGDS33'  
when (RecencyMonths< 79.5 and FlagMail>=0.5 and ClickCnt>=1.5) then 'SEGDS34'  
else 'NULL' end)  
from Datawarehouse.staging.tgc_upsell_RECC_DS_SEG a   
   
  
update a  
set Segment='SEGDSNULL'  
from Datawarehouse.staging.tgc_upsell_RECC_DS_SEG a  
where Segment is null or Segment='NULL'  
--(289691 row(s) affected)  
  
  --find all the segments whose counts are less than 100  
--and assign them into NULL segment  
--drop table #Segment  
select Segment, count(*) count  
into #Segment  
from Datawarehouse.staging.tgc_upsell_RECC_DS_SEG  
group by Segment  
having count(*) < 100  
--(0 row(s) affected)  
  
update a  
set Segment='SEGIMNULL'  
from Datawarehouse.staging.tgc_upsell_RECC_DS_SEG a  
where a.Segment in (select Segment from #Segment)  
  
--select top 1000 * from  
--Datawarehouse.staging.tgc_upsell_RECC_DS_SEG  
  
select count(*), Segment  
from Datawarehouse.staging.tgc_upsell_RECC_DS_SEG  
group by Segment  
order by Segment  
  
  
  
  
End
GO
