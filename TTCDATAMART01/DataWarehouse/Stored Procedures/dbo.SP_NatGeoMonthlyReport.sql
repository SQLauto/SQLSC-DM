SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [dbo].[SP_NatGeoMonthlyReport]  
AS  
BEGIN  
-- Report 1: Monthly report.   
-- All Co-brand courses by format - Sales and Units  
-- irrespective of new/existing customers or TTC/NG marketing  
-- Step 1: Make a copy of \\File1\Groups\Marketing\Marketing Strategy and Analytics\NateGeoReporting\NatGeo_MonthlyReport_YYYYMMDD_TEMPLATE.xlsx  
-- and save as this months file NatGeo_MonthlyReport_201407xx.xlsx  
-- Step 2: to change: 20150402  - this is the date you run the nat geo report  
-- *************************************************************  
/***************************************************************************************************************   
            Co_Brand Course cources:  
            --> A. Co_Brand Course   
            --> B. Co_Brand New Course only   
**************************************************************************************************************/  
DECLARE @ReportDate date  
set @ReportDate = cast(GETDATE()  as DATE)
select @ReportDate  
  
  
Print 'Orders placed which have Co-Branded Courses'  
select a.DateOrdered, a.CustomerID, a.AdCode, b.AdcodeName, a.Orderid,  
      case when a.StatusCode = 4 then 'CancelledOrder'  
            else 'SalesOrder'  
      end as OrderStatus,  
      case when b.MD_PromotionTypeID = 132 then 'NG Sales Channels'  
            else 'TTC Sales Channels'  
      end as MarketingOwner,  
      case when a.BillingCountryCode in ('GB','US','CA','AU') then a.BillingCountryCode  
            else 'ROW'  
      end BillingCountryCode,  
      case when e.SequenceNum = 1 then 'A. New Customer'  
            when e.SequenceNum > 1 then 'B. Existing Customer'  
            else 'C. Unknown'  
      end CustomerType,  
      a.CurrencyCode,  
      coalesce(NGC.CourseType,'C. Non Co_Brand Course') as CourseType,  
      c.CourseID, c.CourseName,   
      case when d.MediaTypeID in ('CD','DVD','Transcript') Then ltrim(rtrim(d.MediaTypeID))  
            when d.MediaTypeID like '%DownloadV%' then 'Video Download'  
            when d.MediaTypeID like '%DownloadA%' then 'Audio Download'  
            when d.MediaTypeID like '%DownloadT%' then 'Digital Transcript' 
      end  as Format,  
      c.TotalQuantity, c.TotalSales,  
      @ReportDate as DateAdded,  
      a.OrderSource  
into #NatGeoByFormat      
from DataWarehouse.Staging.vwOrders a   
      left join DataWarehouse.Marketing.DMPurchaseOrders e on a.OrderID = e.OrderID  
      left join DAXImports..DAX_SalesStatus f on a.StatusCode = f.SalesStatusCode  
      left join DataWarehouse.Mapping.vwAdcodesAll b on a.AdCode = b.AdCode   
      join DataWarehouse.Marketing.DMPurchaseOrderItems c on a.OrderID = c.OrderID   
      join DataWarehouse.Staging.InvItem d on c.StockItemID = d.StockItemID  
      inner join Datawarehouse.Mapping.NatgeoCourses NGC on NGC.CourseID = C.CourseID  
where a.DateOrdered >= '1/15/2014'  
/*and c.CourseID in (7901,7912,7923, 3502)*/  
and b.MD_PromotionTypeID <> 132  /*132 is NatGeo channel*/  
and c.TotalQuantity > 0  
  
  
/*****************************************************************************************************************  
            Co_Brand Course cources:  
            -->Returned cources  
******************************************************************************************************************/  
  
/*
Print 'Issues where sequence not available in #NatGeoByFormat'  
select * from #NatGeoByFormat  
where CustomerType like 'C%'  
and OrderStatus like 'Sale%'    
*/  
  
select distinct e.Orderid as ReturnID, a.OrderID  
into #NatGeoByFormatReturns  
from #NatGeoByFormat a  
join (select OrderID, OriginalOrderID, C.CourseID, StockItemID,  
            sum(TotalQuantity) Units,  
            sum(TotalSales) Sales  
      from DataWarehouse.Marketing.DMPurchaseOrderItems C  
      inner join Datawarehouse.Mapping.NatgeoCourses NGC on NGC.CourseID = C.CourseID  
      where DateOrdered >= '1/15/2014'  
      /*and CourseID in (7901,7912,7923, 3502)*/  
      and OrderID like 'RET%'  
      group by OrderID, OriginalOrderID, C.CourseID, StockItemID)e on a.OrderID = e.OriginalOrderID  
  
  
Print 'Inserting Returns into #NatGeoByFormat'  
insert into  #NatGeoByFormat    
select a.DateOrdered, a.CustomerID, a.AdCode, b.AdcodeName, a.Orderid,  
      'Returns' as OrderStatus,  
      'TTC Sales Channels' as MarketingOwner,  
      case when a.BillingCountryCode in ('GB','US','CA','AU') then a.BillingCountryCode  
            else 'ROW'  
      end BillingCountryCode,  
      case when e.SequenceNum = 1 then 'A. New Customer'  
            when e.SequenceNum > 1 then 'B. Existing Customer'  
            else 'C. Unknown'  
      end CustomerType,  
      a.CurrencyCode,  
      coalesce(NGC.CourseType,'C. Non Co_Brand Course') as CourseType,  
      c.CourseID, c.CourseName,   
      case when d.MediaTypeID in ('CD','DVD','Transcript') Then ltrim(rtrim(d.MediaTypeID))  
            when d.MediaTypeID like '%DownloadV%' then 'Video Download'  
            when d.MediaTypeID like '%DownloadA%' then 'Audio Download'  
            when d.MediaTypeID like '%DownloadT%' then 'Digital Transcript' 
      end  as Format,  
      c.TotalQuantity, c.TotalSales,  
      @ReportDate as DateAdded,  
      e.OrderSource  
from DataWarehouse.Staging.vwOrders a   
      left join DataWarehouse.Marketing.DMPurchaseOrders e on a.OrderID = e.OrderID  
      join #NatGeoByFormatReturns ret on a.OrderID = ret.ReturnID  
      left join DAXImports..DAX_SalesStatus f on a.StatusCode = f.SalesStatusCode  
      left join DataWarehouse.Mapping.vwAdcodesAll b on a.AdCode = b.AdCode   
      join DataWarehouse.Marketing.DMPurchaseOrderItems c on a.OrderID = c.OrderID   
      join DataWarehouse.Staging.InvItem d on c.StockItemID = d.StockItemID   
      inner join Datawarehouse.Mapping.NatgeoCourses NGC on NGC.CourseID = C.CourseID  
where a.DateOrdered >= '1/15/2014'  
/*and c.CourseID in (7901,7912,7923, 3502)*/  

Print 'Delete data from previous run for the current month'
Delete from DataWarehouse.Marketing.NatGeoCoBrand     
where YearOrdered = YEAR(GETDATE())  
and MonthOrdered = MONTH(GETDATE())    
  
Print ' All Co Branded Courses and Returned orders Inserted into final table Datawarehouse.Marketing.NatGeoCoBrand'  
  
Insert into Datawarehouse.Marketing.NatGeoCoBrand       
select YEAR(dateordered) YearOrdered,  
      Month(DateOrdered) MonthOrdered,   
      MarketingOwner,  
      BillingCountryCode,  
      OrderStatus,  
      CustomerType,  
      CurrencyCode,  
      CourseType,  
      CourseID, CourseName, Format,  
      sum(TotalQuantity) Units,  
      sum(TotalSales) Sales,  
      MIN(DateOrdered) MinDateOrdered,  
      max(DateOrdered) MaxDateOrdered,      
      @ReportDate As ReportDate  
from #NatGeoByFormat  
group by YEAR(dateordered),  
      Month(DateOrdered),   
      MarketingOwner,  
      BillingCountryCode,  
      OrderStatus,  
      CustomerType,  
      CurrencyCode,       
      CourseType,  
      CourseID, CourseName, Format  
order by 1,2,3,4,5,6,7,9  
  
Drop table #NatGeoByFormat  
Drop table #NatGeoByFormatReturns  
  
-- RUN TILL HERE step 2  
-- *************************************************************  
-- Step: 3 - Start here again for report 2  
-- *************************************************************  
-- Start from here  
-- Report 2: For all Nat Geo Marketing  
  
  
/************************************************************************************************************************  
           NatGeo Marketing:  
  
           -->Orders Placed Using NatGeo Marketing Channel  
*************************************************************************************************************************/  
  
  
Print 'Orders placed Using NatGeo Marketing Channel'  
  
select a.DateOrdered, a.CustomerID, a.AdCode, b.AdcodeName, a.Orderid,  
      case when a.StatusCode = 4 then 'Cancelled'  
            else 'Sales Order'  
      end as OrderStatus,  
      case when b.MD_PromotionTypeID = 132 then 'NG Sales Channels'  
            else 'TTC Sales Channels'  
      end as MarketingOwner,  
      case when a.BillingCountryCode in ('GB','US','CA','AU') then a.BillingCountryCode  
            else 'ROW'  
      end BillingCountryCode,  
      case when e.SequenceNum = 1 then 'A. New Customer'  
            when e.SequenceNum > 1 then 'B. Existing Customer'  
            else 'C. Unknown'  
      end CustomerType,  
      a.CurrencyCode,  
      coalesce(NGC.CourseType,'C. Non Co_Brand Course') as CourseType,  
      c.CourseID, c.CourseName,   
      case when d.MediaTypeID in ('CD','DVD','Transcript') Then ltrim(rtrim(d.MediaTypeID))  
            when d.MediaTypeID like '%DownloadV%' then 'Video Download'  
            when d.MediaTypeID like '%DownloadA%' then 'Audio Download' 
            when d.MediaTypeID like '%DownloadT%' then 'Digital Transcript'  
      end  as Format,  
      c.TotalQuantity, c.TotalSales,  
      @ReportDate DateAdded,  
      e.OrderSource  
into #NatGeoMktByFormat   
from DataWarehouse.Staging.vwOrders a   
      left join DataWarehouse.Marketing.DMPurchaseOrders e on a.OrderID = e.OrderID  
      left join DAXImports..DAX_SalesStatus f on a.StatusCode = f.SalesStatusCode  
      left join DataWarehouse.Mapping.vwAdcodesAll b on a.AdCode = b.AdCode   
      join DataWarehouse.Marketing.DMPurchaseOrderItems c on a.OrderID = c.OrderID   
      join DataWarehouse.Staging.InvItem d on c.StockItemID = d.StockItemID   
      inner join DataWarehouse.Mapping.NatgeoCourses NGC on NGC.CourseID=C.CourseID  
where a.DateOrdered >= '1/15/2014'  
/*and c.CourseID in (7901,7912,7923, 3502)*/  
and b.MD_PromotionTypeID = 132 /*132 is NatGeo channel*/  
and c.TotalQuantity > 0  


/*  
Print 'Issues with Orders placed Using NatGeo Marketing Channel where sequence not available in #NatGeoMktByFormat '  
select * from #NatGeoMktByFormat    
where CustomerType like 'C%'  
*/
/*  
select * from DAXImports..dax_orderitemexport  
where orderid in (  
select orderid from #NatGeoMktByFormat    
where CustomerType like 'C%')  
*/  
  
Print 'Inserting Returns into #NatGeoMktReturns'  
  
select distinct e.Orderid as ReturnID, a.OrderID  
into #NatGeoMktByFormatReturns  
from #NatGeoMktByFormat a  
join (select OrderID, OriginalOrderID, C.CourseID, StockItemID,  
            sum(TotalQuantity) Units,  
            sum(TotalSales) Sales  
      from DataWarehouse.Marketing.DMPurchaseOrderItems C  
     inner join Datawarehouse.Mapping.NatgeoCourses NGC on NGC.CourseID = C.CourseID  
      where DateOrdered >= '1/15/2014'  
/*    and CourseID in (7901,7912,7923, 3502) */  
      and OrderID like 'RET%'  
      group by OrderID, OriginalOrderID, C.CourseID, StockItemID)e on a.OrderID = e.OriginalOrderID  
  
/*  
--select * from #NatGeoMktReturns  
--select a.*, c.StockItemID, c.CourseName, c.CourseID  
--from DataWarehouse.Staging.vwOrders a   
--    join #NatGeoMktByFormatReturns ret on a.OrderID = ret.ReturnID  
--    left join DataWarehouse.Marketing.DMPurchaseOrderItems c on a.OrderID = c.OrderID  
*/  
  
insert into  #NatGeoMktByFormat       
select a.DateOrdered, a.CustomerID, a.AdCode, b.AdcodeName, a.Orderid,  
      'Returns' as OrderStatus,  
      'NG Sales Channels' as MarketingOwner,  
      case when a.BillingCountryCode in ('GB','US','CA','AU') then a.BillingCountryCode  
            else 'ROW'  
      end BillingCountryCode,  
      'D. Returns' CustomerType,  
      a.CurrencyCode,  
      coalesce(NGC.CourseType,'C. Non Co_Brand Course') as CourseType,  
      c.CourseID, c.CourseName,   
      case when d.MediaTypeID in ('CD','DVD','Transcript') Then ltrim(rtrim(d.MediaTypeID))  
            when d.MediaTypeID like '%DownloadV%' then 'Video Download'  
            when d.MediaTypeID like '%DownloadA%' then 'Audio Download'  
            when d.MediaTypeID like '%DownloadT%' then 'Digital Transcript' 
      end  as Format,  
      c.TotalQuantity, c.TotalSales,  
      @ReportDate as DateAdded,  
      a.OrderSource  
from DataWarehouse.Staging.vwOrders a   
      join #NatGeoMktByFormatReturns ret on a.OrderID = ret.ReturnID  
      left join DAXImports..DAX_SalesStatus f on a.StatusCode = f.SalesStatusCode  
      left join DataWarehouse.Mapping.vwAdcodesAll b on a.AdCode = b.AdCode   
      left join DataWarehouse.Marketing.DMPurchaseOrderItems c on a.OrderID = c.OrderID   
      left join DataWarehouse.Staging.InvItem d on c.StockItemID = d.StockItemID   
      inner join DataWarehouse.Mapping.NatgeoCourses NGC on NGC.CourseID=C.CourseID  
where a.DateOrdered >= '1/15/2014'  
/*and c.CourseID in (7901,7912,7923, 3502)*/  

    
  
Print ' All Orders  and Returned orders Placed using NatGeo Marketing Channels Inserted into final table Datawarehouse.Marketing.NatGeoCoBrand'  
  
insert into Datawarehouse.Marketing.NatGeoCoBrand  
select YEAR(dateordered) YearOrdered,  
      Month(DateOrdered) MonthOrdered,   
      MarketingOwner,  
      BillingCountryCode,  
      OrderStatus,  
      CustomerType,  
      CurrencyCode,  
      CourseType,  
      CourseID, CourseName, Format,  
      sum(TotalQuantity) Units,  
      sum(TotalSales) Sales,  
      MIN(DateOrdered) MinDateOrdered,  
      max(DateOrdered) MaxDateOrdered,      
      @ReportDate As ReportDate  
from #NatGeoMktByFormat  
group by YEAR(dateordered),  
      Month(DateOrdered),   
      MarketingOwner,  
      BillingCountryCode,  
      OrderStatus,  
      CustomerType,  
      CurrencyCode,       
      CourseType,  
      CourseID, CourseName, Format  
order by 1,2,3,4,5,6,7,9  
  
  
  
  
  
--- Run till here for Step 3  
-- **************************************************  
-- Then copy the results of this and paste it in the tab: Co_Brand_Courses  
/************************************************************Co_Brand_Courses Report********************************************************************/  
print 'Co_Brand_Courses Report,Copy these results of this and paste it in the tab: Co_Brand_Courses'  
select * from DataWarehouse.Marketing.NatGeoCoBrand     
where YearOrdered = case when MONTH(GETDATE()) = 1 then YEAR(GETDATE())-1 else YEAR(GETDATE()) end  
and MonthOrdered = case when MONTH(GETDATE()) = 1 then 12 else MONTH(GETDATE())-1 end  
/************************************************************Co_Brand_Courses Report********************************************************************/  
-- Make sure that the pivots in tabs Co_Brand_Courses_Pivot_TTC and Co_Brand_Courses_Pivot_NG  
-- are pointing to the right file and refresh. QC numbers.   
-- can compare prior month file to see if numbers are close...  
  
-- Step 4:   
-- Create New cust table  
--drop table #NatGeoCustomers  
/*******************************************************************************************************************************************************  
                NatGeo Customers  
  
*******************************************************************************************************************************************************/  
  
print 'NatGeo Customers from NatGeo Marketing'  
select distinct CustomerID, OrderID, DateOrdered  
into #NatGeoCustomers  
from #NatGeoMktByFormat a    
where a.CustomerType = 'A. New Customer'  
  
print 'Other NatGeo Customer'  
select distinct a.CustomerID, a.OrderID,    
      a.DateOrdered  
into #OtherNatgeoCust     
from (select a.CustomerID, a.OrderID, a.DateOrdered, OrderSource, SequenceNum, NetOrderAmount,  
      a.AdCode, b.AdcodeName, b.CatalogCode, b.CatalogName,  
      b.ChannelID, b.MD_Channel,  
      b.MD_PromotionTypeID, b.MD_PromotionType,  
      b.MD_CampaignID, b.MD_CampaignName,  
      b.PromotionTypeID, b.PromotionType  
      from DataWarehouse.Marketing.DMPurchaseOrders a join  
            DataWarehouse.Mapping.vwAdcodesAll b on a.AdCode = b.AdCode  
      where b.MD_PromotionTypeID = 132  
      and SequenceNum = 1)a join  
      DataWarehouse.Marketing.CampaignCustomerSignature c on a.CustomerID = c.CustomerID  
where c.CountryCode in ('US', 'CA')  
--and c.FlagOkToShare = 1  --?????????????????????????????????????????????????????????????????????????????????????????????????????????????  
  
insert into #NatGeoCustomers  
select a.* from #OtherNatgeoCust a left join  
      #NatGeoCustomers b on a.CustomerID = b.CustomerID  
where b.CustomerID is null      
  
  
-- QC/Check  
/*  
select a.*, b.SequenceNum, b.NetOrderAmount, c.AdcodeName, c.MD_Channel, c.MD_PromotionType, c.MD_CampaignDesc  
from #NatGeoCustomers a   
join DataWarehouse.Marketing.DMPurchaseOrders b on a.OrderID = b.OrderID   
join DataWarehouse.Mapping.vwAdcodesAll c on b.AdCode = c.AdCode  
where MD_Channel <> 'Partners'  
*/  
print 'NatGeo Customer Non Co Branded Courses into #NatGeoNonCoBrand'  
  
select a.DateOrdered, a.CustomerID, a.AdCode, b.AdcodeName, a.Orderid,  
      case when a.StatusCode = 4 then 'Cancelled'  
            else 'Sales Order'  
      end as OrderStatus,  
      case when b.MD_PromotionTypeID = 132 then convert(varchar(20),'NG Sales Channels')  
            else convert(varchar(20),'TTC Sales Channels')  
      end as MarketingOwner,  
      case when a.BillingCountryCode in ('GB','US','CA','AU') then a.BillingCountryCode  
            else 'ROW'  
      end BillingCountryCode,  
      case when e.SequenceNum = 1 then 'A. New Customer'  
            else 'B. Existing Customer'  
      end CustomerType,  
      a.CurrencyCode,  
      coalesce(NG.CourseType,'C. Non Co_Brand Course') as CourseType,  
      c.CourseID, c.CourseName,   
     -- convert(varchar(20),d.MediaTypeID) as Format,  
      case when d.MediaTypeID in ('CD','DVD','Transcript') Then convert(varchar(20),ltrim(rtrim(d.MediaTypeID)))
            when d.MediaTypeID like '%DownloadV%' then convert(varchar(20),'Video Download')  
            when d.MediaTypeID like '%DownloadA%' then convert(varchar(20),'Audio Download')  
            when d.MediaTypeID like '%DownloadT%' then convert(varchar(20),'Digital Transcript') 
      end as Format,
      c.TotalQuantity, c.TotalSales,  
      @ReportDate as DateAdded  
into #NatGeoNonCoBrand  
from DataWarehouse.Staging.vwOrders a   
      left join DataWarehouse.Marketing.DMPurchaseOrders e on a.OrderID = e.OrderID  
      join #NatGeoCustomers ngc on a.CustomerID = ngc.CustomerID    
      left join DataWarehouse.Mapping.vwAdcodesAll b on a.AdCode = b.AdCode   
      join DataWarehouse.Marketing.DMPurchaseOrderItems c on a.OrderID = c.OrderID   
      join DataWarehouse.Staging.InvItem d on c.StockItemID = d.StockItemID   
      left join DataWarehouse.Mapping.NatgeoCourses NG on NG.CourseID=C.CourseID  
where a.DateOrdered >= '1/15/2014'  
and NG.CourseID is null /*Non Co Branded Courses*/  
and c.TotalQuantity > 0  
  
  
  
select distinct e.Orderid as ReturnID, a.OrderID  
into #NatGeoNonCoBrandReturns  
from #NatGeoNonCoBrand a  
join (select OrderID, OriginalOrderID, c.CourseID, StockItemID,  
            sum(TotalQuantity) Units,  
            sum(TotalSales) Sales  
      from DataWarehouse.Marketing.DMPurchaseOrderItems c  
            left join Datawarehouse.Mapping.NatgeoCourses NGC on NGC.CourseID = C.CourseID  
      where DateOrdered >= '1/15/2014'  
      and NGC.CourseID is null  
      and OrderID like 'RET%'  
      group by OrderID, OriginalOrderID, c.CourseID, StockItemID)e on a.OrderID = e.OriginalOrderID  
  
  
--QC  
/*  
select a.*, c.StockItemID, c.CourseName, c.CourseID  
from DataWarehouse.Staging.vwOrders a   
      join #NatGeoNonCoBrandReturns ret on a.OrderID = ret.ReturnID  
      left join DataWarehouse.Marketing.DMPurchaseOrderItems c on a.OrderID = c.OrderID  
*/  
  
print 'NatGeo Customer Non Co Branded Courses Returns into #NatGeoNonCoBrand'  
  
insert into  #NatGeoNonCoBrand        
select a.DateOrdered, a.CustomerID, a.AdCode, b.AdcodeName, a.Orderid,  
      'Returns' as OrderStatus,  
      'NG DS Returns' as MarketingOwner,  
      case when a.BillingCountryCode in ('GB','US','CA','AU') then a.BillingCountryCode  
            else 'ROW'  
      end BillingCountryCode,  
      'D. Returns' CustomerType,  
      a.CurrencyCode,  
      coalesce(NGC.CourseType,'C. Non Co_Brand Course') as CourseType,  
      c.CourseID, c.CourseName,   
      case when d.MediaTypeID in ('CD','DVD','Transcript') Then ltrim(rtrim(d.MediaTypeID))  
            when d.MediaTypeID like '%DownloadV%' then 'Video Download'  
            when d.MediaTypeID like '%DownloadA%' then 'Audio Download'  
            when d.MediaTypeID like '%DownloadT%' then 'Digital Transcript' 
      end  as Format,  
      c.TotalQuantity, c.TotalSales,  
      @ReportDate as DateAdded  
from DataWarehouse.Staging.vwOrders a   
      join #NatGeoNonCoBrandReturns ret on a.OrderID = ret.ReturnID  
      left join DAXImports..DAX_SalesStatus f on a.StatusCode = f.SalesStatusCode  
      left join DataWarehouse.Mapping.vwAdcodesAll b on a.AdCode = b.AdCode   
      left join DataWarehouse.Marketing.DMPurchaseOrderItems c on a.OrderID = c.OrderID   
      left join DataWarehouse.Staging.InvItem d on c.StockItemID = d.StockItemID   
      left join Datawarehouse.Mapping.NatgeoCourses NGC on NGC.CourseID = C.CourseID  
where a.DateOrdered >= '1/15/2014'  
and NGC.CourseID is Null  
  
-- Step4: Ends here  
-- *****************************************************  
  
-- copy and paste results of this query into tab: NG_NewCust_DS_Data  
-- Make sure that the pivot in tab NG_NewCust_DS_Pivot  
-- is pointing to the right file and refresh. QC numbers.   
-- can compare prior month file to see if numbers are close...  

Print 'Delete data from previous run for the current month'  
Delete from DataWarehouse.Marketing.NatGeoNonCoBrand   
where YearOrdered = YEAR(GETDATE())  
and MonthOrdered = MONTH(GETDATE())  

  
Print ' All Non Co Branded Orders and Returned Placed using NatGeo Customers Inserted into final table Datawarehouse.Marketing.NatGeoCoBrand'  
  
insert into DataWarehouse.Marketing.NatGeoNonCoBrand   
select YEAR(dateordered) YearOrdered,  
      Month(DateOrdered) MonthOrdered,   
      MarketingOwner,  
      BillingCountryCode,  
      OrderStatus,  
      CustomerType,  
      CurrencyCode,  
      CourseType,  
      CourseID, CourseName, Format,  
      COUNT(distinct customerID) Custs,  
      sum(TotalQuantity) Units,  
      sum(TotalSales) Sales,  
      MIN(DateOrdered) MinDateOrdered,  
      max(DateOrdered) MaxDateOrdered,      
      @ReportDate As ReportDate  
from #NatGeoNonCoBrand  
group by YEAR(dateordered),  
      Month(DateOrdered),   
      MarketingOwner,  
      BillingCountryCode,  
      OrderStatus,  
      CustomerType,  
      CurrencyCode,  
      CourseType,  
      CourseID, CourseName, Format  
order by 1,2,3,4,5,6,7,8,10  
  
  
print 'Non Co_Brand_Courses Report,Copy these results of this and paste it in the tab: NG_NewCust_DS_Data'  
  
select * from DataWarehouse.Marketing.NatGeoNonCoBrand   
where YearOrdered = case when MONTH(GETDATE()) = 1 then YEAR(GETDATE())-1 else YEAR(GETDATE()) end  
and MonthOrdered = case when MONTH(GETDATE()) = 1 then 12 else MONTH(GETDATE())-1 end  

  
-- Step 5:  
-- Nat Geo direct orders  
-- **************************************************  
/*******************************************************************************************************************************************************  
                NatGeo Direct Orders  
  
*******************************************************************************************************************************************************/  

Print 'Delete data from previous run for the current month' 
Delete from DataWarehouse.Marketing.NatGeoDirectOrders   
where YearOrdered = YEAR(GETDATE())  
and MonthOrdered = MONTH(GETDATE())  

  
insert into DataWarehouse.Marketing.NatGeoDirectOrders   
select Year(a.orderdate) YearOrdered,  
      Month(a.orderdate) MonthOrdered,  
      'TTC to NG Direct' MarketingOwner,   
      a.BillingCountryCode,  
      b.CustGroup CustomerType,  
      a.CurrencyCode,  
      coalesce(NGC.CourseType,'C. Non Co_Brand Course') as CourseType,  
      c.CourseID,  
      c.CourseName,  
      c.Format,  
      a.AdCode,  
      d.AdcodeName,  
      d.CatalogCode,  
      d.CatalogName,  
      d.MD_Channel,  
      d.MD_PromotionType,  
      d.MD_CampaignName,  
      sum(c.Quantity) as TotalUnits,  
      sum((c.SalesPrice * c.Quantity)) as TotalSales,  
      MIN(a.OrderDate) MinDateOrdered,  
      Max(a.OrderDate) MaxDateOrdered,  
      @ReportDate ReportDate  
from DataWarehouse.Staging.Orders a   
      left join DataWarehouse.Staging.Customers b on a.CustomerID = b.CustomerID  
      join (select o.*, ii.CourseID, ii.Description as CourseName,   
                        case when ii.MediaTypeID in ('CD','DVD','Transcript') Then ltrim(rtrim(ii.MediaTypeID))  
                              when ii.MediaTypeID like '%DownloadV%' then 'Video Download'  
                              when ii.MediaTypeID like '%DownloadA%' then 'Audio Download' 
							 when ii.MediaTypeID like '%DownloadT%' then 'Digital Transcript'  
                        end  as Format  
                  from datawarehouse.Staging.OrderItems o  
                  left join datawarehouse.staging.invitem ii on o.StockItemID = ii.stockitemid  
                  where o.orderid in (select distinct orderid  
                                          from DAXImports..DAX_OrderExport      
                                          Where SourceCode in (select distinct AdCode
                                          from DataWarehouse.Mapping.vwAdcodesAll
                                          where MD_CampaignName like '%National Geo%'
                                          and AudienceID = 5) 
                                           ))c on a.OrderID = c.OrderID 
      left join DataWarehouse.Mapping.vwAdcodesAll d on a.AdCode = d.AdCode  
      left join Datawarehouse.Mapping.NatgeoCourses NGC on NGC.CourseID = C.CourseID  
where a.OrderID in (select distinct orderid 
                                          from DAXImports..DAX_OrderExport      
                                          Where SourceCode in (select distinct AdCode
                                          from DataWarehouse.Mapping.vwAdcodesAll
                                          where MD_CampaignName like '%National Geo%'
                                          and AudienceID = 5) )        
and a.OrderDate >= '1/1/2015'                                       
group by Year(a.orderdate),  
      Month(a.orderdate),  
      a.BillingCountryCode,  
      b.CustGroup,  
      a.CurrencyCode,  
      --case when c.CourseID in (7901,7912) then 'A. Co_Brand Course'  
      --      when c.CourseID in (7923, 3502) then 'B. Co_Brand New Course'  
      --      else 'C. Non Co_Brand Course'  
      --end,  
      c.CourseID,  
      c.CourseName,  
      --NGC.CourseType,
      coalesce(NGC.CourseType,'C. Non Co_Brand Course'),  
      c.Format,  
      a.AdCode,  
      d.AdcodeName,  
      d.CatalogCode,  
      d.CatalogName,  
      d.MD_Channel,  
      d.MD_PromotionType,  
      d.MD_CampaignName  
  
  
  
print 'NatGeo Direct Orders Monthly, Copy these results of this and paste it in the tab: NatGeoDirectOrders'  
select * from DataWarehouse.Marketing.NatGeoDirectOrders   
where YearOrdered = case when MONTH(GETDATE()) = 1 then YEAR(GETDATE())-1 else YEAR(GETDATE()) end  
and MonthOrdered = case when MONTH(GETDATE()) = 1 then 12 else MONTH(GETDATE())-1 end  
  
  
-- Step 5: ENDS HERE  
-- Nat Geo direct orders  
-- **************************************************  
  
-- added on 5/1/2014  
  
-- every quarter, we need to send Nat Geo new custmomer information to Nat geo..  
-- Step 6  
-- ***************************************************  
-- drop table rfm..NatGeo_NewCustList_20150402    
  
/*****************************************************************************************************************************************  
      Send Nat Geo new custmomer information to Nat geo only customers that have okay to share flag.  
         Sending only files once three months, once at the end of each quarter, i.e. (1,4,7,10)  
*****************************************************************************************************************************************/  
If ( Month(GETDATE()) in (1,4,7,10))   
  
Begin  
  
Declare @StartDate datetime,@StopDate Datetime  
SELECT @StartDate = DATEADD(qq, DATEDIFF(qq, 0, GETDATE()) - 1, 0), @StopDate = DATEADD(dd, -1, DATEADD(qq, DATEDIFF(qq, 0, GETDATE()), 0))  
  
  
truncate table NatGeo_NewCustList_Monthly_NG  
truncate table NatGeo_NewCustList_Monthly_NG_Course  
  
select distinct a.CustomerID, a.OrderID, a.MarketingOwner, a.CustomerType,  
      a.DateOrdered, a.Adcode, a.AdcodeName,  
      c.Prefix, c.FirstName, c.MiddleName, c.LastName, c.Suffix, d.EmailAddress,  
      c.Address1, c.Address2, c.Address3, c.City, c.State, c.postalcode,c.CountryCode,  
      c.FlagMail, c.FlagOkToShare, a.ordersource  
into #NatGeo_NewCustList       
from #NatGeoMktByFormat     a join  
      DataWarehouse.Marketing.CampaignCustomerSignature c on a.CustomerID = c.CustomerID  
      left join (select *  
                  from DataWarehouse.Marketing.CampaignCustomerSignature  
                  where CustomerSince between @StartDate and @StopDate  
                  and FlagOkToShare = 1  
                  and FlagEmailPref = 1)d on a.CustomerID = d.CustomerID  
where a.CustomerType = 'A. New Customer'  
and c.CountryCode in ('US', 'CA')  
and c.CustomerSince between @StartDate and @StopDate  
and c.FlagOkToShare = 1  
  
  
select distinct a.CustomerID, a.OrderID,    
      'NG Sales Channels' MarketingOwner,   
      'A. New Customer' CustomerType,  
      a.DateOrdered, a.Adcode, a.AdcodeName,  
      c.Prefix, c.FirstName, c.MiddleName, c.LastName, c.Suffix, d.EmailAddress,  
      c.Address1, c.Address2, c.Address3, c.City, c.State, c.postalcode,c.CountryCode,  
      c.FlagMail, c.FlagOkToShare, a.OrderSource  
into #OtherNGCust    
from (select a.CustomerID, a.OrderID, a.DateOrdered, OrderSource, SequenceNum, NetOrderAmount,  
      a.AdCode, b.AdcodeName, b.CatalogCode, b.CatalogName,  
      b.ChannelID, b.MD_Channel,  
      b.MD_PromotionTypeID, b.MD_PromotionType,  
      b.MD_CampaignID, b.MD_CampaignName,  
      b.PromotionTypeID, b.PromotionType  
      from DataWarehouse.Marketing.DMPurchaseOrders a join  
     DataWarehouse.Mapping.vwAdcodesAll b on a.AdCode = b.AdCode  
      where b.MD_PromotionTypeID = 132  
      and SequenceNum = 1  
      and a.DateOrdered between @StartDate and @StopDate)a   
        
      join DataWarehouse.Marketing.CampaignCustomerSignature c on a.CustomerID = c.CustomerID   
        
      left join (select *  
                        from DataWarehouse.Marketing.CampaignCustomerSignature  
                        where CustomerSince >= @StartDate  
                        and FlagOkToShare = 1  
                        and FlagEmailPref = 1)d on a.CustomerID = d.CustomerID  
where c.CountryCode in ('US', 'CA')  
and c.FlagOkToShare = 1  
and c.CustomerSince between @StartDate and @StopDate  
  
insert into #NatGeo_NewCustList   
select a.* from #OtherNGCust a left join  
      #NatGeo_NewCustList b on a.CustomerID = b.CustomerID  
where b.CustomerID is null      
  
--insert into DataWarehouse..NatGeo_NewCustList_Monthly_NG  
--select distinct c.Prefix, c.FirstName, c.MiddleName, c.LastName, c.Suffix,  
--      c.EmailAddress,  
--      c.Address1, c.Address2, c.Address3, c.City, c.State, c.postalcode,c.CountryCode,  
--      d.OrderSource, c.Adcode, c.AdcodeName  
--from rfm..NatGeo_NewCustList_20150402 c join  
--      DAXImports..DAX_OrderExport d on c.OrderID = d.OrderID  
--where c.DateOrdered < @StopDate  
        
--insert into DataWarehouse..NatGeo_NewCustList_Monthly_NG_Course  
--select distinct c.CustomerID, c.Prefix, c.FirstName, c.MiddleName, c.LastName, c.Suffix, c.EmailAddress,  
--      c.Address1, c.Address2, c.Address3, c.City, c.State, c.postalcode,c.CountryCode, d.CourseID,   
--      d.CourseName,   
--      case when d.StockItemID like 'PC%' then 'CD'  
--            when d.StockItemID like 'PD%' then 'DVD'  
--            when d.StockItemID like 'DA%' then 'Audio Download'  
--            when d.StockItemID like 'DV%' then 'Video Download'  
--            when d.StockItemID like 'PT%' then 'Transcript'  
--            when d.StockItemID like 'DT%' then 'Transcript Download'  
--            else 'Other'  
--      end as Format,  
--      c.AdCode, c.AdcodeName, c.OrderSource  
--from rfm..NatGeo_NewCustList_20150402 c join  
--      DataWarehouse.Marketing.DMPurchaseOrderItems d on c.OrderID = d.OrderID   
--order by c.CustomerID, d.CourseID     


insert into DataWarehouse..NatGeo_NewCustList_Monthly_NG  
select distinct c.Prefix, c.FirstName, c.MiddleName, c.LastName, c.Suffix,  
      c.EmailAddress,  
      c.Address1, c.Address2, c.Address3, c.City, c.State, c.postalcode,c.CountryCode,  
      d.OrderSource, c.Adcode, c.AdcodeName  
from (select a.CustomerID,a.OrderID,'NG Sales Channels' as MarketingOwner, 
			case when a.SequenceNum = 1 then 'A. New Customer'  
				 when a.SequenceNum > 1 then 'B. Existing Customer'  
				 else 'C. Unknown'  
				 end CustomerType 
			,a.DateOrdered,a.Adcode,AdcodeName
			,Prefix,FirstName,MiddleName,LastName,Suffix,EmailAddress,Address1,Address2
			,Address3,City,State,postalcode,CountryCode,FlagMail,FlagOkToShare,ordersource
		from  (select * from DataWarehouse.Marketing.DMPurchaseOrders 
					where cast( DateOrdered as date) between DATEADD(QUARTER, DATEDIFF(QUARTER, 0, GETDATE())-1, 0) and DATEADD(QUARTER, DATEDIFF(QUARTER, -1, GETDATE())-1, -1) 
					and SequenceNum = 1) a
			left join DAXImports..DAX_SalesStatus f on a.StatusCode = f.SalesStatusCode  
			left join DataWarehouse.Mapping.vwAdcodesAll b on a.AdCode = b.AdCode   
			Left join DataWarehouse.Marketing.CampaignCustomerSignature CCS on ccs.CustomerID= a.CustomerID
		where b.MD_PromotionTypeID = 132  /*132 is NatGeo channel*/  and FlagOkToShare = 1) c join  
      DAXImports..DAX_OrderExport d on c.OrderID = d.OrderID  
where c.DateOrdered < @StopDate  
        
insert into DataWarehouse..NatGeo_NewCustList_Monthly_NG_Course  
select distinct c.CustomerID, c.Prefix, c.FirstName, c.MiddleName, c.LastName, c.Suffix, c.EmailAddress,  
      c.Address1, c.Address2, c.Address3, c.City, c.State, c.postalcode,c.CountryCode, d.CourseID,   
      d.CourseName,   
      case when d.StockItemID like 'PC%' then 'CD'  
            when d.StockItemID like 'PD%' then 'DVD'  
            when d.StockItemID like 'DA%' then 'Audio Download'  
            when d.StockItemID like 'DV%' then 'Video Download'  
            when d.StockItemID like 'PT%' then 'Transcript'  
            when d.StockItemID like 'DT%' then 'Digital Transcript'  
            else 'Other'  
      end as Format,  
      c.AdCode, c.AdcodeName, c.OrderSource  
from (select a.CustomerID,a.OrderID,'NG Sales Channels' as MarketingOwner, 
			case when a.SequenceNum = 1 then 'A. New Customer'  
				 when a.SequenceNum > 1 then 'B. Existing Customer'  
				 else 'C. Unknown'  
				 end CustomerType 
			,a.DateOrdered,a.Adcode,AdcodeName
			,Prefix,FirstName,MiddleName,LastName,Suffix,EmailAddress,Address1,Address2
			,Address3,City,State,postalcode,CountryCode,FlagMail,FlagOkToShare,ordersource
		from  (select * from DataWarehouse.Marketing.DMPurchaseOrders 
					where cast( DateOrdered as date) between DATEADD(QUARTER, DATEDIFF(QUARTER, 0, GETDATE())-1, 0) and DATEADD(QUARTER, DATEDIFF(QUARTER, -1, GETDATE())-1, -1) 
					and SequenceNum = 1) a
			left join DAXImports..DAX_SalesStatus f on a.StatusCode = f.SalesStatusCode  
			left join DataWarehouse.Mapping.vwAdcodesAll b on a.AdCode = b.AdCode   
			Left join DataWarehouse.Marketing.CampaignCustomerSignature CCS on ccs.CustomerID= a.CustomerID
		where b.MD_PromotionTypeID = 132  /*132 is NatGeo channel*/  and FlagOkToShare = 1) c join   
      DataWarehouse.Marketing.DMPurchaseOrderItems d on c.OrderID = d.OrderID   
order by c.CustomerID, d.CourseID   


/* Insering into History tables*/  
insert into datawarehouse..NatGeo_NewCustList_Monthly_NG_hist  
select *  from datawarehouse..NatGeo_NewCustList_Monthly_NG  
  
insert into  datawarehouse..NatGeo_NewCustList_Monthly_NG_Course_hist  
select *  from  datawarehouse..NatGeo_NewCustList_Monthly_NG_Course   
  
  
  
declare @sql varchar(200),@date varchar(8)  
set @date = cast(convert(int, convert(varchar(10), GETDATE(), 112)) as varchar(8))  
  
set @sql = 'select * into DataWarehouse.dbo.NatGeo_NewCustList_' + @date + '_NG  from DataWarehouse.dbo.NatGeo_NewCustList_Monthly_NG'  
exec (@sql)  
  
set @sql = 'select * into DataWarehouse.dbo.NatGeo_NewCustList_' + @date + '_NG_Course from DataWarehouse.dbo.NatGeo_NewCustList_Monthly_NG_Course'  
exec (@sql)  
  
  
set @sql = ' exec staging.ExportTableToPipeText DataWarehouse, ''dbo'', ' + 'NatGeo_NewCustList_' + @date + '_NG' + ', ''\\File1\Groups\Marketing\Marketing Strategy and Analytics\NateGeoReporting\ToNatGeo_NewCustFile'' '  
exec (@sql)  
  
set @sql =' exec staging.ExportTableToPipeText DataWarehouse, ''dbo'', ' + 'NatGeo_NewCustList_' + @date + '_NG_Course' +', ''\\File1\Groups\Marketing\Marketing Strategy and Analytics\NateGeoReporting\ToNatGeo_NewCustFile'' '  
exec (@sql)  
  

drop table #NatGeo_NewCustList  
drop table #OtherNGCust  


End  
  
  
drop table #NatGeoMktByFormat  
drop table #NatGeoMktByFormatReturns  
  
END  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  




GO
