SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [Staging].[GetCustomerFormatAD]
(
	@AsOfDate datetime = null
)
returns table
as
	return
    
	select distinct 
    	o.CustomerID, 
        FormatAD
	from Marketing.DMPurchaseOrderItems oi (nolock)
    join Marketing.DMPurchaseOrders o (nolock) on o.OrderID = oi.OrderID
    where 
		o.DateOrdered < coalesce(@AsOfDate, getdate()) 
        and FormatMedia <> 'T'
GO
