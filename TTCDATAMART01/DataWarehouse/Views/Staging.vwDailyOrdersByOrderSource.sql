SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE VIEW [Staging].[vwDailyOrdersByOrderSource]
as
	select  year(DateOrdered) OrderYear,
		month(DateOrdered) OrderMonth,
		datawarehouse.Staging.GetMonday(a.Dateordered) OrderWeek,
		cast(a.Dateordered as date) OrderDate,
		a.OrderSource,
		a.CurrencyCode,
		case when a.SequenceNum = 1 then 'FirstOrder'
            else '2+ Orders'
        end as FlagFirstOrder,
		Case when a.BillingCountryCode IN ('US','USA') then 'US'
			when a.BillingCountryCode IN ('GB','AU','CA') then ltrim(rtrim(a.BillingCountryCode))
			else 'RestOfTheWorld'
		end as CountryCode,
		b.MD_Channel, b.ChannelID as MD_ChannelID,
		FlagDefaultWeb = case when b.catalogcode in (4289,5265,999,11519,16318) then b.CatalogCode else 0 end,									
		FlagDefaultWebName = case when b.CatalogCode in (4289,5265,999,11519,16318) then b.CatalogName else 'Other' end,
		COUNT(a.OrderID) Orders,
		SUM(a.netorderamount) as sales,
		sum(a.TotalCourseQuantity) Units,
		suM(a.TotalCourseParts) Parts,
		GETDATE() ReportDate
	from DataWarehouse.Marketing.DMPurchaseOrders a 
		join Mapping.vwAdcodesAll b on a.AdCode = b.AdCode
	where a.dateordered >= (select DATEADD(yy, -2, DATEADD(yy, DATEDIFF(yy,0,getdate()), 0)))
	group by  year(DateOrdered),
		month(DateOrdered),
		datawarehouse.Staging.GetMonday(a.Dateordered),
		cast(a.Dateordered as date),
		a.OrderSource,
		a.CurrencyCode,
		case when a.SequenceNum = 1 then 'FirstOrder'
            else '2+ Orders'
        end,
		Case when a.BillingCountryCode IN ('US','USA') then 'US'
			when a.BillingCountryCode IN ('GB','AU','CA') then ltrim(rtrim(a.BillingCountryCode))
			else 'RestOfTheWorld'
		end,
		b.MD_Channel, b.ChannelID,
		case when b.catalogcode in (4289,5265,999,11519,16318) then b.CatalogCode else 0 end,									
		case when b.CatalogCode in (4289,5265,999,11519,16318) then b.CatalogName else 'Other' end





GO
