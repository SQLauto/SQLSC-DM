SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [Staging].[vw_PublicLibrarySales]
AS
			
						
select a.CustomerID, 
	b.FirstName, 
	b.LastName,						
	b.CompanyName, 			
	b.Address1, 
	b.Address2, 
	b.Address3,					
	b.City, 
	b.State, 
	b.PostalCode, 
	b.CountryCode,					
	year(a.DateOrdered) YearOrdered,					
	MONTH(a.DateOrdered) MonthOrdered,
	case when month(a.DateOrdered) in (1,2,3) then 'Q1'
		 when month(a.DateOrdered) in (4,5,6) then 'Q2'
		 when month(a.DateOrdered) in (7,8,9) then 'Q3'
		 when month(a.DateOrdered) in (10,11,12) then 'Q4'
	End as QuarterOrdered,	
	a.AdCode,
	c.AdcodeName,
	c.CatalogCode,
	c.CatalogName,
	c.MD_Country,
	c.MD_Year,
	c.MD_Channel,
	c.MD_PromotionType,
	c.MD_CampaignName,
	c.MD_Audience,
	c.MD_PriceType,	 
	count(a.OrderID) Orders,					
	sum(a.NetOrderAmount) Sales,
	GETDATE() as ReportDate					
from DataWarehouse.Marketing.DMPurchaseOrders a with (nolock) join						
	(select *					
	from DataWarehouse.Marketing.CampaignCustomerSignature with (nolock)
	where CountryCode = 'US'					
	and PublicLibrary = 1)b on a.CustomerID = b.CustomerID	left join
	DataWarehouse.Mapping.vwAdcodesAll c with (nolock) on a.AdCode = c.AdCode				
where a.DateOrdered >= DATEADD(yy, DATEDIFF(yy,0,getdate()) - 3, 0)		
group by a.CustomerID, b.FirstName, b.LastName,						
	b.CompanyName,					
	b.Address1, b.Address2, b.Address3,					
	b.City, b.State, b.PostalCode, b.CountryCode,					
	year(a.DateOrdered),					
	MONTH(a.DateOrdered),
	case when month(a.DateOrdered) in (1,2,3) then 'Q1'
		 when month(a.DateOrdered) in (4,5,6) then 'Q2'
		 when month(a.DateOrdered) in (7,8,9) then 'Q3'
		 when month(a.DateOrdered) in (10,11,12) then 'Q4'
	End,
	a.AdCode,
	c.AdcodeName,
	c.CatalogCode,
	c.CatalogName,
	c.MD_Country,
	c.MD_Year,
	c.MD_Channel,
	c.MD_PromotionType,
	c.MD_CampaignName,
	c.MD_Audience,
	c.MD_PriceType				
									


GO
