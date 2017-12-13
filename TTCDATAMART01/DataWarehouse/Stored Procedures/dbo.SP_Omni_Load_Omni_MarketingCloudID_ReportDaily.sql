SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Proc [dbo].[SP_Omni_Load_Omni_MarketingCloudID_ReportDaily]
as
Begin


 select R.*,
 isnull(br.AllVisits,0) as  bannerrotation, 
 isnull(hph.AllVisits,0) as HomepageHero, 
 isnull(ppv.AllVisits,0) as ProfessorPageViewVisits,
 isnull(ppv.PageViews,0) as ProfessorPageViewPageViews,
 isnull(rr.AllVisits,0) as RightRail,
 isnull(tvv.MediaViews,0) as TrailerVideoViews,
 isnull(ui.AllVisits,0) as UpsellInteractions
 Into #Omni_MarketingCloudID_ReportDaily
 from staging.Omni_ssis_MarketingCloudID_Report R
left join staging.Omni_ssis_MarketingCloudID_bannerrotation br  
on r.MarketingCloudVisitorID=br.MarketingCloudVisitorID and r.Date = br.Date and r.MobileDeviceType = br.MobileDeviceType
left join staging.Omni_ssis_MarketingCloudID_HomepageHero hph	
on  r.MarketingCloudVisitorID=hph.MarketingCloudVisitorID and r.Date = hph.Date and r.MobileDeviceType = hph.MobileDeviceType
left join staging.Omni_ssis_MarketingCloudID_ProfessorPageView ppv	
on r.MarketingCloudVisitorID=ppv.MarketingCloudVisitorID and r.Date = ppv.Date and r.MobileDeviceType = ppv.MobileDeviceType
left join staging.Omni_ssis_MarketingCloudID_RightRail rr  
on r.MarketingCloudVisitorID=rr.MarketingCloudVisitorID and r.Date = rr.Date and r.MobileDeviceType = rr.MobileDeviceType
left join staging.Omni_ssis_MarketingCloudID_TrailerVideoViews tvv  
on r.MarketingCloudVisitorID=tvv.MarketingCloudVisitorID and r.Date = tvv.Date and r.MobileDeviceType = tvv.MobileDeviceType
left join staging.Omni_ssis_MarketingCloudID_UpsellInteractions ui  
on r.MarketingCloudVisitorID= ui.MarketingCloudVisitorID and r.Date = ui.Date and r.MobileDeviceType = ui.MobileDeviceType


delete from [Archive].[Omni_MarketingCloudID_ReportDaily]
where date in (select distinct date from #Omni_MarketingCloudID_ReportDaily)


insert into [Archive].[Omni_MarketingCloudID_ReportDaily]
 (MarketingCloudVisitorID,AllVisits,Date,MobileDeviceType,Carts,CartViews,Checkouts,CartAdditions,InternalSearchPerformed,CartRemovals,InternalSearchNullResult,
AccountLogin,PrioritCodeSubmits,FacetClicks,AddtoWishlist,CheckoutLogins,BillingContinues,ShippingAddrContinues,ShippingMethodContinues,PlaceOrderSubmits,egiftaddtocart,
egiftopencart,egiftcheckout,egiftpurchase,egiftredeemview,egiftredeem,SocialShareSubmits,PDPGalleryClick,PDPWhatWIllYouLearn,PDPWhatsIncludedClick,OnSaleProductView,
UpsellRightArrowClick,UpsellLeftArrowClicke,UniqueVisitors,PageViews,bannerrotation,HomepageHero,ProfessorPageViewVisits,ProfessorPageViewPageViews,RightRail,TrailerVideoViews,UpsellInteractions)

select 
MarketingCloudVisitorID,AllVisits,Date,MobileDeviceType,Carts,CartViews,Checkouts,CartAdditions,InternalSearchPerformed,CartRemovals,InternalSearchNullResult,
AccountLogin,PrioritCodeSubmits,FacetClicks,AddtoWishlist,CheckoutLogins,BillingContinues,ShippingAddrContinues,ShippingMethodContinues,PlaceOrderSubmits,egiftaddtocart,
egiftopencart,egiftcheckout,egiftpurchase,egiftredeemview,egiftredeem,SocialShareSubmits,PDPGalleryClick,PDPWhatWIllYouLearn,PDPWhatsIncludedClick,OnSaleProductView,
UpsellRightArrowClick,UpsellLeftArrowClicke,UniqueVisitors,PageViews,bannerrotation,HomepageHero,ProfessorPageViewVisits,ProfessorPageViewPageViews,RightRail,TrailerVideoViews,UpsellInteractions
from #Omni_MarketingCloudID_ReportDaily


End
GO
