SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Mapping].[vwSalesByAdcode]
AS
	select year(od.DateOrdered) OrderYr, 
			month(od.DateOrdered) OrderMo, 
			od.Ordersource, 
			od.CurrencyCode,
			case when od.BillingCountryCode like 'US%' then 'US'
				when od.BillingCountryCode in ('CA','GB','AU') then od.BillingCountryCode
				else 'ROW'
			end as BillingCountry,
			va.StartDate,
			va.StopDate,
			va.ChannelID as MD_ChannelID,
			va.MD_Channel,
			va.MD_PromotionTypeID,
			va.MD_PromotionType,
			va.MD_CampaignID,
			va.MD_CampaignName,
			va.MD_Country,
			va.CatalogCode,
			va.CatalogName,
			va.AdCode,
			va.AdcodeName,
			COUNT(od.OrderID) TotalOrders, 
			sum(od.NetOrderAmount) TotalSales,
			sum(od.DiscountAmount) TotalCouponValue,
			sum(od.Tax) TotalTax,
			sum(od.ShippingCharge) TotalShipping,
			GETDATE() as ReportDate
	from Marketing.DMPurchaseOrders od   
		left join Mapping.vwAdcodesAll va on od.AdCode = va.AdCode
	where Year(od.DateOrdered) >= YEAR(dateadd(year,-3,GETDATE()))
	group by year(od.DateOrdered), 
			month(od.DateOrdered), 
			od.Ordersource, 
			od.CurrencyCode,
			case when od.BillingCountryCode like 'US%' then 'US'
				when od.BillingCountryCode in ('CA','GB','AU') then od.BillingCountryCode
				else 'ROW'
			end,
			va.StartDate,
			va.StopDate,
			va.ChannelID,
			va.MD_Channel,
			va.MD_PromotionTypeID,
			va.MD_PromotionType,
			va.MD_CampaignID,
			va.MD_CampaignName,
			va.MD_Country,
			va.CatalogCode,
			va.CatalogName,
			va.AdCode,
			va.AdcodeName









GO
