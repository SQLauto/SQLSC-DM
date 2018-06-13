SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create FUNCTION [Staging].[FN_MC_GetCustomerOrderSource]
(
	@AsOfDate datetime = null
)
returns table
as
	return
    
	select distinct 
    	o.CustomerID, 
        OrderSource
	from Marketing.DMPurchaseOrdersIgnoreReturns o (nolock) 
    where 
		o.DateOrdered < coalesce(@AsOfDate, getdate()) 
GO
