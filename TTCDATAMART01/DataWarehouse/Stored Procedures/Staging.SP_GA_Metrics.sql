SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [Staging].[SP_GA_Metrics]    
as    
Begin    
    
Declare @adcode int
select @adcode = MAX(adcode)  from DataWarehouse.Mapping.vwAdcodesAll 

  
/*Delete and Load */    
Delete from [Archive].[GA_Metrics]
where [DATE] >= (select Min(date) from staging.GA_ssis_Metrics )
 
    
--insert into [Archive].[TGCPlus_User]    
--(id,version,active,city,email,first_name,full_name,gender,joined,large_profile_pic,last_login_date,last_name,original_profile_pic,password    
--,profile_pic,registration_type,state,verified_email,parental_control_enabled,player_settings_id,site_id,uuid,privacy_settings_id,facebook_id    
--,google_id,twitter_id,facebook_access_token,update_date,campaign,TGCPluscampaign,entitled_dt,subscription_plan_id,offer_name,offer_code_used,offer_applied_method    
--,payment_handler,subscribed_via_platform,DMLastUpdateESTDateTime)    

insert into [Archive].[GA_Metrics]
    
select  [Date]
, Campaign
, Case  
   when patindex('%[a-z]%', campaign)> 0 then 120091 /* Default*/  
   when isnull(campaign,'') = '' then 120091 /* Default*/  
   when cast(campaign as int)> @adcode then 120091 /* Default*/ 
   else campaign end as  TGCPluscampaign   
, Sessions
, New_users
, Pageviews
, Goal_1_completions_Finished_Registration
, Goal_2_completions_Signedup_For_Subscription
, GETDATE() as DMLastUpdateESTDateTime     
from staging.GA_ssis_Metrics 

    
END    
GO
