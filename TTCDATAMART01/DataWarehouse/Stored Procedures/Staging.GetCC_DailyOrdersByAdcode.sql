SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[GetCC_DailyOrdersByAdcode] 
AS
	-- Preethi Ramanujam    1/13/2015
	-- for customer Care forecasting purpose, need daily order information by adcode
begin

 	if object_id('Staging.TempCC_DailyOrdersByAdcode') is not null drop table Staging.TempCC_DailyOrdersByAdcode

		
	select year(DateOrdered) YearOrdered,		
		month(DateOrdered) MonthOrdered,	
		Staging.GetMonday(DateOrdered) WeekOf,	
		cast(DateOrdered as date) DateOrdered,	
		DATEPART(hour,dateordered) HourOrdered,	
		a.CurrencyCode,	
		case when BillingCountryCode in ('AU','GB','CA') then BillingCountryCode	
			when BillingCountryCode like '%US%' then 'US'
			else 'ROW'
		end as BillingCountryCode,	
		OrderSource,	
		b.SalesStatusValue as OrderStatus,	
		c.SalesTypeValue as OrderType,
		a.AdCode, d.AdcodeName,
		d.CatalogCode, d.CatalogName,
		d.ChannelID MD_ChannelID,
		d.MD_Channel,
		d.MD_PromotionTypeID,
		d.MD_PromotionType,
		d.MD_CampaignID,
		d.MD_CampaignName,
		d.MD_PriceType,	
		COUNT(OrderID) Orders,	
		sum(NetOrderAmount) Sales,
		GETDATE() as ReportDate
	into Staging.TempCC_DailyOrdersByAdcode		
	from Staging.vwOrders a 
		join DAXImports..DAX_SalesStatus b on a.StatusCode = b.SalesStatusCode 
		join DAXImports..DAX_SalesType c on a.SalesTypeID = c.SalesTypeID	
		left join Mapping.vwAdcodesAll d on a.AdCode = d.AdCode
	where DateOrdered >= DATEADD(MONTH, -13, GETDATE())
	group by year(DateOrdered),		
		month(DateOrdered),	
		Staging.GetMonday(DateOrdered),	
		cast(DateOrdered as date) ,	
		DATEPART(hour,dateordered) ,	
		a.CurrencyCode,	
		case when BillingCountryCode in ('AU','GB','CA') then BillingCountryCode	
			when BillingCountryCode like '%US%' then 'US'
			else 'ROW'
		end,	
		OrderSource,	
		b.SalesStatusValue,	
		c.SalesTypeValue,		
		a.AdCode, d.AdcodeName,
		d.CatalogCode, d.CatalogName,
		d.ChannelID,
		d.MD_Channel,
		d.MD_PromotionTypeID,
		d.MD_PromotionType,
		d.MD_CampaignID,
		d.MD_CampaignName,
		d.MD_PriceType

	truncate table Marketing.CC_DailyOrdersByAdcode
	insert into Marketing.CC_DailyOrdersByAdcode
	select * from Staging.TempCC_DailyOrdersByAdcode


end
GO
