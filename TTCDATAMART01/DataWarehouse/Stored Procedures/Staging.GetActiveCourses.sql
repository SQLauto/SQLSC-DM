SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE PROC [Staging].[GetActiveCourses] 
	@EmailDate datetime = null
AS 

/* Preethi Ramanujam 	3/12/2012
	To get the list of Courses that are active in a mail piece
*/

    set @EmailDate = isnull(@EmailDate, convert(datetime,convert(varchar,getdate(),101)))

	PRINT '@EmailDate = ' + convert(varchar,@EmailDate)
	
	declare @EmailYear int
	set @EmailYear = YEAR(@EmailDate)

	PRINT '@EmailYear = ' + convert(varchar,@EmailYear)

select distinct c.CourseID, a.CatalogCode, b.Name as CatalogName, b.StartDate, b.StopDate
from DataWarehouse.Staging.MktPricingMatrix a join
	(select *
	from DataWarehouse.Staging.MktCatalogCodes
	where CurrencyCode = 'USD' 
	and DaxMktYear = @EmailYear
	and DaxMktTargetType = 1
	and DaxMktRegion = 4
	and DaxMktChannel = 1
	and StartDate <= @EmailDate 
	and StopDate >= @EmailDate
	and DaxMktPromotionType in (1,3,4,6,8,10)
	and Name not like '%dummy%'
	and Name not like '%request%')b on a.CatalogCode = b.CatalogCode left join
	DataWarehouse.Staging.InvItem c on a.UserStockItemID = c.StockItemID
order by 2,1	




GO
