SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[GetCC_MonthlyAddonUpsell_Report]
AS
--- Proc Name:    GetCC_MonthlyAddonUpsell_Report
--- Purpose:      To capture the results of Customer Care Montly AddOn Upsell program
--- Input Parameters: None
---               
--- Updates:
--- Name                      Date        Comments
--- Preethi Ramanujam		  9/6/2011    New
BEGIN
	set nocount on
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

    DECLARE @ReportDate datetime

    set @ReportDate = GETDATE()

    -- Get sales for Sets used in upsell
    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'CC_MonthlyAddonUpsell_Report_Temp')
          DROP TABLE Staging.CC_MonthlyAddonUpsell_Report_Temp

    select a.CustomerID, A.OrderID,                                                                 
          convert(datetime,convert(varchar,A.DateOrdered,101)) as DateOrdered, 
          Staging.GetMonday(a.DateOrdered) as WeekOf,
          YEAR(a.DateOrdered) YearOrdered,
          MONTH(a.Dateordered) MonthOrdered,
          DAY(a.DateOrdered) DayOrdered,                                                            
          A.OrderSource, A.StatusCode, 
		  os.SalesStatusCode,
          A.CSRID_actual CSRID,                                                         
          C.BundleID, c.BundleName,                                                   
          C.CourseID, C.CourseName, C.Parts, C.TotalQuantity,                                                         
          isnull(a.CurrencyCode,'USD') CurrencyCode, C.TotalSales,
          c.ItemsLevelAdcode,
          c.ItemsLevelAdcodeName,
          c.ItemsLevelCatalogCode,
          c.ItemsLevelCatalogName,
          @ReportDate as ReportUpdateDate
    into Staging.CC_MonthlyAddonUpsell_Report_Temp                                               
    from Marketing.DMPurchaseOrders a (nolock)
    join Staging.SalesStatus os (nolock) on a.StatusCode = os.SalesStatusCode           
	join  (select c.Orderid, c.CustomerID, C.BundleID, 
					e.CourseName as BundleName,                                                   
					C.CourseID, C.CourseName, C.Parts, C.TotalQuantity,                                                         
					C.TotalSales,
					c.AdCode as ItemsLevelAdcode,
					d.AdcodeName as ItemsLevelAdcodeName,
					d.CatalogCode as ItemsLevelCatalogCode,
					d.CatalogName as ItemsLevelCatalogName
			from marketing.dmpurchaseorderitems c 
			join (select * from  Mapping.vwAdcodesAll
				where md_PromotionTYpeID = 128) d on c.AdCode = d.AdCode
			left outer join Mapping.dmcourse e on c.BundleID = e.CourseID  
			where c.totalsales > 0 )c on a.OrderID = c.orderid
    where a.OrderSource = 'P'

/*
    select a.CustomerID, A.OrderID,                                                                 
          convert(datetime,convert(varchar,A.DateOrdered,101)) as DateOrdered, 
          Staging.GetMonday(a.DateOrdered) as WeekOf,
          YEAR(a.DateOrdered) YearOrdered,
          MONTH(a.Dateordered) MonthOrdered,
          DAY(a.DateOrdered) DayOrdered,                                                            
          A.OrderSource, A.StatusCode, 
		  os.SalesStatusCode,
          A.CSRID,                                                         
          C.BundleID, e.CourseName as BundleName,                                                   
          C.CourseID, C.CourseName, C.Parts, C.TotalQuantity,                                                         
          isnull(a.CurrencyCode,'USD') CurrencyCode, C.TotalSales,
          c.AdCode as ItemsLevelAdcode,
          d.AdcodeName as ItemsLevelAdcodeName,
          d.CatalogCode as ItemsLevelCatalogCode,
          d.CatalogName as ItemsLevelCatalogName/*,
          @ReportDate as ReportUpdateDate
    into Staging.CC_MonthlyAddonUpsell_Report_Temp*/                                                
    from Staging.vworders a (nolock)
    join Staging.SalesStatus os (nolock) on a.StatusCode = os.SalesStatusCode           
	join marketing.dmpurchaseorderitems c on a.orderid = c.orderid and a.customerid = c.customerid    
	join (select * from  Mapping.vwAdcodesAll
		where md_PromotionTYpeID = 128) d on c.AdCode = d.AdCode
    left outer join Mapping.dmcourse e on c.BundleID = e.CourseID  
    where c.totalsales > 0
    and a.OrderSource = 'P'
*/

    -- Update the main table

    truncate Table Marketing.CC_MonthlyAddonUpsell_Report

    insert into Marketing.CC_MonthlyAddonUpsell_Report
    select * from Staging.CC_MonthlyAddonUpsell_Report_Temp

    -- Drop the temp table
    DROP TABLE Staging.CC_MonthlyAddonUpsell_Report_Temp
    
END
GO
