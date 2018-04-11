SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE View [Archive].[VW_COLO_TGC_TGCPlusExclusion]
as
select TGCCustomerID,EmailAddress,getdate() as DMlastupdated
 from DataWarehouse.Marketing.TGCPlus_CustomerSignature
where TGCCustomerID is not null --and CustStatusFlag in (0,1)
and isnumeric(TGCCustomerID) = 1
GO
