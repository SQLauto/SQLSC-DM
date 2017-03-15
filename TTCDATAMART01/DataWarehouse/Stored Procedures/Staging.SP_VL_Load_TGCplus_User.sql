SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

 
CREATE Proc [Staging].[SP_VL_Load_TGCplus_User]   
as        
Begin 

-- first update the TGCPlusCampaign for ROKU emails..
--added the code in the user table load.
/*update a
set a.TGCPlusCampaign = case when left(campaign,6) in ('130509','130510','130511','130512','130513','130514','130515','130516','130517','130518','130519','130520')
						then left(campaign,6) else TGCPluscampaign
					end
from Archive.TGCPlus_User a
*/

    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'TGCPlus_UserSummary_TEMP')
        DROP TABLE Staging.TGCPlus_UserSummary_TEMP
	      
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
		--,case when d.Email IS null then 0 else 1 end as FlagTGCCust -- was including TTC prospects. Need only customers.
		,case when d.CustomerID IS null then 0 else 1 end as FlagTGCCust
		,f.CustomerSegmentFnl
		,count( a.uuid) CustCount
		,e.entitled_dt as MaxSubscriptionDate
		,GETDATE() as ReportDate
	into Staging.TGCPlus_UserSummary_TEMP	
	from (select *
		from Archive.TGCPlus_User 
		where joined >= '7/1/2015'
		and email not like '%+%'
		and email not like 'plustest%'
		and isnull(subscription_plan_id,30) <> 47)a 
		left join Archive.TGCPlus_SubscriptionPlan b on a.subscription_plan_id = b.id
		left join Mapping.vwAdcodesAll c on a.TGCPluscampaign = convert(varchar,c.AdCode)
		left join Marketing.epc_preference d on a.email = d.Email
		left join Marketing.CampaignCustomerSignature f on d.CustomerID = f.CustomerID
		,(select MAX(entitled_dt) entitled_dt from Archive.TGCPlus_User) e
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
		--,case when d.Email IS null then 0 else 1 end
		,case when d.CustomerID IS null then 0 else 1 end
		,f.CustomerSegmentFnl
		,e.entitled_dt      
	 
     --IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'TGCPlus_UserSummary')
     --   DROP TABLE Marketing.TGCPlus_UserSummary
			
	truncate table Marketing.TGCPlus_UserSummary
	
	insert into Marketing.TGCPlus_UserSummary			        
	  select *
	  from Staging.TGCPlus_UserSummary_TEMP
 
    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'TGCPlus_UserSummary_TEMP')
        DROP TABLE Staging.TGCPlus_UserSummary_TEMP  
    
END 

GO
