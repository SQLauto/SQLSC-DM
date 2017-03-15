SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[QCWebDefaultVSOthers] 
AS
	-- Preethi Ramanujam    6/5/2012 - Get monthly top line report
begin

    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'WebDefaultVSOthers')
        DROP TABLE Marketing.WebDefaultVSOthers

select SUM(TotalSales) Sales, 
	COUNT(distinct po.OrderID) Orders, 
	Day (po.DateOrdered) Day, 
	MONTH(po.DateOrdered) Month,									
    year(po.DateOrdered) Year, 
    po.FlagEmailOrder, 									
	FlagDefaultWeb = case when po.catalogcode in (4289,5265,999,11519,16318) then po.CatalogCode else 0 end,									
	FlagDefaultWebName = case when po.CatalogCode in (4289,5265,999,11519,16318) then mc.Name else 'Other' end,
	FlagVDL = case when poi.formatmedia in ('DV') then 1 else 0 end,
	GETDATE() ReportDate
into Marketing.WebDefaultVSOthers
from DataWarehouse.Marketing.DMPurchaseOrders po join									
     DataWarehouse.marketing.DMPurchaseOrderItems poi 									
						on po.OrderID = poi.orderid	left join
    DataWarehouse.Staging.MktCatalogCodes mc on po.CatalogCode = mc.CatalogCode							
where po.DateOrdered >='1/1/2009' 
and po.BillingCountryCode in ('US', 'USA')
and OrderSource like 'w' 
and SequenceNum >1									
group by Day (po.DateOrdered), MONTH(po.DateOrdered),									
    year(po.DateOrdered), FlagEmailOrder,									
	case when po.catalogcode in (4289,5265,999,11519,16318) then po.CatalogCode else 0 end,									
	case when po.CatalogCode in (4289,5265,999,11519,16318) then mc.Name else 'Other' end,									
	case when poi.formatmedia in ('DV') then 1 else 0 end	

end
GO
