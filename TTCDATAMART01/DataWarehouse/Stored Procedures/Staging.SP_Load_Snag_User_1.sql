SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE Proc [Staging].[SP_Load_Snag_User_1]
as

Begin


/***************** Data cleanup and Load to Final Table. ***************** */

--Create table datawarehouse.archive.TGCPlus_User_1
--(
--id	int	NOT Null,
--version	int  Null,
--active	Bit	  Null,
--city	varchar	(255)  Null,
--email	varchar	(255)  Null,
--first_name	varchar	(255)  Null,
--full_name	varchar	(255)  Null,
--gender	varchar	(255)  Null,
--joined	Datetime Null,
--large_profile_pic	varchar	(255)  Null,
--last_login_date	Datetime	  Null,
--last_name	varchar	(255)  Null,
--original_profile_pic	varchar	(255)  Null,
--password	varchar	(255)  Null,
--profile_pic	varchar	(255)  Null,
--registration_type	varchar	(255)  Null,
--state	varchar	(255)  Null,
--verified_email	Bit	  Null,
--parental_control_enabled Bit	  Null,
--player_settings_id	int	  Null,
--site_id	int	  Null,
--uuid	varchar	(255)  Null,
--privacy_settings_id	int	  Null,
--facebook_id	varchar	(255)  Null,
--google_id	varchar	(255)  Null,
--twitter_id	varchar	(255)  Null,
--facebook_access_token	varchar	(255)  Null,
--update_date Datetime	  Null,
--campaign	varchar	(255)  Null,
--LastupdatedDate datetime not null default(getdate())
--)



/*********************Load into Clean table*********************/

truncate table Datawarehouse.archive.TGCPlus_User_1


insert into Datawarehouse.archive.TGCPlus_User_1
( id,version, active ,city ,email ,first_name,full_name,gender	,joined	,large_profile_pic,last_login_date	,last_name	,original_profile_pic 
 ,password	 ,profile_pic	 ,registration_type	 ,state	 ,verified_email ,parental_control_enabled,player_settings_id ,site_id,uuid
 ,privacy_settings_id ,facebook_id ,google_id	 ,twitter_id,facebook_access_token,update_date ,campaign,entitled_dt,subscription_plan_id,offer_name
 ,offer_code_used,offer_applied_method	)

 select 
 id	,case when version is null then null else cast( version as int) End as version,
 case when active is null then null else cast( active as bit) End as active  ,city ,email ,first_name,full_name,gender	
 ,case when joined is null then null else cast( joined as datetime ) End as joined	,large_profile_pic	
 ,case when last_login_date is null then null else cast( last_login_date as datetime) End as last_login_date	,last_name	,original_profile_pic
 ,password	 ,profile_pic	 ,registration_type	 ,state	 ,verified_email	 ,
  case when parental_control_enabled is null then null else cast( parental_control_enabled as Bit) End as parental_control_enabled
 ,case when player_settings_id is null then null else cast( player_settings_id as int) End as player_settings_id 
 ,case when site_id is null then null else cast( site_id as int) End as site_id	 ,uuid	 
 ,case when privacy_settings_id is null then null else cast( privacy_settings_id as int) End as privacy_settings_id	 
 ,facebook_id	 ,google_id	 ,twitter_id,facebook_access_token	
 ,case when update_date is null then null else cast( update_date as Datetime) End as update_date ,campaign	
 ,case when entitled_dt is null then null else cast( entitled_dt as Datetime) End as entitled_dt 	
 ,case when subscription_plan_id is null then null else cast( subscription_plan_id as BigInt) End as subscription_plan_id 	
 ,case when offer_name is null then null else offer_name  End as offer_name 	
 ,case when offer_code_used is null then null else offer_code_used  End as offer_code_used 	
 ,case when offer_applied_method is null then null else offer_applied_method  End as offer_applied_method 	
from  Datawarehouse.staging.Snag_ssis_User


--update a
--set campaign =  LEFT(campaign, CHARINDEX('|', campaign) - 1)
--from datawarehouse.archive.TGCPlus_User_1 a
--WHERE CHARINDEX('|', campaign) > 0


End 





GO
