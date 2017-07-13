SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE View [Archive].[VW_TB_Emailordres_DormantCustomers]
as


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

*/
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
GO
