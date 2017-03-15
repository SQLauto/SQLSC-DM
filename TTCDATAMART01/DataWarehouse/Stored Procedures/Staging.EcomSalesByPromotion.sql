SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [Staging].[EcomSalesByPromotion]
AS
--- Proc Name:    MarketingDM.dbo.HouseFileForOSWPreMerge
--- Purpose:      To Generate Ecom sales report by promotion
---   
--- Special Tables Used: 
---
--- Input Parameters:
---         
---         
--- Updates:
--- Name          Date        Comments
--- Preethi Ramanujam   7/15/2015   New
--- 
--- 

--- Declare variables

begin
	set nocount on

    if object_id(N'Staging.TempEcom_SalesByPromotion1', N'U') is not null drop table Staging.TempEcom_SalesByPromotion1

	select a.customerid, 
		a.SequenceNum, 
		a.NetOrderAmount, 
		a.orderid, 
		a.DateOrdered,
		b.catalogcode, 
		b.catalogname, 
		b.adcode, 
		b.adcodename, 
		b.PromotionTypeID,
		b.PromotionType,
		b.MD_Country,
		b.MD_Audience,
		b.MD_Year,
		b.MD_CampaignID,
		b.MD_CampaignDesc,
		b.ChannelID as MD_ChannelID,
		b.MD_Channel as MD_ChannelDesc, 
		b.MD_PromotionTypeID, 
		b.MD_PromotionType, 
		b.MD_PriceType, 
		b.CurrencyCode,
		c.customersince,
		case when a.sequencenum=1 then 'new_customer' 
			else 'existing_customer' 
		end as CustomerType,
		marketingdm.dbo.getsunday(a.DateOrdered) as WeekOf
	into Staging.TempEcom_SalesByPromotion1
	from datawarehouse.marketing.dmpurchaseorders a
		join (select * from DataWarehouse.Mapping.vwAdcodesAll
			where PromotionTypeID in (select distinct PromotionTypeID
									   from MarketingCubes..DimPromotionType
										where PromotionTypeFlag2 = 'Ecom')
			union
			select * from DataWarehouse.Mapping.vwAdcodesAll
			where ChannelID in (11,12,13,14)
			union
			select * from DataWarehouse.Mapping.vwAdcodesAll
			where ChannelID in (2)
			and MD_PromotionTypeID = 19
			and adcodename like '%redirect%') b on a.adcode=b.adcode
		join datawarehouse.marketing.campaigncustomersignature c on a.customerid=c.customerid
		--join DAXImports..CustomerExport c on a.customerid=c.customerid
	where a.netorderamount between 5 and 1500
	and a.dateordered  between DATEADD(yy, DATEDIFF(yy,0,getdate()) - 1, 0) and GETDATE()


   if object_id(N'Staging.TempEcom_SalesByPromotion', N'U') is not null drop table Staging.TempEcom_SalesByPromotion

	select 
		GETDATE() ReportDate,
		year(DateOrdered) as YearOrdered,
		month(DateOrdered) as MonthOrdered, 
		DATEPART(week,dateordered) as WeekNum,
		DATEDIFF(week,staging.getmonday(DateOrdered),staging.getmonday(getdate())) WeeksSinceOrder,
		WeekOf,
		CatalogCode, 
		CatalogName,  
		Adcode, 
		AdcodeName, 
		PromotionTypeID,
		PromotionType,
		MD_Country,
		MD_Audience,
		MD_Year,
		MD_CampaignID,
		MD_CampaignDesc,
		MD_ChannelID,
		MD_ChannelDesc,
		MD_PromotionTypeID, 
		MD_PromotionType, 
		MD_PriceType, 
		CurrencyCode,
		CustomerType, 
		count(distinct customerid) as CustomerCount, 
		min(convert(varchar,dateordered,101)) as MinDate, 
		max(convert(varchar,dateordered,101)) as MaxDate, 
		sum(NetOrderAmount) as TotalSales,
		count(orderid) as TotalOrders
	into Staging.TempEcom_SalesByPromotion
	from Staging.TempEcom_SalesByPromotion1
	group by year(DateOrdered),
		month(DateOrdered), 
		DATEPART(week,dateordered),
		DATEDIFF(week,staging.getmonday(DateOrdered),staging.getmonday(getdate())),
		WeekOf,
		CatalogCode, 
		CatalogName,  
		Adcode, 
		AdcodeName, 
		PromotionTypeID,
		PromotionType,
		MD_Country,
		MD_Audience,
		MD_Year,
		MD_CampaignID,
		MD_CampaignDesc,
		MD_ChannelID,
		MD_ChannelDesc,
		MD_PromotionTypeID,
		MD_PromotionType,
		MD_PriceType,
		CurrencyCode,
		CustomerType

   truncate table Marketing.Ecom_SalesByPromotion
   
   insert into Marketing.Ecom_SalesByPromotion
   select * from Staging.TempEcom_SalesByPromotion

end
GO
