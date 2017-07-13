SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create proc [dbo].[SP_EmailOrders_Monthly] @EOMonth date = null
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


if @EOMonth is null
begin 

Select @EOMonth = max(EOMStartdate) from archive.emailorders_monthly

End 

select  a.CustomerID,
a.EmailAddress,
a.ComboID,
sum(isnull(a.OpenCnt, 0)) as OpenCnt,
sum(isnull(a.ClickCnt, 0)) as ClickCnt,
EoMonth(Startdate) EOMStartdate,
getdate() as DMlastupdated
into #emailorders_monthly
from archive.emailorders (nolock) a 
where EoMonth(Startdate) >=  @EOMonth
and flagholdout  = 0
group by a.CustomerID,a.EmailAddress,a.ComboID,EoMonth(a.Startdate)



Delete E 
from archive.emailorders_monthly E
join #emailorders_monthly T
on T.customerid = E.Customerid 
and T.EmailAddress = E.EmailAddress
and T.EOMStartdate = E.EOMStartdate

insert into archive.emailorders_monthly (CustomerID,EmailAddress,ComboID,OpenCnt,ClickCnt,EOMStartdate,DMlastupdated)
select CustomerID,EmailAddress,ComboID,OpenCnt,ClickCnt,EOMStartdate,getdate() from #emailorders_monthly
 
 
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



END
GO
