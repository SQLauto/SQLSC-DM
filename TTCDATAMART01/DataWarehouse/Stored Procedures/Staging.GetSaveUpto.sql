SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE PROC [Staging].[GetSaveUpto] @CatalogCode INT = 4
AS

-- Preethi Ramanujam 	3/4/2010  To get save up to amount for a catalog.
DECLARE @FullPriceCatCode INT, @UnitCurrency varchar(5)

select @FullPriceCatCode = case when UnitCurrency = 'GBP' then 71
				when UnitCurrency = 'AUD' then 61
				--when ISNULL(UnitCurrency,'USD') = 'USD' then 1
				else 1
				end,
	@UnitCurrency = UnitCurrency
from datawarehouse.staging.mktpricingmatrix
where catalogcode = @CatalogCode

select @FullPriceCatCode as FullPriceCatCode, 
	@UnitCurrency Currency, @CatalogCode CatalogCode


Select courseid, ii.stockitemid, MediaTypeID, 
	ListPrice = max(case when catalogcode = @FullPriceCatCode then UnitPrice else 0 end),
      CurrentPrice = min(UnitPrice)
into #CurrentPricing
from datawarehouse.staging.InvItem ii join 
  	datawarehouse.staging.mktpricingmatrix pm  on ii.stockitemid = pm.userstockitemid
					and pm.catalogcode in (@FullPriceCatCode,@Catalogcode)
where --forsaleonweb = 1 and forsaletoconsumer = 1
--AND ii.InvStatusID in ('Active','Disc')
--and 
itemcategoryid in ('course','bundle')
and ii.StockItemID like '[pd][cdva]%'
group by courseid, ii.stockitemid, MediaTypeID


select * from #CurrentPricing
order by CourseID, MediaTypeID

select CourseID,  max(convert(int,Listprice - CurrentPrice))SaveUpto
INTO #SaveUptoPricing
from #CurrentPricing
group by courseid
having max(convert(int,Listprice - CurrentPrice))>0
order by 1

select * from #SaveUptoPricing

select max(SaveUpto) AS MaxSaveUpto
from #SaveUptoPricing


GO
