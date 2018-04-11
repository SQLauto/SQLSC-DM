SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Proc [Staging].[SP_Load_Affiliate_AdcodeMap]   
as  
  
Begin  
  
delete from Archive.Affiliate_AdcodeMap
where adcode in (select adcode from staging.Affiliate_ssis_AdcodeMap )
   
  
Insert into Archive.Affiliate_AdcodeMap  
Select distinct *, getdate() as DMlastUpdated  
from staging.Affiliate_ssis_AdcodeMap   
  
   
    
  
 End
GO
