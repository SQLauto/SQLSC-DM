SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [Staging].[vwPMCompare]
AS

Select ii.CourseID, mc.CourseName, mc.CourseParts, ii.ItemCategoryID,
	 ii.stockitemid, MediaTypeID, CatalogCode,
	'PM_' + Convert(varchar,CatalogCode) PMType, 
	UnitPrice, isnull(pm.UnitCurrency,'USD') UnitCurrency
from datawarehouse.staging.InvItem ii join 
  	datawarehouse.staging.mktpricingmatrix pm  on ii.stockitemid = pm.userstockitemid
					and pm.catalogcode in (1,71,61,4,5,7,8,13083,21258,6102,7281,64,65,74,75,6263)  join
	DataWarehouse.Staging.MktCourse mc on ii.CourseID = mc.CourseID					
where ii.InvStatusID in ('Active','Disc')
and itemcategoryid in ('course','bundle')
and ii.StockItemID like '[pd][cdva]%'
and ii.StockItemID not like '%-%'




GO
