SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Staging].[vwCC_ResellerAuditMultipleItems]
AS
	    
	select a.OrderID, 
		year(b.DateOrdered) YearOrdered, 
		Month(b.DateOrdered) MonthOrdered, 
		cast(b.DateOrdered as date) DateOrdered, 
		b.DateOrdered DateTime, 
		b.CustomerID, 
		b.BillingCountryCode, 
		b.CurrencyCode,
		b.OrderSource,
		a.CourseID,
		a.CourseName, 
		c.MediaTypeID, 
		a.SalesPrice, 
		a.TotalQuantity, 
		a.TotalSales,
		GETDATE() ReportDate
	from DataWarehouse.Marketing.DMPurchaseOrderItems a join
		DataWarehouse.Marketing.DMPurchaseOrders b on a.OrderID = b.OrderID left join
		DataWarehouse.Staging.InvItem c on a.StockItemID = c.StockItemID
	where b.DateOrdered >= DATEADD(month, -3, getdate())
	and a.TotalQuantity >= 3


GO
