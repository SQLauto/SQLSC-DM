SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Staging].[vwGet3rdPartyInsertSOUP]
AS

	   
	select MONTH(a.DateOrdered) MonthOrdered,
		YEAR(a.dateordered) YearOrdered,
		Staging.GetMonday(a.dateordered) WeekOrdered,
		CAST(a.dateordered as date) DateOrdered,
		a.OrderSource, 
		Case when a.SequenceNum = 1 then 'New Customer'
			else 'Exisiting Customer'
		end as CustomerType,
		a.CurrencyCode, 
		case when a.BillingCountryCode like '%US%' then 'US'
			when a.BillingCountryCode in ('CA','GB','AU') then a.BillingCountryCode
			else 'ROW'
		end as BillingCountryCode,
		a.AdCode, b.AdcodeName,
		b.CatalogCode, b.CatalogName,
		b.MD_Channel, b.MD_PromotionType,
		b.MD_CampaignName, b.MD_PriceType,
		b.MD_Country,
		b.StartDate, b.StopDate,
		COUNT(a.OrderID) Orders,
		sum(a.NetOrderAmount) Sales,
		sum(a.TotalCourseSales) TotalCourseSales,
		sum(a.TotalCourseQuantity) Units,
		sum(a.TotalCourseParts) Parts,
		GETDATE() ReportDate
	from DataWarehouse.Marketing.DMPurchaseOrders a 
	join (select * 
			from DataWarehouse.Mapping.vwAdcodesAll
			where ChannelID in (9)) b on a.AdCode = b.AdCode	
	where a.DateOrdered >= '1/1/2014'				
	group by MONTH(a.DateOrdered),
		YEAR(a.dateordered),
		Staging.GetMonday(a.dateordered),
		CAST(a.dateordered as date),
		a.OrderSource, 
		Case when a.SequenceNum = 1 then 'New Customer'
			else 'Exisiting Customer'
		end,
		a.CurrencyCode, 
		case when a.BillingCountryCode like '%US%' then 'US'
			when a.BillingCountryCode in ('CA','GB','AU') then a.BillingCountryCode
			else 'ROW'
		end,
		a.AdCode, b.AdcodeName,
		b.CatalogCode, b.CatalogName,
		b.MD_Channel, b.MD_PromotionType,
		b.MD_CampaignName, b.MD_PriceType,
		b.MD_Country,
		b.StartDate, b.StopDate


GO
