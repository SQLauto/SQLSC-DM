SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


Create FUNCTION [Staging].[FN_MC_GetCustomerFormatAV]
(
	@AsOfDate datetime = null
)
returns table
as
	return
    
	select distinct 
    	o.CustomerID, 
        FormatAV
	from Marketing.DMPurchaseOrderItems oi (nolock)
    join Marketing.DMPurchaseOrdersIgnoreReturns o (nolock) on o.OrderID = oi.OrderID
    where 
		o.DateOrdered < coalesce(@AsOfDate, getdate()) 
        and FormatMedia <> 'T'
GO
