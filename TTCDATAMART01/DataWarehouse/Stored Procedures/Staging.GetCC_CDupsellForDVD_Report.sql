SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[GetCC_CDupsellForDVD_Report]
AS
--- Proc Name:    GetCC_CDupsellForDVD_Report
--- Purpose:      To capture the results of Customer Care upsell for CD when customer purchased a DVD
--- Input Parameters: None
---               
--- Updates:
--- Name                      Date        Comments
--- Preethi Ramanujam   7/7/2011    New
    DECLARE 
    	@ReportDate datetime
BEGIN
	set nocount on

    set @ReportDate = GETDATE()

    -- Get sales for Sets used in upsell
    if object_id('Staging.CC_CDUpsellForDVD_Report_Temp') is not null drop table Staging.CC_CDUpsellForDVD_Report_Temp
    if object_id('Staging.CC_CDUpsellForDVD_Report_Temp2') is not null drop table Staging.CC_CDUpsellForDVD_Report_Temp2    

    select a.CustomerID, A.OrderID,                                                                 
          convert(datetime,convert(varchar,A.DateOrdered,101)) as DateOrdered, 
          Staging.GetMonday(a.DateOrdered) as WeekOf,
          YEAR(a.DateOrdered) YearOrdered,
          MONTH(a.Dateordered) MonthOrdered,
          DAY(a.DateOrdered) DayOrdered,                                                            
          A.OrderSource, A.StatusCode, os.SalesStatusCode, A.CSRID,                                                         
          C.BundleID, e.CourseName as BundleName,                                                   
          C.CourseID, C.CourseName, C.Parts, C.FormatMedia, C.TotalQuantity,                                                            
          isnull(a.CurrencyCode,'USD') CurrencyCode, C.TotalSales,
          @ReportDate as ReportUpdateDate
    into Staging.CC_CDUpsellForDVD_Report_Temp                                            
    from Staging.vworders a (nolock)
    join Staging.SalesStatus os (nolock) on a.StatusCode = os.SalesStatusCode           
--          (select *                                                         
--          from Staging.CCQlkStatusCodes                                                           
--          where ccqtablename = 'Orders'                                                       
--          and ccqcolumnname = 'StatusCode')b on b.statusvalue = a.statuscode 
	join marketing.dmpurchaseorderitems c (nolock) on a.orderid = c.orderid and a.customerid = c.customerid 
--	left outer join ccqdw..OrderCurrency d on a.orderid = d.orderid    
    left outer join Mapping.dmcourse e (nolock) on c.BundleID = e.CourseID                                        
    where c.totalsales > 0
    and a.OrderSource = 'P'
    and a.DateOrdered >= '6/27/2011'
    and c.FormatMedia in ('D','C')


    -- Keep only those orders that have both CD and DVD formats for the same courseid 
    -- in the same order and CD Price should be Parts * $10
          
    select a.*
    into Staging.CC_CDUpsellForDVD_Report_Temp2
    from Staging.CC_CDUpsellForDVD_Report_Temp a (nolock) join 
          (select * from Staging.CC_CDUpsellForDVD_Report_Temp (nolock)    
          where FormatMedia = 'D')b on a.OrderID = b.OrderID
                                              and a.CourseID = b.CourseID
    where a.FormatMedia = 'C'
    and a.TotalSales = a.Parts * 10                                         

    -- Drop all the orders with the exception of the above
    delete a
    from Staging.CC_CDUpsellForDVD_Report_Temp a left outer join  
          Staging.CC_CDUpsellForDVD_Report_Temp2 b (nolock) on a.OrderID = b.OrderID
    where b.OrderID is null 

    -- Drop all other courses
    delete a
    from Staging.CC_CDUpsellForDVD_Report_Temp a join 
          (select OrderID, CourseID, COUNT(CourseID) CourseCount
          from Staging.CC_CDUpsellForDVD_Report_Temp (nolock)
          group by OrderID, CourseID
          having COUNT(CourseID) < 2)b on a.OrderID = b.OrderID
                                                    and a.CourseID = b.CourseID


    -- Update the main table

    truncate table  Marketing.CC_CDUpsellForDVD_Report

    insert into Marketing.CC_CDUpsellForDVD_Report
    select * from Staging.CC_CDUpsellForDVD_Report_Temp (nolock)

    -- Drop all the temp tables
    if object_id('Staging.CC_CDUpsellForDVD_Report_Temp') is not null drop table Staging.CC_CDUpsellForDVD_Report_Temp
    if object_id('Staging.CC_CDUpsellForDVD_Report_Temp2') is not null drop table Staging.CC_CDUpsellForDVD_Report_Temp2
END
GO
