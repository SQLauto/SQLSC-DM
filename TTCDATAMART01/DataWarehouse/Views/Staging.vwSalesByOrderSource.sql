SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Staging].[vwSalesByOrderSource]
AS


	select sum(o.netorderamount) Sales, count(O.OrderID)  TotalOrders, 
		isnull(o.CurrencyCode,'USD') CurrencyCode,
		isnull(o.OrderSource,'P') OrderSource, 
		Year(dateordered) YearOrdered,
		MONTH(dateordered) MonthOrdered,
		GETDATE() ReportDate
	from DataWarehouse.Staging.vwOrders o	
	where dateordered >= dateadd(yy,-4,DATEADD(yy, DATEDIFF(yy,0,getdate()), 0))
	and OrderID not like '%RET%'	
	group by isnull(o.CurrencyCode,'USD'), 
		isnull(o.OrderSource,'P'), 
		Year(dateordered), 
		MONTH(dateordered)



GO
