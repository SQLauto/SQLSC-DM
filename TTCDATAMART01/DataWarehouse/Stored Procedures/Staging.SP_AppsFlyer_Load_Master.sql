SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Proc [Staging].[SP_AppsFlyer_Load_Master] 
as

Begin


Truncate table mapping.TGCPLus_AppsFlyer_master

Insert into mapping.TGCPLus_AppsFlyer_master
Select distinct *, getdate() as DMlastUpdated
from staging.Appsflyer_ssis_master 

 
  

 End
GO
