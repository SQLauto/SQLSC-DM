SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Staging].[vwCC_ResellerAuditMultipleOrders]
AS
	select a.CustomerID, 
		a.OrderID, 
		year(a.DateOrdered) YearOrdered, 
		Month(a.DateOrdered) MonthOrdered, 
		cast(a.DateOrdered as date) DateOrdered, 
		a.DateOrdered DateTime,
		a.BillingCountryCode, 
		a.CurrencyCode,
		a.OrderSource,
		a.NetOrderAmount,
		a.DiscountAmount,
		a.ShippingCharge,
		a.Tax,
		GETDATE() ReportDate
	from DataWarehouse.Marketing.DMPurchaseOrders a join	
		(select CustomerID, cast(DateOrdered as date)  DateOrdered, COUNT(OrderID) TotalOrders
		from DataWarehouse.Marketing.DMPurchaseOrders
		where dateordered >= dateadd(month, -3, getdate())
		group by CustomerID, 	cast(DateOrdered as date)  
		having COUNT(OrderID) > 3)b on a.CustomerID = b.CustomerID
								and cast(a.DateOrdered as date) = b.DateOrdered


GO
