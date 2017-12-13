SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [Staging].[SP_AppsFlyer_Load_AppEvents] 
as      
Begin      

/*Update Previous Counts*/
--exec SP_TGCPlus_UpdatePreviousCounts @TGCPlusTableName =  

-- Deletes
delete A
from Archive.TGCPLus_AppsFlyer_AppEvents A
join staging.AppsFlyer_ssis_AppEvents S
on A.AppsFlyerID =  S.AppsFlyerID
and A.EventTime  = S.EventTime  
and A.EventName  = S.EventName
and A.EventValue = S.EventValue
       
 -- inserts
insert into Archive.TGCPLus_AppsFlyer_AppEvents
(AttributedTouchType, AttributedTouchTime, InstallTime, EventTime, EventName, EventValue, EventRevenue, EventRevenueCurrency, EventRevenueUSD, EventSource, IsReceiptValidated, 
Partner, MediaSource, Channel, Keywords, Campaign, CampaignID, Adset, AdsetID, Ad, AdID, AdType, SiteID, SubSiteID, SubParam1, SubParam2, SubParam3, SubParam4, SubParam5, 
CostModel, CostValue, CostCurrency, Contributor1Partner, Contributor1MediaSource, Contributor1Campaign, Contributor1TouchType, Contributor1TouchTime, Contributor2Partner, 
Contributor2MediaSource, Contributor2Campaign, Contributor2TouchType, Contributor2TouchTime, Contributor3Partner, Contributor3MediaSource, Contributor3Campaign, 
Contributor3TouchType, Contributor3TouchTime, Region, CountryCode, State, City, PostalCode, DMA, IP, WIFI, Operator, Carrier, Language, AppsFlyerID, AdvertisingID, 
IDFA, AndroidID, CustomerUserID, IMEI, IDFV, Platform, DeviceType, OSVersion, AppVersion, SDKVersion, AppID, AppName, BundleID, IsRetargeting, RetargetingConversionType, 
AttributionLookback, ReengagementWindow, IsPrimaryAttribution, UserAgent, HTTPReferrer, OriginalURL, DMLastupdated)

select AttributedTouchType, AttributedTouchTime, InstallTime, EventTime, EventName, EventValue, EventRevenue, EventRevenueCurrency, EventRevenueUSD, EventSource, 
IsReceiptValidated, Partner, MediaSource, Channel, Keywords, Campaign, CampaignID, Adset, AdsetID, Ad, AdID, AdType, SiteID, SubSiteID, SubParam1, SubParam2, 
SubParam3, SubParam4, SubParam5, CostModel, CostValue, CostCurrency, Contributor1Partner, Contributor1MediaSource, Contributor1Campaign, Contributor1TouchType, 
  case when Contributor1TouchTime ='' then null else Cast(Contributor1TouchTime as datetime) end  Contributor1TouchTime,  Contributor2Partner, Contributor2MediaSource, Contributor2Campaign, Contributor2TouchType,
 case when Contributor2TouchTime ='' then null else Cast(Contributor2TouchTime as datetime) end Contributor2TouchTime, Contributor3Partner, 
Contributor3MediaSource, Contributor3Campaign, Contributor3TouchType,  case when Contributor3TouchTime ='' then null else Cast(Contributor3TouchTime as datetime) end  Contributor3TouchTime, 
Region, CountryCode, State, City, PostalCode, DMA, IP, WIFI, 
Operator, Carrier, Language, AppsFlyerID, AdvertisingID, IDFA, AndroidID, CustomerUserID, IMEI, IDFV, Platform, DeviceType, OSVersion, AppVersion, SDKVersion, 
AppID, AppName, BundleID, IsRetargeting, RetargetingConversionType, AttributionLookback, ReengagementWindow, IsPrimaryAttribution, UserAgent, HTTPReferrer, OriginalURL,
getdate() as DMLastupdated
from staging.AppsFlyer_ssis_AppEvents 

/*Update Counts*/
--exec SP_TGCPlus_UpdateCurrentCounts @TGCPlusTableName =  
      

/*Insert only the initial Status*/

insert into marketing.TGCPLus_AppsFlyer_AppEvents
select Rnk.* 
from 
(
select A.*  ,Row_number() over(partition by  A.CustomerUserID order by  A.Eventtime, A.Eventname, A.installTime) as Rank
from Archive.TGCPLus_AppsFlyer_AppEvents A
left join marketing.TGCPLus_AppsFlyer_AppEvents m
on	a.CustomerUserID = m.CustomerUserID
where isnull(a.CustomerUserID,'') <>''
and m.CustomerUserID is null
)Rnk
where Rnk.Rank = 1 

END    
GO
