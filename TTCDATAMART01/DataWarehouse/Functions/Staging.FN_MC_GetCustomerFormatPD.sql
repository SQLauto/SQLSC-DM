SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [Staging].[FN_MC_GetCustomerFormatPD]
(
	@AsOfDate datetime = null
)
returns table
as
	return
    
	select distinct 
    	o.CustomerID, 
        case when FormatMedia in ('DL','DV') then 'Digital' else 'Physical' end as FormatPD
	from Marketing.DMPurchaseOrderItems oi (nolock)
    join Marketing.DMPurchaseOrdersIgnoreReturns o (nolock) on o.OrderID = oi.OrderID
    where 
		o.DateOrdered < coalesce(@AsOfDate, getdate()) 
        and FormatMedia <> 'T'
GO
