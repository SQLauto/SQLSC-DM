SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Staging].[vwSalesByState]
AS
					
	select year(a.DateOrdered) YearOrdered,				
		month(a.DateOrdered) MonthOrdered,	
		staging.GetMonday(a.dateOrdered) WeekOrdered,
		a.BillingCountryCode,			
		b.BillingState,			
		b.ShipToCountryCode,			
		b.ShipToState,			
		a.CurrencyCode,			
		count(a.OrderID) Orders,			
		sum(a.NetOrderAmount) Sales			
	from Marketing.DMPurchaseOrders (nolock) a join				
		DAXImports..DAX_OrderExport (nolock) b on a.OrderID = b.orderid			
	where a.DateOrdered >= DATEADD(yy, DATEDIFF(yy,0,getdate()) -1, 0)
	and a.BillingCountryCode = 'US'				
	group by 	year(a.DateOrdered),			
		month(a.DateOrdered),	
		staging.GetMonday(a.dateOrdered),			
		a.BillingCountryCode,			
		b.BillingState,			
		b.ShipToCountryCode,			
		b.ShipToState,			
		a.CurrencyCode	

GO
