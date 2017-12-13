SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [Staging].[vw_PublicLibrarySales_Items]
AS
			
						
					
				
select convert(varchar(50),'IndividualLibrarySales') as PartnerName,
	a.CustomerID, 
	b.FirstName, 
	b.LastName,						
	case   
       when CompanyName not like '%lib%' and address1 like '%lib%' then Address1
	   when CompanyName not like '%lib%' and address2 like '%lib%' then Address2
	   when CompanyName not like '%lib%' and address3 like '%lib%' then Address3
       else CompanyName 
	end as Library, 			
	b.Address1, 
	b.Address2, 
	b.Address3,					
	b.City, 
	b.State, 
	b.Zip5 as PostalCode, 
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
	oi.CourseID,
	oi.CourseName,
	oi.CourseReleaseDate,
	oi.Parts as CourseParts,
	sum(oi.TotalSales) TotalSales,
	sum(oi.TotalQuantity) TotalQuantity,
	sum(oi.TotalParts) TotalParts,
	count(distinct a.OrderID) Orders,	
	GETDATE() as ReportDate					
from (select *					
	from DataWarehouse.Marketing.CampaignCustomerSignature with (nolock)
	where CountryCode = 'US'					
	and PublicLibrary = 1)b left join
	DataWarehouse.Marketing.DMPurchaseOrders a with (nolock) 					
	 on a.CustomerID = b.CustomerID	left join
	DataWarehouse.Marketing.DMPurchaseOrderItems oi on a.OrderID = oi.OrderID left join
	DataWarehouse.Mapping.vwAdcodesAll c with (nolock) on a.AdCode = c.AdCode left join
	 Mapping.ZipCodes_CountyAll z on b.Zip5 = z.ZipCode
where a.DateOrdered >= DATEADD(yy, DATEDIFF(yy,0,getdate()) - 3, 0)		
group by a.CustomerID, 
	b.FirstName, 
	b.LastName,						
	case   
       when CompanyName not like '%lib%' and address1 like '%lib%' then Address1
	   when CompanyName not like '%lib%' and address2 like '%lib%' then Address2
	   when CompanyName not like '%lib%' and address3 like '%lib%' then Address3
       else CompanyName 
	end,		
	b.Address1, 
	b.Address2, 
	b.Address3,					
	b.City, 
	b.State, 
	b.Zip5, 
	b.CountryCode,					
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
	c.MD_PriceType,
	oi.CourseID,
	oi.CourseName,
	oi.CourseReleaseDate,
	oi.Parts		
							
						


GO
