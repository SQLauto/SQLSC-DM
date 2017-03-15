SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Staging].[GetCC_Upsell_Report]
	@FlagFullRefresh int = 0
AS
--- Proc Name:    GetCC_Upsell_Report
--- Purpose:      To capture the results of Customer Care Upsell program
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
		select @ReportStartDate = DATEADD(Wk, -2, datawarehouse.Staging.GetMonday(GETDATE()))	--Delta does Monday 2 weeks back

    -- Get orders and items information with crosell flag set to 1
    print 'Get orders and items information with crosell flag set to 1'
    
    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'CC_Upsell_Items_Temp')
          DROP TABLE Staging.CC_Upsell_Items_Temp

	select Orderid, 
		Orderitemid,
		ITEMID, 
		CrossSell, 
		LineType,  
		Quantity, 
		SALESPRICE, 
		(Quantity * SALESPRICE) TotalSales									
	into Staging.CC_Upsell_Items_Temp
	from Marketing.CCUpsellItems 
	where CrossSell = 1
	and ITEMID not like 's%'

    -- Get Order level data...
    print 'Get Order level data.'
    
    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'CC_Upsell_Report_Temp')
          DROP TABLE Staging.CC_Upsell_Report_Temp

	select @ReportDate as ReportDate,
		year(a.DateOrdered) YearOrdered,									
		MONTH(a.DateOrdered) MonthOrdered,								
		datawarehouse.Staging.GetMonday(a.DateOrdered) WeekOrdered,								
		cast(a.DateOrdered as Date) DateOrdered,								
		a.OrderSource,								
		a.CurrencyCode,	
		a.CSRID_Actual as CSRID,
		case when a.BillingCountryCode in ('US','USA') then 'US'
			when a.BillingCountryCode in ('CA','AU','GB') then a.BillingCountryCode
			else 'ROW'
		end as BillingCountryCode,							
		sum(a.TotalCourseSales) TotalCourseSales,								
		sum(a.TotalTranscriptSales) TotalTranscriptSales,								
		sum(a.NetOrderAmount) NetOrderAmount,								
		sum(a.ShippingCharge) ShippingCharge,								
		sum(a.DiscountAmount) DiscountAmount,								
		sum(a.Tax) Tax,								
		sum(b.TotalSales)  as TotalUpsell_Sold,					
		sum(c.TotalSales)  as TotalUpsell_Delivered,					
		sum(d.TotalSales)  as TotalUpsell					
	into Staging.CC_Upsell_Report_Temp									
	from (select *									
		from DataWarehouse.Marketing.DMPurchaseOrders 								
		where DateOrdered >= @ReportStartDate) a 								
		left join								
		(select OrderID, SUM(TotalSales) TotalSales								
		from staging.CC_Upsell_Items_Temp								
		where LineType = 'ItemSold'
		group by OrderID) b on a.OrderID = b.OrderID									
		left join								
		(select OrderID, SUM(TotalSales) TotalSales								
		from staging.CC_Upsell_Items_Temp								
		where LineType = 'ItemDelivered'
		group by OrderID)c on a.OrderID = c.OrderID										
		left join								
		(select OrderID, SUM(TotalSales) TotalSales								
		from staging.CC_Upsell_Items_Temp
		group by OrderID)d on a.OrderID = d.OrderID								
	group by year(a.DateOrdered),									
		MONTH(a.DateOrdered),								
		datawarehouse.Staging.GetMonday(a.DateOrdered),								
		cast(a.DateOrdered as Date),								
		a.OrderSource,								
		a.CurrencyCode,	
		a.CSRID_Actual,
		case when a.BillingCountryCode in ('US','USA') then 'US'
			when a.BillingCountryCode in ('CA','AU','GB') then a.BillingCountryCode
			else 'ROW'
		end		          
          
    -- Update the main table
    print 'Update the main table'

	delete from Marketing.CC_Upsell_Report
	where WeekOrdered >= @ReportStartDate
	
	insert into Marketing.CC_Upsell_Report
	select * from Staging.CC_Upsell_Report_Temp
					

    -- Drop the temp table
    DROP TABLE Staging.CC_Upsell_Items_Temp
    
    DROP TABLE Staging.CC_Upsell_Report_Temp
    
END


GO
