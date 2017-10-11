SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE View [Archive].[Vw_TGCPlus_CustomerSignature]
as
Select A.*,B.DSMonthCancelled_New,DS,BillingRank,LTDAmount as DSLTDAmount,LTDNetAmount as DSLTDNetAmount
from
(select * from marketing.TGCPlus_CustomerSignature (nolock)) A
left join
(
SELECT Distinct
CustomerID, 
case    when Cancelled + Suspended + DeferredSuspension = 0 and RefundedAmount = 0 then NULL 
        when pre_tax_amount = 0 and MaxDS = 0 then MaxDS
              when LTDNetAmount = 0 then 0
        when RefundedAmount*1./NullIf(pre_tax_amount,0) > .75 then MaxDS - DSSplits 
        else MaxDS 
        end as DSMonthCancelled_New
		,DS,BillingRank,LTDAmount,LTDNetAmount
  FROM [DataWarehouse].[Archive].[Vw_TGCPlus_DS_Working] (nolock) 
  where CurrentDS = 1 and DS is not null
) B on A.CustomerID = B.CustomerID 


GO
