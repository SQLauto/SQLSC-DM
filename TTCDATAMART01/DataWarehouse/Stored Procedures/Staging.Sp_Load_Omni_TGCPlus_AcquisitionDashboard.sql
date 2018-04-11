SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [Staging].[Sp_Load_Omni_TGCPlus_AcquisitionDashboard]  
as  
Begin  
  
--Deletes  
Delete from Archive.Omni_TGCPlus_AcquisitionDashboard  
where Date in (Select distinct cast(Date as date)Date from Staging.Omni_TGCPlus_ssis_AcquisitionDashboard)  
  
--Inserts  
insert into Archive.Omni_TGCPlus_AcquisitionDashboard  
(MarketingCloudVisitorID,AllVisits,Date,UniqueVisitors,pageviews,utm_campaign,TGCPlusRegistration,TGCPlusSubscriptionSignups,TGCPlusAddtoWatchlist,TGCPlusRemovefromWatchlist,TGCPlusSubscriptionCancellation,TGCPlusSubscriptionChangePlans)  
  
select MarketingCloudVisitorID,AllVisits,cast(Date as date)Date,UniqueVisitors,pageviews,utm_campaign,TGCPlusRegistration,TGCPlusSubscriptionSignups,TGCPlusAddtoWatchlist,TGCPlusRemovefromWatchlist,TGCPlusSubscriptionCancellation,TGCPlusSubscriptionChangePlans   
from Staging.Omni_TGCPlus_ssis_AcquisitionDashboard  
  
End


 
GO
