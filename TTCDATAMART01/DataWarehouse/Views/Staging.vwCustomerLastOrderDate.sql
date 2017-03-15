SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Staging].[vwCustomerLastOrderDate]
(
	CustomerID, 
    LastOrderDate
)
as
    select 
    	o.CustomerID, 
        max(o.DateOrdered)
    from Staging.vwOrders o (nolock)
    group by o.CustomerID
GO
