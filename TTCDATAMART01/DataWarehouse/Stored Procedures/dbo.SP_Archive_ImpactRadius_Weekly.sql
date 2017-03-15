SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 CREATE Proc [dbo].[SP_Archive_ImpactRadius_Weekly]  
 as  
 Begin  
 insert into archive.ImpactRadius_Weekly  
 (CampaignId,ActionTrackerId,OrderId,CustomerId,Category,Sku,Amount,Quantity,EventDate )  
 select CampaignId,ActionTrackerId,OrderId,CustomerId,Category,Sku,Amount,Quantity,EventDate 
 from archive.Vw_ImpactRadius_Weekly  
   
 End
 

GO
