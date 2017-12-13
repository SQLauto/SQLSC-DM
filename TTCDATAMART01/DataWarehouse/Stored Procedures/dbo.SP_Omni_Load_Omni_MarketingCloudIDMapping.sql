SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Proc [dbo].[SP_Omni_Load_Omni_MarketingCloudIDMapping] 
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
  
  
End
GO
