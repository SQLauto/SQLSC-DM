SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Staging].[vwPastOrdersBinWP]
AS
	SELECT 	
		o.CustomerID, 
		COUNT(OrderID) as OrdersCount,
		CASE 
			WHEN COUNT(OrderID) = 1 THEN '00-01'
			WHEN COUNT(OrderID) BETWEEN 2 AND 3 THEN '02-03'
			WHEN COUNT(OrderID) BETWEEN 4 AND 7 THEN '04-07'
			WHEN COUNT(OrderID) BETWEEN 8 AND 18 THEN '08-18'
			ELSE '19-1000'
		END as PastOrdersBin
	FROM Staging.vwOrders o (nolock)
	join Staging.WPMailCustomers c (nolock) on c.CustomerID = o.CustomerID
	WHERE 
		StatusCode in (0, 1, 2, 3, 12, 13)
		and NetOrderAmount > 0
		and c.packageType IN ('New', 'Returning')        
	GROUP BY o.CustomerID
GO
