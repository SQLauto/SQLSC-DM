SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [Staging].[GetCC_Upsell_Adcode_Report] @FlagFullRefresh int = 0
AS
--- Proc Name:    GetCC_Upsell_Report
--- Purpose:      To capture the results of Customer Care Upsell program adcode level
--- Input Parameters: None
---               
--- Updates:
--- Name                      Date        Comments
--- Preethi Ramanujam   1/8/2015    New
BEGIN
	set nocount on
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

    DECLARE @ReportDate datetime, @ReportStartDate Date

    set @ReportDate = GETDATE()
    
    if @FlagFullRefresh = 1 
		select @ReportStartDate = '8/1/2013' -- upsell program needs to be tracked from this date...
	else 
		select @ReportStartDate = DATEADD(Wk, -2, datawarehouse.Staging.GetMonday(GETDATE()))		--Delta does Monday 2 weeks back


    -- Get orders and items information with crosell flag set to 1
    print 'Get orders and items information with crosell flag set to 1'
    
    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'CC_Upsell_Items_Temp_Adcode')
    DROP TABLE Staging.CC_Upsell_Items_Temp_Adcode

	select ccups.Orderid, 
		ccups.Orderitemid,
		ITEMID, 
		CrossSell, 
		LineType,  
		Quantity, 
		ccups.SALESPRICE, 
		(Quantity * ccups.SALESPRICE) TotalSales,
		YEAR(DM.DateOrdered) YearUpSellordered, 
		MONTH(DM.DateOrdered) MonthUpSellordered,
		datawarehouse.Staging.GetMonday(DM.DateOrdered) WeekUpSellordered,
		cast(DM.DateOrdered as date) DayUpSellordered,
		ccups.JSSOURCEID as UpSellAdcode, c.AdcodeName as UpSellAdcodeName, c.CatalogCode as UpSellCatalogCode, c.CatalogName as UpSellCatalogName,
		c.MD_Year, c.MD_Country, c.MD_Audience,
		c.ChannelID MD_ChannelID, c.MD_Channel as MD_ChannelName,
		c.MD_PromotionTypeID, c.MD_PromotionType,
		c.MD_CampaignID, c.MD_CampaignName,
		c.MD_PriceType									
	into Staging.CC_Upsell_Items_Temp_Adcode
	from Marketing.CCUpsellItems ccups
	left join DataWarehouse.Marketing.DMPurchaseOrderitems Dm
	on Dm.OrderID = ccups.orderid and Dm.StockItemID=ccups.ITEMID
	left join DataWarehouse.Mapping.vwAdcodesAll c 
	on ccups.JSSOURCEID  = c.adcode
	where CrossSell = 1
	and DM.DateOrdered>=@ReportStartDate
	and ITEMID not like 's%'
	
	
	
	

    -- Get Order level data...
    print 'Get Order level data.'
    
    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'CC_Upsell_Report_Adcode_Temp')  
          DROP TABLE Staging.CC_Upsell_Report_Adcode_Temp


 select @ReportDate as ReportDate,
		CCUPS.YearUpSellordered YearOrdered,									
		CCUPS.MonthUpSellordered MonthOrdered,								
		CCUPS.WeekUpSellordered WeekOrdered,								
		CCUPS.DayUpSellordered DateOrdered,
		CCUPS.UpSellAdcode,
		CCUPS.UpSellAdcodeName,
		CCUPS.UpSellCatalogCode,
		CCUPS.UpSellCatalogName,
		CCUPS.MD_Year, 
		CCUPS.MD_Country, 
		CCUPS.MD_Audience,
		CCUPS.MD_ChannelID, 
		CCUPS.MD_ChannelName,
		CCUPS.MD_PromotionTypeID, 
		CCUPS.MD_PromotionType,
		CCUPS.MD_CampaignID, 
		CCUPS.MD_CampaignName,
		CCUPS.MD_PriceType,				
		DM.OrderSource,								
		DM.CurrencyCode,	
		DM.CSRID_Actual as CSRID,
		case when DM.BillingCountryCode in ('US','USA') then 'US'
			when Dm.BillingCountryCode in ('CA','AU','GB') then DM.BillingCountryCode
			else 'ROW'
		end as BillingCountryCode,							
		sum(ISNULL(b.TotalSales,0))  as TotalUpsell_Sold,					
		sum(ISNULL(c.TotalSales,0))  as TotalUpsell_Delivered,					
		sum(ISNULL(d.TotalSales,0))  as TotalUpsell,
		0 as TotalSales,
		cast(1 as bit) as UpSellFlag
					
	into Staging.CC_Upsell_Report_Adcode_Temp									
	from (select OrderID,UpSellAdcode,UpSellAdcodeName,UpSellCatalogCode,UpSellCatalogName,MD_Year,MD_Country, MD_Audience,MD_ChannelID, MD_ChannelName,MD_PromotionTypeID, MD_PromotionType,
                 MD_CampaignID, MD_CampaignName,MD_PriceType,CCUPS.YearUpSellordered ,CCUPS.MonthUpSellordered ,CCUPS.WeekUpSellordered ,CCUPS.DayUpSellordered 
                 from staging.CC_Upsell_Items_Temp_Adcode   ccups                                         
              group by OrderID,UpSellAdcode,UpSellAdcodeName,UpSellCatalogCode,UpSellCatalogName,MD_Year,MD_Country, MD_Audience,MD_ChannelID, MD_ChannelName,MD_PromotionTypeID, MD_PromotionType,
                 MD_CampaignID, MD_CampaignName,MD_PriceType,CCUPS.YearUpSellordered ,CCUPS.MonthUpSellordered ,CCUPS.WeekUpSellordered ,CCUPS.DayUpSellordered 
                              ) CCUPS 
		left join	(select OrderID,UpSellAdcode, SUM(TotalSales) TotalSales								
					from staging.CC_Upsell_Items_Temp_Adcode								
					where LineType = 'ItemSold'
					group by OrderID,UpSellAdcode) b 
					on CCUPS.OrderID = b.OrderID and  b.UpSellAdcode = CCUPS.UpSellAdcode										
		left join	(select OrderID,UpSellAdcode, SUM(TotalSales) TotalSales								
					from staging.CC_Upsell_Items_Temp_Adcode								
					where LineType = 'ItemDelivered'
					group by OrderID,UpSellAdcode)c 
					on CCUPS.OrderID = c.OrderID and  c.UpSellAdcode = CCUPS.UpSellAdcode											
		left join	(select OrderID,UpSellAdcode, SUM(TotalSales) TotalSales								
					from staging.CC_Upsell_Items_Temp_Adcode
					group by OrderID,UpSellAdcode)d 
					on CCUPS.OrderID = d.OrderID and  d.UpSellAdcode = CCUPS.UpSellAdcode			
		left join	Marketing.DMPurchaseOrders DM
					on Dm.OrderID = CCUPS.OrderID						
	group by CCUPS.YearUpSellordered,CCUPS.MonthUpSellordered,CCUPS.WeekUpSellordered,CCUPS.DayUpSellordered,
	DM.OrderSource,DM.CurrencyCode,DM.CSRID_Actual,CCUPS.UpSellAdcode,CCUPS.UpSellAdcodeName,
	CCUPS.UpSellCatalogCode,CCUPS.UpSellCatalogName,CCUPS.MD_Year, CCUPS.MD_Country, CCUPS.MD_Audience,CCUPS.MD_ChannelID, 
	CCUPS.MD_ChannelName,CCUPS.MD_PromotionTypeID, CCUPS.MD_PromotionType,CCUPS.MD_CampaignID, CCUPS.MD_CampaignName,CCUPS.MD_PriceType ,     
	case when Dm.BillingCountryCode in ('US','USA') then 'US'
		when DM.BillingCountryCode in ('CA','AU','GB') then DM.BillingCountryCode
		else 'ROW'
	end

 
UNION ALL

 select @ReportDate as ReportDate,
		year(DM.DateOrdered) YearOrdered,									
		MONTH(DM.DateOrdered) MonthOrdered,								
		datawarehouse.Staging.GetMonday(DM.DateOrdered) WeekOrdered,								
		cast(DM.DateOrdered as Date) DateOrdered,
		'' as UpSellAdcode,
		'' as UpSellAdcodeName,
		'' as UpSellCatalogCode,
		'' as UpSellCatalogName,
		'' as MD_Year, 
		'' as MD_Country, 
		'' as MD_Audience,
		'' as MD_ChannelID, 
		'' as MD_ChannelName,
		'' as MD_PromotionTypeID, 
		'' as MD_PromotionType,
		'' as MD_CampaignID, 
		'' as MD_CampaignName,
		'' as MD_PriceType,				
		DM.OrderSource,								
		DM.CurrencyCode,	
		DM.CSRID_Actual as CSRID,
		case when DM.BillingCountryCode in ('US','USA') then 'US'
			when Dm.BillingCountryCode in ('CA','AU','GB') then DM.BillingCountryCode
			else 'ROW'
		end as BillingCountryCode,							
		0  as TotalUpsell_Sold,					
		0  as TotalUpsell_Delivered,					
		0  as TotalUpsell,
		SUM(ISNULL(dm.NetOrderAmount,0)) as TotalSales,
		cast(0 as bit) as UpSellFlag
	from  Marketing.DMPurchaseOrders DM
	where DM.DateOrdered>=@ReportStartDate
	group by year(DM.DateOrdered),MONTH(DM.DateOrdered),datawarehouse.Staging.GetMonday(DM.DateOrdered),								
	cast(DM.DateOrdered as Date),DM.OrderSource,DM.CurrencyCode,DM.CSRID_Actual,
	case when Dm.BillingCountryCode in ('US','USA') then 'US'
	when DM.BillingCountryCode in ('CA','AU','GB') then DM.BillingCountryCode
	else 'ROW'
	end


    if @FlagFullRefresh = 1 
    begin
    truncate table Marketing.CC_Upsell_Report_Adcode
    end

	delete from Marketing.CC_Upsell_Report_Adcode
	where WeekOrdered >= @ReportStartDate
	
	insert into Marketing.CC_Upsell_Report_Adcode
	select * from Staging.CC_Upsell_Report_Adcode_Temp

    -- Drop the temp table
    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'CC_Upsell_Report_Adcode_Temp')
		DROP TABLE Staging.CC_Upsell_Report_Adcode_Temp
	
	IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'CC_Upsell_Items_Temp_Adcode')
		DROP TABLE Staging.CC_Upsell_Items_Temp_Adcode

    
END



GO
