SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE View [Mapping].[Omni_MarketingCloudID_Customerid]
as

select dax_customer_id as Customerid,web_user_id,MarketingCloudVisitorID 
 from DataWarehouse.Archive.Omni_MarketingCloudIDMapping OMC
 join MagentoImports..Email_Customer_Information ECI
 on ECI.web_user_id = OMC.userID
 where isnull(dax_customer_id,'')<>''

GO
