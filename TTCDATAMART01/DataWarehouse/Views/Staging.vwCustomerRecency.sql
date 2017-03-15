SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create VIEW [Staging].[vwCustomerRecency]
AS
	with cteOrders(CustomerID, MaxDateOrdered) as
    (
        SELECT 
        	O.CustomerID, 
            MAX(O.DateOrdered)
        FROM Staging.vwOrders o (nolock)
        WHERE 
        	o.NetOrderAmount > 0
            AND StatusCode in (1, 3, 12)
        GROUP BY O.CustomerID
    )
	SELECT 
    	o.CustomerID, 
        DATEDIFF(DD, o.MaxDateOrdered, GETDATE()) DSLPurchase,
        DATEDIFF(Month, o.MaxDateOrdered, GETDATE()) Recency,
    	cs.IntlPurchAmount as IntlAOS,
        cs.IntlOrderSource as IntlOrderSource,
        cs.IntlFormatMediaCat as IntlFormat,
        cs.IntlPromotionTypeID
    FROM cteOrders o
	left join Marketing.DMCustomerStatic cs (nolock) on cs.CustomerID = o.CustomerID
GO
