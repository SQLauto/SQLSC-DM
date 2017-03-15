SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[GetDailyDeals_Report]
AS
--- Proc Name:    GetDailDeals_Report 
--- Purpose:      Create daily deals report for call center
--- Input Parameters: None
---               
--- Updates:
--- Name          Date        Comments
--- Preethi Ramanujam   6/10/2010   New
BEGIN
	set nocount on
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

    DECLARE @ReportDate datetime

    set @ReportDate = GETDATE()

    -- Get sales for courses from daily deals
    IF object_id('Staging.DailyDeals_Report') is not null
    DROP TABLE Staging.DailyDeals_Report

    select a.CustomerID, A.OrderID,                                                                 
          convert(datetime,convert(varchar,A.DateOrdered,101)) as DateOrdered,
          YEAR(A.DateOrdered) YearOrdered,
          MONTH(A.Dateordered) MonthOrdered,
          DAY(A.DateOrdered) DayOrdered,
          Staging.GetMonday(a.DateOrdered) as WeekOf,                                                   
          A.OrderSource,                                                          
          A.StatusCode, 
          os.SalesStatusValue as [Description],
--          B.StatusDesc, 
          A.CSRID,                                                            
          C.BundleID, e.CourseName as BundleName,                                                   
          C.CourseID, C.CourseName, C.Parts, C.TotalQuantity,                                                         
          isnull(a.CurrencyCode,'USD') CurrencyCode, C.TotalSales,
          @ReportDate as ReportUpdateDate
    into Staging.DailyDeals_Report                                             
    from Staging.vworders a 
--          (select *                                                         
--          from superstardw.dbo.CCQlkStatusCodes                                                           
--          where ccqtablename = 'Orders'                                                       
--          and ccqcolumnname = 'StatusCode')b on b.statusvalue = a.statuscode join        
    join Staging.SalesStatus os (nolock) on a.StatusCode = os.SalesStatusCode           
    join marketing.dmpurchaseorderitems c on a.orderid = c.orderid and                                                        
                                                                      a.customerid = c.customerid
--          ccqdw.dbo.OrderCurrency d on a.orderid = d.orderid    
    left outer join Mapping.dmcourse e on c.BundleID = e.CourseID                                              
    where a.dateordered >=  '5/15/2011' --dateadd(day,-1,convert(datetime,convert(varchar,getdate(),101)))                                                               
    and c.courseid in (select distinct CourseID from Mapping.DailyDeals_CourseList)                                                             
    and c.totalsales > 0
    and a.OrderSource <> 'W'

    -- Get sales for sets from daily deals
    IF object_id('Staging.DailyDeals_Report_Bundles') is not null
    DROP TABLE Staging.DailyDeals_Report_Bundles
          
    select 
        a.CustomerID, A.OrderID,                                                                 
        convert(datetime,convert(varchar,A.DateOrdered,101)) as DateOrdered,    
        YEAR(A.DateOrdered) YearOrdered,
        MONTH(A.Dateordered) MonthOrdered,
        DAY(A.DateOrdered) DayOrdered,
        Staging.GetMonday(a.DateOrdered) as WeekOf,                                                                     
        A.OrderSource,                                                          
        A.StatusCode, 
        --          B.StatusDesc, 
        os.SalesStatusValue as [Description],
        A.CSRID,                                                            
        C.BundleID, e.CourseName as BundleName,                                                   
        C.CourseID, C.CourseName, C.Parts, C.TotalQuantity,                                                         
        isnull(a.CurrencyCode,'USD') CurrencyCode, C.TotalSales,
        @ReportDate as ReportUpdateDate
    into Staging.DailyDeals_Report_Bundles                                           
    from Staging.vworders a 
--          (select *                                                         
--          from superstardw.dbo.CCQlkStatusCodes                                                           
--          where ccqtablename = 'Orders'                                                       
--          and ccqcolumnname = 'StatusCode')b on b.statusvalue = a.statuscode 
    join Staging.SalesStatus os (nolock) on a.StatusCode = os.SalesStatusCode
	join marketing.dmpurchaseorderitems c on a.orderid = c.orderid and a.customerid = c.customerid 
--          ccqdw.dbo.OrderCurrency d on a.orderid = d.orderid    
	left outer join Mapping.dmcourse e on c.BundleID = e.CourseID                                              
    where a.dateordered >=  '5/15/2011' --dateadd(day,-1,convert(datetime,convert(varchar,getdate(),101)))                                                               
    and c.BundleID in (select distinct CourseID from Mapping.DailyDeals_CourseList)                                                             
    and c.totalsales > 0
    and a.OrderSource <> 'W'

    -- if the date and course combination does not exist, then drop the rows.

    -- Drop if there was no daily deal for that day
    delete a
    -- select a.*
    from Staging.DailyDeals_Report a left outer join
          Mapping.DailyDeals_CourseList b on convert(datetime,convert(varchar,a.DateOrdered,101)) = b.DateOnSale
    where b.DateOnSale is null

    delete a
    -- select a.*
    from Staging.DailyDeals_Report_Bundles a left outer join
          Mapping.DailyDeals_CourseList b on convert(datetime,convert(varchar,a.DateOrdered,101)) = b.DateOnSale
    where b.DateOnSale is null

    -- Drop if the course was not offered that day as part of daily deals
    delete a
    -- select a.*
    from Staging.DailyDeals_Report a left outer join
          Mapping.DailyDeals_CourseList b on a.CourseID = B.CourseID
                                  and convert(datetime,convert(varchar,a.DateOrdered,101)) = b.DateOnSale
    where b.CourseID is null

    delete a
    -- select a.*
    from Staging.DailyDeals_Report_Bundles a left outer join
          Mapping.DailyDeals_CourseList b on a.bundleID = B.CourseID
                                  and convert(datetime,convert(varchar,a.DateOrdered,101)) = b.DateOnSale
    where b.CourseID is null

    -- Drop all the bundles
    delete a
    -- select a.*
    from Staging.DailyDeals_Report a left outer join
          Mapping.DailyDeals_CourseList b on a.CourseID = B.CourseID
                                  and convert(datetime,convert(varchar,a.DateOrdered,101)) = b.DateOnSale
    where a.BundleID > 0



    -- Add bundles into main table
    INSERT into Staging.DailyDeals_Report
    select * from Staging.DailyDeals_Report_Bundles
    
    -- Add data to the main table.
    TRUNCATE TABLE Marketing.DailyDeals_Report
    
    INSERT into Marketing.DailyDeals_Report
    select * from staging.DailyDeals_Report


    drop table Staging.DailyDeals_Report
    
    drop table Staging.DailyDeals_Report_Bundles    

END
GO
