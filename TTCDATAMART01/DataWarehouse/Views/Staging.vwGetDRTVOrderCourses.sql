SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Staging].[vwGetDRTVOrderCourses]
AS

	   

	select MONTH(a.DateOrdered) MonthOrdered,
		YEAR(a.dateordered) YearOrdered,
		Staging.GetMonday(a.dateordered) WeekOrdered,
		CAST(a.dateordered as date) DateOrdered,
		a.OrderSource, 
		Case when a.SequenceNum = 1 then 'New Customer'
			else 'Exisiting Customer'
		end as CustomerType,
		a.AdCode, b.AdcodeName,
		b.CatalogCode, b.CatalogName,
		b.MD_Channel, b.MD_PromotionType,
		b.MD_CampaignName, b.MD_PriceType,
		c.CourseID, 
		c.CourseName,
		c.SubjectCategory2 as SubjectCategory,
		c.FormatMedia,
		sum(c.TotalQuantity) Units,
		sum(c.TotalSales) Sales,
		sum(c.TotalParts) Parts,
		GETDATE() ReportDate
	from DataWarehouse.Marketing.DMPurchaseOrders a 
	join (select * 
			from DataWarehouse.Mapping.vwAdcodesAll
			where ChannelID in (5)
			and StartDate >= '1/1/2014') b on a.AdCode = b.AdCode
	join DataWarehouse.Marketing.DMPurchaseOrderItems c on a.OrderID = c.OrderID	
	where a.DateOrdered >= '1/1/2014'		
	group by MONTH(a.DateOrdered),
		YEAR(a.dateordered),
		Staging.GetMonday(a.dateordered),
		CAST(a.dateordered as date),
		a.OrderSource, 
		Case when a.SequenceNum = 1 then 'New Customer'
			else 'Exisiting Customer'
		end,
		a.AdCode, b.AdcodeName,
		b.CatalogCode, b.CatalogName,
		b.MD_Channel, b.MD_PromotionType,
		b.MD_CampaignName, b.MD_PriceType,
		c.CourseID, 
		c.CourseName,
		c.SubjectCategory2,
		c.FormatMedia








GO
