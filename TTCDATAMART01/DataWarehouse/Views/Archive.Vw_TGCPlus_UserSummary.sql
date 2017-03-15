SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE View [Archive].[Vw_TGCPlus_UserSummary]
as
select 	year(a.joined) RegisteredYear
	,month(a.joined) RegisteredMonth
	,datawarehouse.Staging.GetMonday(a.joined) RegisteredWeek
	,CAST(a.Joined as Date) RegisteredDate
	,year(a.entitled_dt) IntlSubscribedYear
	,month(a.entitled_dt) IntlSubscribedMonth
	,datawarehouse.Staging.GetMonday(a.entitled_dt) IntlSubscribedWeek
	,CAST(a.entitled_dt AS date) IntlSubscribedDate
	,a.campaign as VLCampaign
	,a.TGCPlusCampaign IntlCampaign
	,c.AdcodeName as IntlCampaignName
	,c.CatalogCode as IntlCamapaignOfferCode
	,c.CatalogName as IntlCamapaignOfferName
	,c.MD_Audience IntlMD_Audience
	,c.MD_Year IntlMD_Year
	,c.ChannelID as IntlMD_ChannelID
	,c.MD_Channel  IntlMD_Channel
	,c.MD_PromotionTypeID IntlMD_PromotionTypeID
	,c.MD_PromotionType IntlMD_PromotionType
	,c.MD_CampaignID IntlMD_CampaignID
	,c.MD_CampaignName IntlMD_CampaignName
	,c.StartDate as Intl_Cmpn_StartDate
	,c.StopDate as Intl_Cmpn_StopDate
	,case when isnull(a.subscription_plan_id,0) = 0 then 1 else 0 end as FlagRegisteredOnly
	,case when isnull(a.subscription_plan_id,0) = 0 then 0 else 1 end as FlagSubscribed
	,a.subscription_plan_id
	,b.name as Subscription_Plan
	,b.description as Subscription_Desc
	,b.billing_cycle_period_type SubscriptionType
	,b.recurring_payment_amount ReccrPaymentAmt
	,a.offer_code_used as OfferCodeUsed
	,a.offer_name as OfferName
	,a.offer_applied_method as OfferAppliedMthd
	,b.visible
	,case when d.Emailaddress IS null then 0 else 1 end as FlagTGCCust
	,d.CustomerSegmentFnl
	,count( a.uuid) CustCount
	,e.entitled_dt as MaxSubscriptionDate
	,GETDATE() as ReportDate
from Archive.TGCPlus_User a 
	left join Archive.TGCPlus_SubscriptionPlan b on a.subscription_plan_id = b.id
	left join Mapping.vwAdcodesAll c on a.TGCPluscampaign = convert(varchar,c.AdCode)
	left join Marketing.Vw_EPC_EmailPull d on a.email = d.Emailaddress
	,(select MAX(entitled_dt) entitled_dt from Archive.TGCPlus_User) e
where a.joined >= '7/1/2015'
and email not like '%+%'	
group by 	year(a.joined) 
	,month(a.joined) 
	,datawarehouse.Staging.GetMonday(a.joined)
	,CAST(a.Joined as Date) 
	,year(a.entitled_dt) 
	,month(a.entitled_dt) 
	,datawarehouse.Staging.GetMonday(a.entitled_dt)
	,CAST(a.entitled_dt AS date)
	,a.campaign
	,a.TGCPlusCampaign
	,c.AdcodeName
	,c.CatalogCode
	,c.CatalogName
	,c.MD_Audience
	,c.MD_Year
	,c.ChannelID
	,c.MD_Channel 
	,c.MD_PromotionTypeID 
	,c.MD_PromotionType 
	,c.MD_CampaignID 
	,c.MD_CampaignName
	,c.StartDate
	,c.StopDate
	,case when isnull(a.subscription_plan_id,0) = 0 then 1 else 0 end
	,case when isnull(a.subscription_plan_id,0) = 0 then 0 else 1 end
	,a.subscription_plan_id
	,b.name
	,b.description
	,b.billing_cycle_period_type
	,b.recurring_payment_amount
	,a.offer_code_used
	,a.offer_name
	,a.offer_applied_method
	,b.visible
	,case when d.Emailaddress IS null then 0 else 1 end
	,d.CustomerSegmentFnl
	,e.entitled_dt











GO
GRANT ALTER ON  [Archive].[Vw_TGCPlus_UserSummary] TO [TEACHCO\carrt]
GO
GRANT CONTROL ON  [Archive].[Vw_TGCPlus_UserSummary] TO [TEACHCO\carrt]
GO
GRANT SELECT ON  [Archive].[Vw_TGCPlus_UserSummary] TO [TEACHCO\carrt]
GO
