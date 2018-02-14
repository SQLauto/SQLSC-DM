SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[SP_EmailOrders_Monthly] @EOMonth date = null  
as  
  
Begin  
  
  
/*  
  
select   
a.CustomerID,  
a.EmailAddress,  
c.CustomerSegmentFnl,  
d.CustomerSegment, d.Frequency, d.CustomerSince, d.LastOrderDate, d.PreferredCategory,   
sum(isnull(a.OpenCnt, 0)) as OpenCnt,  
sum(isnull(a.ClickCnt, 0)) as ClickCnt  
from archive.emailorders (nolock) a   
     left join  ( select distinct ComboID, CustomerSegment2, CustomerSegmentFnl from mapping.RFMComboLookup (nolock)) c on a.ComboID = c.ComboID  
  left join  (select CustomerID, CustomerSegment, Frequency, CustomerSince, LastOrderDate, PreferredCategory from marketing.CampaignCustomerSignature (nolock)) d on a.CustomerID = d.CustomerID  
where a.AdCode not in   
       (select  a.AdCode   
       from archive.emailorders (nolock) a  
       group by a.Adcode  
       having sum(isnull(a.OpenCnt, 0)) = 0  
       )        
group by a.CustomerID, a.EmailAddress, c.CustomerSegmentFnl,   
d.CustomerSegment, d.Frequency, d.CustomerSince, d.LastOrderDate, d.PreferredCategory  
  
  
  
  
--Code  
select  a.CustomerID,  
a.EmailAddress,  
a.ComboID,  
sum(isnull(a.OpenCnt, 0)) as OpenCnt,  
sum(isnull(a.ClickCnt, 0)) as ClickCnt,  
EoMonth(Startdate) EOMStartdate,  
getdate() as DMlastupdated  
into #emailorders_monthly  
from archive.emailorders (nolock) a   
where EoMonth(Startdate) >  '2016-12-31'  
and flagholdout  = 0  
group by a.CustomerID,a.EmailAddress,a.ComboID,EoMonth(a.Startdate)  
  
*/  
--declare  @EOMonth date = null    

declare @StartOfMonth date
  
if @EOMonth is null  
begin   
  
Select @EOMonth = max(EOMStartdate) from archive.emailorders_monthly  

set @StartOfMonth =   DATEADD(month, DATEDIFF(month, 0, @EOMonth), 0)  
  
End   

if object_id('Archive.Tempemailorders')  is not null 
drop table Datawarehouse.Archive.Tempemailorders

select  *
into Archive.Tempemailorders   
from archive.emailorders (nolock) a   
where Startdate >=  @StartOfMonth  
option (maxdop 16);

  
select  a.CustomerID,  
a.EmailAddress,  
a.ComboID,  
sum(isnull(a.OpenCnt, 0)) as OpenCnt,  
sum(isnull(a.ClickCnt, 0)) as ClickCnt,  
EoMonth(Startdate) EOMStartdate,  
getdate() as DMlastupdated  
into #emailorders_monthly  
from Archive.Tempemailorders (nolock) a   
where EoMonth(Startdate) >=  @EOMonth  
and flagholdout  = 0  
group by a.CustomerID,a.EmailAddress,a.ComboID,EoMonth(a.Startdate)  
option (maxdop 16);
  

  
Delete E   
from archive.emailorders_monthly E  
join #emailorders_monthly T  
on T.customerid = E.Customerid   
and T.EmailAddress = E.EmailAddress  
and T.EOMStartdate = E.EOMStartdate  ;
  
insert into archive.emailorders_monthly (CustomerID,EmailAddress,ComboID,OpenCnt,ClickCnt,EOMStartdate,DMlastupdated)  
select CustomerID,EmailAddress,ComboID,OpenCnt,ClickCnt,EOMStartdate,getdate() from #emailorders_monthly  ;
   
   
/*  
select   
a.CustomerID,  
a.EmailAddress,  
c.CustomerSegmentFnl,  
d.CustomerSegment, d.Frequency, d.CustomerSince, d.LastOrderDate, d.PreferredCategory,   
sum(isnull(a.OpenCnt, 0)) as OpenCnt,  
sum(isnull(a.ClickCnt, 0)) as ClickCnt  
from archive.emailorders_monthly (nolock) a   
     left join  ( select distinct ComboID, CustomerSegment2, CustomerSegmentFnl from mapping.RFMComboLookup (nolock)) c on a.ComboID = c.ComboID  
  left join  (select CustomerID, CustomerSegment, Frequency, CustomerSince, LastOrderDate, PreferredCategory from marketing.CampaignCustomerSignature (nolock)) d on a.CustomerID = d.CustomerID  
group by a.CustomerID, a.EmailAddress, c.CustomerSegmentFnl,   
d.CustomerSegment, d.Frequency, d.CustomerSince, d.LastOrderDate, d.PreferredCategory  
*/  




--select * 
--INTO #Emailorders
--FROM archive.emailorders (nolock) 
--WHERE startdate > (select max(startdate) from Archive.EmailOrders_Summary);


Declare @MaxSummaryDate Date 

select @MaxSummaryDate = max(startdate) from Archive.EmailOrders_Summary;

--Insert into Archive.EmailOrders_Summary
select 
count(distinct a.CustomerID) as UniqueCustomers,
count(a.CustomerID) as Customers, 
a.Adcode,
a.StartDate,
count(a.EmailAddress) as Sends,
case when OpenCnt>=1 then 1 else 0 end as OpenCounter,
case when ClickCnt>=1 then 1 else 0 end as ClickCounter,
sum(case when OpenCnt>=1 then OpenCnt else 0 end) as Opens,
sum(case when ClickCnt>=1 then ClickCnt else 0 end) as Clicks,
cast(a.OpenDateStamp as Date) as OpenDate, 
cast(a.ClickDateStamp as Date) as ClickDate,
count(a.OrderID) as Orders,
cast(a.DateOrdered as Date) as DateOrdered, 
sum(a.NetOrderAmount) as NetOrderAmount,
a.OrderSource,
a.FlagDigitalPhysical,
CONVERT(VARCHAR(5),OpenDateStamp,108) as OpenTime,
CONVERT(VARCHAR(5), ClickDateStamp, 108) as ClickTime,
b.AdcodeName,
b.StopDate as AdCodeExpirationDate, 
 b.MD_CampaignName,
c.CustomerSegmentFnl,
RFI.EmailOffer, RFI.campaignName, RFI.Country, RFI.CatalogCode, RFI.catalogname, RFI.Flag_DoublePunch, RFI.FrequencyByCampiagn, RFI.PriorRunDate,GETDATE() AS DMlastupdated
INTO #temp
from --archive.emailorders (nolock) a 
       --(select * from archive.emailorders (nolock) where Month(StartDate) = 1 and year(StartDate) = 2017 ) a
          Datawarehouse.Archive.Tempemailorders a
            left join mapping.vwAdcodesAll (nolock) b 
                     on a.Adcode = b.AdCode
            left join  ( select distinct ComboID, CustomerSegment2, CustomerSegmentFnl from mapping.RFMComboLookup (nolock)) c 
                     on a.ComboID = c.ComboID
             Left join DataWarehouse.Marketing.Email_RFI_Report2018 (nolock) RFI
                     on RFI.catalogcode = b.catalogcode and c.CustomerSegmentFnl = RFI.CustomerSegmentFnl
where FlagHoldOut = 0 
group by
a.Adcode, AdCodeName, b.StopDate, MD_CampaignName,
a.StartDate, 
case when OpenCnt>=1 then 1 else 0 end,
case when ClickCnt>=1 then 1 else 0 end,
cast(a.OpenDateStamp as Date), CONVERT(VARCHAR(5),OpenDateStamp,108),
cast(a.ClickDateStamp as Date), CONVERT(VARCHAR(5), ClickDateStamp, 108), 
cast(a.DateOrdered as Date) , OrderSource, FlagDigitalPhysical, 
c.CustomerSegmentFnl,
case when OpenCnt>=1 then 1 else 0 end,
case when ClickCnt>=1 then 1 else 0 end,
RFI.EmailOffer, RFI.campaignName, RFI.Country, RFI.CatalogCode, RFI.catalogname, RFI.Flag_DoublePunch, RFI.FrequencyByCampiagn, RFI.PriorRunDate;



delete D from #temp D
Where Startdate <= @MaxSummaryDate

insert into Archive.EmailOrders_Summary
select * from #temp;


if object_id('Archive.Tempemailorders')  is not null 
drop table Datawarehouse.Archive.Tempemailorders  
  
END  





GO
