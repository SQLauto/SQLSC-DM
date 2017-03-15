SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[GetCC_SetsUpsell_Report]
AS
--- Proc Name:    GetCC_SetsUpsell_Report
--- Purpose:      To capture the results of Customer Care Sets Upsell program
--- Input Parameters: None
---               
--- Updates:
--- Name                      Date        Comments
--- Preethi Ramanujam   7/7/2011    New
BEGIN
	set nocount on
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

    DECLARE @ReportDate datetime

    set @ReportDate = GETDATE()

    -- Get sales for Sets used in upsell
    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Staging.CC_SetsUpsell_Report_Temp')
          DROP TABLE Staging.CC_SetsUpsell_Report_Temp

    select a.CustomerID, A.OrderID,                                                                 
          convert(datetime,convert(varchar,A.DateOrdered,101)) as DateOrdered, 
          Staging.GetMonday(a.DateOrdered) as WeekOf,
          YEAR(a.DateOrdered) YearOrdered,
          MONTH(a.Dateordered) MonthOrdered,
          DAY(a.DateOrdered) DayOrdered,                                                            
          A.OrderSource, A.StatusCode, 
--          B.StatusDesc, 
			os.SalesStatusCode,
          A.CSRID,                                                         
          C.BundleID, e.CourseName as BundleName,                                                   
          C.CourseID, C.CourseName, C.Parts, C.TotalQuantity,                                                         
          isnull(a.CurrencyCode,'USD') CurrencyCode, C.TotalSales,
          @ReportDate as ReportUpdateDate,
          e.FlagBuffetSet
    into Staging.CC_SetsUpsell_Report_Temp                                                
    from Staging.vworders a (nolock)
--          (select *                                                         
--          from superstardw.dbo.CCQlkStatusCodes                                                           
--          where ccqtablename = 'Orders'                                                       
--          and ccqcolumnname = 'StatusCode')b on b.statusvalue = a.statuscode 
    join Staging.SalesStatus os (nolock) on a.StatusCode = os.SalesStatusCode           
	join marketing.dmpurchaseorderitems c on a.orderid = c.orderid and a.customerid = c.customerid 
--    left outer join ccqdw.dbo.OrderCurrency d on a.orderid = d.orderid    
    left outer join Mapping.dmcourse e on c.BundleID = e.CourseID    
    join Mapping.CC_SetsUpsell_SetsList f on c.BundleID = f.BundleID
                                                                and c.DateOrdered between f.StartDate and dateadd(day,1,f.StopDate)
    where c.totalsales > 0
    and a.OrderSource = 'P'

    -- Update the main table

    truncate Table Marketing.CC_SetsUpsell_Report

    insert into Marketing.CC_SetsUpsell_Report
    select * from Staging.CC_SetsUpsell_Report_Temp

    -- Drop the temp table
    DROP TABLE Staging.CC_SetsUpsell_Report_Temp
    
END
GO
