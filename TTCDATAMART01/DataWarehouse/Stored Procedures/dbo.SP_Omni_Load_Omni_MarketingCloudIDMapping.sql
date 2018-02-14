SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [dbo].[SP_Omni_Load_Omni_MarketingCloudIDMapping] 
as   
Begin  
  
 insert into archive.Omni_MarketingCloudIDMapping 
 (MarketingCloudVisitorID,userID,DMLastupdated)  
  
 select  S.MarketingCloudVisitorID,S.userID,getdate()
 From  staging.Omni_ssis_MarketingCloudIDMapping   S
 left join archive.Omni_MarketingCloudIDMapping A
 on A.MarketingCloudVisitorID = S.MarketingCloudVisitorID
 and A.userID = S.userID
 where A.MarketingCloudVisitorID is null
  


Truncate table DataWarehouse.mapping.Customerid_Userid_MarketingCloudID
insert into DataWarehouse.mapping.Customerid_Userid_MarketingCloudID 

select distinct  case when isnull(cust.JSMERGEDROOT,'') <> '' then cust.JSMERGEDROOT                      
	else ECI.dax_customer_id end as CustomerID,web_user_id,MarketingCloudVisitorID , getdate() as DMLastupdated   
	from DataWarehouse.Archive.Omni_MarketingCloudIDMapping OMC     
	join MagentoImports..Email_Customer_Information ECI     
	on ECI.web_user_id = OMC.userID     
	left join DAXImports..CustomerExport Cust    
	on ECI.dax_customer_id = Cust.Customerid     
	where isnull(dax_customer_id,'')<>''  


  
End
GO
