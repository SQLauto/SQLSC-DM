SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
        
CREATE Proc [Staging].[SP_CC_VOC_ContactedCustReport]        
as        
        
Begin        
        
        
/*Updating Flags Correctly*/        
  update staging.tempCC_VOC_ContactedCustList        
    set CustomerName = ISNULL(CustomerName,''),        
     FlagEngaged = case when FlagDigitalIssue in (1,2) then null        
          else FlagEngaged end,        
     FlagSaved = case when FlagDigitalIssue in (1,2) then null        
          else FlagSaved end         
        
 --Delete nulls Created by Copy paste error    
 delete from staging.tempCC_VOC_ContactedCustList        
 where CustomerID is null and  isnull(CustomerName,'') = ''     
 and  CC_ContactDate is null     
 and  FlagDigitalIssue is null     
 and  FlagEngaged is null     
 and  FlagSaved is null     
 and TicketNo is null     
    
     
--Check and remove Duplicates        
 If exists (select CustomerID,CC_ContactDate,FlagDigitalIssue,TicketNo,Rank() over (Partition BY CustomerID,CC_ContactDate,FlagDigitalIssue,TicketNo order by TicketNo desc) as Ranking --,COUNT(*)        
 from staging.tempCC_VOC_ContactedCustList        
 group by CustomerID,CC_ContactDate, FlagDigitalIssue,TicketNo        
 having COUNT(*)>1)        
      
   begin        
   WITH Duplicates as        
   (        
   SELECT ROW_NUMBER() Over(PARTITION BY CustomerID,CC_ContactDate,FlagDigitalIssue,TicketNo  ORDER BY TicketNo)        
      As RowNumber,* FROM staging.tempCC_VOC_ContactedCustList        
   )        
   --select * from Duplicates where RowNumber >1        
   delete  from Duplicates where RowNumber >1        
   end        
        
        
--Insert into staging.CC_VOC_ContactedCustList        
insert into staging.CC_VOC_ContactedCustList (CustomerID,CustomerName,CC_ContactDate,FlagDigitalIssue,FlagEngaged,FlagSaved,TicketNo)        
select CustomerID,CustomerName,CC_ContactDate,FlagDigitalIssue,FlagEngaged,FlagSaved,TicketNo from staging.tempCC_VOC_ContactedCustList        
        


/*Keep only first contact information for digital (1,11)*/
select CustomerID, TicketNo,FlagDigitalIssue, min(a.CC_ContactDate)Min_CC_ContactDate
into #DeletesForDigital 
from datawarehouse.Staging.CC_VOC_ContactedCustList a 
where FlagDigitalIssue in (1,11) 
group by CustomerID, TicketNo,FlagDigitalIssue 
having min(a.CC_ContactDate)<>max(a.CC_ContactDate)

/*deleting other than first contact information for digital (1,11)*/
delete a from datawarehouse.Staging.CC_VOC_ContactedCustList a 
inner join #DeletesForDigital D
on d.CustomerID = a.CustomerID 
and d.FlagDigitalIssue = a.FlagDigitalIssue 
and d.TicketNo = a.TicketNo
and a.CC_ContactDate > d.Min_CC_ContactDate
        
-- Run the report        
if OBJECT_ID ('Staging.TempCC_VOC_90DaysDS') is not null        
drop table datawarehouse.Staging.TempCC_VOC_90DaysDS        
        
        
select a.CustomerID,         
 a.CustomerName,         
 a.CC_ContactDate,        
 a.FlagDigitalIssue,        
 a.FlagEngaged,        
 a.FlagSaved,        
 a.TicketNo,        
 Year(a.CC_ContactDate) CC_ContactYear,        
 Month(a.CC_ContactDate) CC_ContactMonth,        
 DataWarehouse.Staging.GetMonday(a.CC_ContactDate) WeekOfContact,        
 DataWarehouse.Staging.GetMonday(b.Dateordered) WeekOfOrder,        
 count(b.OrderID) Orders,        
 sum(b.NetOrderAmount) Sales,        
 DATEDIFF(WEEK,DataWarehouse.Staging.GetMonday(a.CC_ContactDate),DataWarehouse.Staging.GetMonday(b.Dateordered)) as OrderedWithinWks,        
 DATEDIFF(day,a.CC_ContactDate,GETDATE()) as DaysSinceContact,        
 case when DATEDIFF(day,a.CC_ContactDate,GETDATE()) > 90 then 1        
  else 0        
 end as FlagComplete90Days,        
 GETDATE() as DateLoaded        
into datawarehouse.Staging.TempCC_VOC_90DaysDS        
from staging.CC_VOC_ContactedCustList a         
 left join DataWarehouse.Marketing.DMPurchaseOrders b on a.CustomerID = b.CustomerID        
              and b.DateOrdered  between a.CC_ContactDate and dateadd(day,90,a.CC_ContactDate)        
where b.NetOrderAmount > 0                      
group by a.CustomerID,         
 a.CustomerName,         
 a.CC_ContactDate,        
 a.FlagDigitalIssue,        
 a.FlagEngaged,        
 a.FlagSaved,        
 a.TicketNo,        
 Year(a.CC_ContactDate),        
 Month(a.CC_ContactDate),        
 DataWarehouse.Staging.GetMonday(a.CC_ContactDate),        
 DataWarehouse.Staging.GetMonday(b.Dateordered),        
 DATEDIFF(WEEK,DataWarehouse.Staging.GetMonday(a.CC_ContactDate),DataWarehouse.Staging.GetMonday(b.Dateordered)),        
 DATEDIFF(day,a.CC_ContactDate,GETDATE()),        
 case when DATEDIFF(day,a.CC_ContactDate,GETDATE()) > 90 then 1        
  else 0        
 end                     
order by 4,1,5        
        
        
update a      
set a.customername = b.firstname + ' ' + b.lastname        
from datawarehouse.Staging.TempCC_VOC_90DaysDS a join        
 DataWarehouse.Marketing.CampaignCustomerSignature b on a.CustomerID = b.CustomerID        
where isnull(a.CustomerName,'') = ''        
        
-- Load the data to final table.        
Truncate table datawarehouse.marketing.CC_VOC_90DaysDS        
        
insert into datawarehouse.marketing.CC_VOC_90DaysDS        
select *         
from datawarehouse.Staging.TempCC_VOC_90DaysDS        
        
        
select * from datawarehouse.marketing.CC_VOC_90DaysDS        
        
        
  /*Load to Archive.CC_VOC_ContactedCustList_History*/      
  insert into Archive.CC_VOC_ContactedCustList_History      
  select CustomerID,CustomerName,CC_ContactDate,FlagDigitalIssue,FlagEngaged,FlagSaved,TicketNo,GETDATE() as LastRunDate from staging.tempCC_VOC_ContactedCustList        
        
        
    select COUNT(*) CNTs,CAST(LastRunDate as DATE)LastRunDate from Archive.CC_VOC_ContactedCustList_History     
    where  CAST(LastRunDate as DATE)= CAST(getdate() as DATE)    
    group by CAST(LastRunDate as DATE)    
        
End      
      
GO
