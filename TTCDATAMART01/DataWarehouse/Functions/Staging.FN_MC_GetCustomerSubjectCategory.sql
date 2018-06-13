SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create FUNCTION [Staging].[FN_MC_GetCustomerSubjectCategory]
(
	@AsOfDate datetime = null
)
returns table
as
	return
    
	select distinct 
    	o.CustomerID, 
        SubjectCategory
	from Marketing.DMPurchaseOrderItems oi (nolock)
    join Marketing.DMPurchaseOrdersIgnoreReturns o (nolock) on o.OrderID = oi.OrderID
    where 
		o.DateOrdered < coalesce(@AsOfDate, getdate()) 
        and FormatMedia <> 'T'
GO
