SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create VIEW [Staging].[vwCustomerInitialInfo]
AS
	with cteOrders(CustomerID, MinDateOrdered) as
    (
        SELECT 
        	O.CustomerID, 
            MIN(O.DateOrdered)
        FROM Staging.vwOrders o (nolock)
        WHERE 
        	o.NetOrderAmount > 0
            AND StatusCode in (1, 3, 12)
        GROUP BY O.CustomerID
    )
	SELECT 
    	o.CustomerID, 
        cs.DateOrdered as IntlDateOrdered,
    	cs.NetOrderAmount as IntlAOS,
        cs.OrderSource as IntlOrderSource,
        cs.PromotionType as IntlPromotionTypeID
    FROM cteOrders o
	left join Marketing.DMPurchaseOrders cs (nolock) on cs.CustomerID = o.CustomerID
GO
