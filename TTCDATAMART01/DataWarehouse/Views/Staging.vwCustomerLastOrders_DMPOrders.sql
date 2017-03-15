SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [Staging].[vwCustomerLastOrders_DMPOrders]

as
	select a.*
	from DataWarehouse.Marketing.DMPurchaseOrders a join
		(select customerid, MAX(DateOrdered) DateMax
		from DataWarehouse.Marketing.DMPurchaseOrders
		group by CustomerID)b on a.CustomerID = b.CustomerID
							and a.DateOrdered = b.DateMax


GO
