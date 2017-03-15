SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Staging].[vwGetPartnerOrders]
AS

	   
	select MONTH(a.DateOrdered) MonthOrdered,
		YEAR(a.dateordered) YearOrdered,
		Staging.GetMonday(a.dateordered) WeekOrdered,
		CAST(a.dateordered as date) DateOrdered,
		replace(left(convert(time,a.dateordered),5),':','') TimeOrdered,
		a.OrderSource, 
		Case when a.SequenceNum = 1 then 'New Customer'
			else 'Exisiting Customer'
		end as CustomerType,
		a.AdCode, b.AdcodeName,
		b.CatalogCode, b.CatalogName,
		b.MD_Channel, b.MD_PromotionType,
		b.MD_CampaignName, b.MD_PriceType,
		left(c.BillingZip,5) As BillingZip,
		COUNT(a.OrderID) Orders,
		sum(a.NetOrderAmount) Sales,
		sum(a.TotalCourseSales) TotalCourseSales,
		sum(a.TotalCourseQuantity) Units,
		sum(a.TotalCourseParts) Parts,
		GETDATE() ReportDate
	from DataWarehouse.Marketing.DMPurchaseOrders a 
	join (select * 
			from DataWarehouse.Mapping.vwAdcodesAll
			where ChannelID in (48)
			and StartDate >= '1/1/2014') b on a.AdCode = b.AdCode
	join DAXImports..DAX_OrderExport c on a.OrderID = c.orderid			
	where a.DateOrdered >= '1/1/2014'				
	group by MONTH(a.DateOrdered),
		YEAR(a.dateordered),
		Staging.GetMonday(a.dateordered),
		CAST(a.dateordered as date),
		replace(left(convert(time,a.dateordered),5),':',''),
		a.OrderSource, 
		Case when a.SequenceNum = 1 then 'New Customer'
			else 'Exisiting Customer'
		end,
		a.AdCode, b.AdcodeName,
		b.CatalogCode, b.CatalogName,
		b.MD_Channel, b.MD_PromotionType,
		b.MD_CampaignName, b.MD_PriceType,
		left(c.BillingZip,5)










GO
