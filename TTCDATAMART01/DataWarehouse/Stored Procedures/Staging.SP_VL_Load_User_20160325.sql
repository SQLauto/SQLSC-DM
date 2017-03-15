SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [Staging].[SP_VL_Load_User_20160325]            
as            
Begin            
            
Declare @adcode int    
select @adcode = MAX(adcode)+ 1000  from DataWarehouse.Mapping.vwAdcodesAll         
  
Declare @specialchars varchar(200)  = '%[~,@,#,$,%,&,*,(,),.,!^?:]%'    
        
             
/*Truncate and Load */            
Truncate table [Archive].[TGCPlus_User]             
            
insert into [Archive].[TGCPlus_User]            
(id,version,active,city,email,first_name,full_name,gender,joined,large_profile_pic,last_login_date,last_name,original_profile_pic,password            
,profile_pic,registration_type,state,verified_email,parental_control_enabled,player_settings_id,site_id,uuid,privacy_settings_id,facebook_id            
,google_id,twitter_id,facebook_access_token,update_date,campaign,TGCPluscampaign,entitled_dt,subscription_plan_id,offer_name,offer_code_used,offer_applied_method            
,payment_handler,subscribed_via_platform,registered_via_platform,DMLastUpdateESTDateTime)            
            
select             
id,Cast(version as BigInt)version,Cast(active as Bit)active,city,email,first_name,full_name,gender,Cast(joined as DateTime) joined            
,large_profile_pic,Cast(last_login_date as DateTime) last_login_date,last_name,original_profile_pic,password,profile_pic            
,registration_type,state,Cast(verified_email as Bit) verified_email,Cast(parental_control_enabled as Bit) parental_control_enabled            
,Cast(player_settings_id as BigInt)player_settings_id,Cast(site_id as BigInt)site_id,uuid,Cast(privacy_settings_id as BigInt)privacy_settings_id            
,facebook_id,google_id,twitter_id,facebook_access_token,Cast(update_date as DateTime) update_date,campaign          
,null as TGCpluscampaign  
,Cast(entitled_dt as DateTime) entitled_dt            
,Cast(subscription_plan_id as BigInt)subscription_plan_id,offer_name,offer_code_used,offer_applied_method,payment_handler,subscribed_via_platform,registered_via_platform            
,GETDATE() as DMLastUpdateESTDateTime             
from [Staging].VL_ssis_User             
  
  
/*Update TGCPLus campaign (Integer)*/  
                  
Update [Archive].[TGCPlus_User]  
set TGCPluscampaign = Case when subscription_plan_id = 27 then 120093 /* Beta Users*/          
         when registered_via_platform = 'Roku' then 120092 /* Roku */          
         when subscribed_via_platform = 'Roku' and registered_via_platform is null and campaign is NULL then 120092 /* Roku */          
         when patindex('%[a-z]%', campaign)> 0 then 120091 /* Default*/          
         when patindex(@specialchars, campaign)> 0 then 120091 /* Default*/  
         When isnumeric(campaign) = 0 then 120091 /* Default*/  
		 when isnull(campaign,'') = '' then 120091 /* Default*/          
         when cast(campaign as int)> @adcode then 120091 /* Default*/         
         else campaign end            
  
  
  
END   
   

GO
