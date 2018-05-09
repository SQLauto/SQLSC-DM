SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [Staging].[SP_MC_TGC_Customer]  
as
Begin

/*
Add Missing Customers due to Merge or Deduping

*/

--select Distinct Customerid , Getdate() as DateAdded
--into DataWarehouse.Marketing.MC_TGC_Customer
--from DataWarehouse.Marketing.CampaignCustomerSignature

Insert into DataWarehouse.Marketing.MC_TGC_Customer
select distinct W.CustomerID,getdate() 
from DataWarehouse.Marketing.MC_TGC_WebVisits W
left join DataWarehouse.Marketing.MC_TGC_Customer C
on w.CustomerID = c.CustomerID
where C.CustomerID is null 


Insert into DataWarehouse.Marketing.MC_TGC_Customer
select distinct W.CustomerID,getdate() 
from DataWarehouse.Marketing.MC_TGC_MailingContact W
left join DataWarehouse.Marketing.MC_TGC_Customer C
on w.CustomerID = c.CustomerID
where C.CustomerID is null 

Insert into DataWarehouse.Marketing.MC_TGC_Customer
select distinct W.CustomerID,getdate() 
from DataWarehouse.Marketing.MC_TGC_EMailContact W
left join DataWarehouse.Marketing.MC_TGC_Customer C
on w.CustomerID = c.CustomerID
where C.CustomerID is null 
 

Insert into DataWarehouse.Marketing.MC_TGC_Customer
select distinct W.CustomerID,getdate() 
from DataWarehouse.Marketing.MC_TGC_DailyConsumptionHistory W
left join DataWarehouse.Marketing.MC_TGC_Customer C
on w.CustomerID = c.CustomerID
where C.CustomerID is null 
  

End 

GO
