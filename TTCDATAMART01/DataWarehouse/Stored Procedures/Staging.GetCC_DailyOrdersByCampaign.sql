SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[GetCC_DailyOrdersByCampaign] 
AS
	-- Preethi Ramanujam    6/12/2014
	-- for customer Care forecasting purpose, need daily order information by campaign
begin

 	if object_id('Staging.TempCC_DailyOrdersByCampaign') is not null drop table Staging.TempCC_DailyOrdersByCampaign

		
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
	into Staging.TempCC_DailyOrdersByCampaign		
	from Staging.vwOrders a 
		join DAXImports..DAX_SalesStatus b on a.StatusCode = b.SalesStatusCode 
		join DAXImports..DAX_SalesType c on a.SalesTypeID = c.SalesTypeID	
		left join Mapping.vwAdcodesAll d on a.AdCode = d.AdCode
	where DateOrdered >= DATEADD(MONTH, -37, GETDATE())
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
		d.ChannelID,
		d.MD_Channel,
		d.MD_PromotionTypeID,
		d.MD_PromotionType,
		d.MD_CampaignID,
		d.MD_CampaignName,
		d.MD_PriceType

	truncate table Marketing.CC_DailyOrdersByCampaign
	insert into Marketing.CC_DailyOrdersByCampaign
	select * from Staging.TempCC_DailyOrdersByCampaign

end
GO
