SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE VIEW [Mapping].[vwCouponRedeems]
AS
	select year(od.DateOrdered) OrderYr, 
			month(od.DateOrdered) OrderMo, 
			oi.Coupon, 
			cpn.JSCOUPONNUMBER as CouponNumber,
			oi.CouponDesc,
			od.Ordersource, 
			od.CurrencyCode,
			od.CSRID_actual,
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
			COUNT(oi.salesid) TotalOrders, 
			sum(od.NetOrderAmount) TotalSales,
			sum(od.DiscountAmount) TotalCouponValue,
			sum(od.Tax) TotalTax,
			sum(od.ShippingCharge) TotalShipping,
			GETDATE() as ReportDate
	from DAXImports..DAX_OrderCouponsExport oi 
		join Marketing.DMPurchaseOrders od on oi.salesid = od.orderid  
		left join Mapping.vwAdcodesAll va on od.AdCode = va.AdCode
		left join DAXImports..Load_Coupons cpn on oi.Coupon = cpn.jscouponid
	where Year(od.DateOrdered) >= YEAR(dateadd(year,-3,GETDATE()))
	group by year(od.DateOrdered), 
			month(od.DateOrdered), 
			oi.Coupon, 
			cpn.JSCOUPONNUMBER,
			oi.CouponDesc,
			od.Ordersource, 
			od.CurrencyCode,
			od.CSRID_actual,
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
