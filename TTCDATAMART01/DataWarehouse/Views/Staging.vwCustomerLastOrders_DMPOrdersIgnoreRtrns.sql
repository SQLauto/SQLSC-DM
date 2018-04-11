SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [Staging].[vwCustomerLastOrders_DMPOrdersIgnoreRtrns]

as
	select a.*
	from DataWarehouse.Marketing.DMPurchaseOrdersIgnoreReturns a join
		(select customerid, MAX(DateOrdered) DateMax
		from DataWarehouse.Marketing.DMPurchaseOrdersIgnoreReturns
		group by CustomerID)b on a.CustomerID = b.CustomerID
							and a.DateOrdered = b.DateMax



GO
