SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--- View Name: 	Datawarehouse.Marketing.QCEmailMailPrefs
--- Purpose:	To check Customer's email and mail preferences.
---		
--- Updates:
--- Name				Date		Comments
--- Preethi Ramanujam 	7/7/2011 	New
---


CREATE	VIEW [Marketing].[QCEmailMailPrefs]
AS

select convert(datetime,convert(varchar,a.CustomerSince,101)) CustomerSince,
	YEAR(a.CustomerSince) YearOf, Month(a.CustomerSince) MonthOf,
	DAY(a.customerSince) DayOf,
	a.CustomerID, a.EmailAddress, 
	a.EmailPreferenceID, a.EmailPreferenceValue, a.FlagEmailable, 
	a.MailPreferenceID, a.MailPreferenceValue, 
	case when b.CountryCode in ('US','CA','GB','AU') then b.CountryCode
		else 'Others'
	end as CountryCode
from DataWarehouse.Marketing.DMCustomerStaticEmail a left join
	DataWarehouse.Marketing.CampaignCustomerSignature b on a.CustomerID = b.CustomerID
where a.CustomerSInce >= DATEADD(month,-3,getdate())















GO
