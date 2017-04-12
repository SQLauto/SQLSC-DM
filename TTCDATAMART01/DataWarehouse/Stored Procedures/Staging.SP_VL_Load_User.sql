SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [Staging].[SP_VL_Load_User]            
AS            
BEGIN            
            


/*Update Previous Counts*/
exec SP_TGCPlus_UpdatePreviousCounts @TGCPlusTableName = 'TGCPlus_User'


/* Create prev day comparision table */
   if object_id ('staging.TGCPlus_PrevDay_User') is not null
   drop table staging.TGCPlus_PrevDay_User

   select * into [staging].[TGCPlus_PrevDay_User] 
   from [Archive].[TGCPlus_User]


Declare @adcode int    
select @adcode = MAX(adcode)+ 1000  from DataWarehouse.Mapping.vwAdcodesAll         
  
Declare @specialchars varchar(200)  = '%[~,@,#,$,%,&,*,(,),.,!^?:]%'    
        

/* Create #PAS table*/
/*
select pa_user_id,min(pas_created_at)as pas_created_at 
Into #PAS
from DataWarehouse.Archive.TGCPlus_PaymentAuthorizationStatus 
where pas_state = 'Completed' 
group by pa_user_id
*/
             
/*Truncate and Load */            
--Truncate table [Archive].[TGCPlus_User]             
Delete A from [Archive].[TGCPlus_User] A
Join [Staging].VL_ssis_User S
on A.uuid=s.uuid

           
insert into [Archive].[TGCPlus_User]            
(id,version,active,city,email,first_name,full_name,gender,joined,large_profile_pic,last_login_date,last_name,original_profile_pic,password            
,profile_pic,registration_type,state,verified_email,parental_control_enabled,player_settings_id,site_id,uuid,privacy_settings_id,facebook_id            
,google_id,twitter_id,facebook_access_token,update_date,campaign,TGCPluscampaign,VL_entitled_dt,subscription_plan_id,offer_name,offer_code_used,offer_applied_method            
,payment_handler,subscribed_via_platform,registered_via_platform,DMLastUpdateESTDateTime)            
            
select    distinct          
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
  

/* Update entitled date from #PAS */
/*
update U
set U.entitled_dt =  coalesce(Pas.pas_created_at,U.VL_entitled_dt)
from [Archive].[TGCPlus_User]   U 
left join #PAS pas on pas.pa_user_id = U.id
*/
/* Fix for Missing ROKU Data Preethi 20160525*/
select distinct a.*
into #tempPas
from DataWarehouse.Archive.TGCPlus_PaymentAuthorizationStatus a join
      (select pa_user_id, pas_state, min(pas_id) pas_id
      from DataWarehouse.Archive.TGCPlus_PaymentAuthorizationStatus
      where pas_state = 'Completed'
      --and pas_created_at >= '9/28/2015'
      group by pa_user_id, pas_state)b on a.pa_user_id = b.pa_user_id
                                    and a.pas_state = b.pas_state
                                    and a.pas_id = b.pas_id

select pa_user_id
from #tempPas
group by pa_user_id
having count(*) > 1

select a.email, a.entitled_dt, a.vl_entitled_dt, 
      a.subscribed_via_platform, a.subscription_plan_id,
      b.pas_created_at, b.pas_subscribed_via_platform,
      b.pas_plan_id, b.pas_payment_handler
from DataWarehouse.Archive.TGCPlus_User a join
      #tempPas b on a.id = b.pa_user_id
--where a.subscription_plan_id is null


update a
set a.entitled_dt = b.pas_created_at,
a.subscription_plan_id = b.pas_plan_id,
      a.subscribed_via_platform = b.pas_subscribed_via_platform,
      a.payment_handler = b.pas_payment_handler
from DataWarehouse.Archive.TGCPlus_User a join
      #tempPas b on a.id = b.pa_user_id
	  where a.entitled_dt is null /* Added after missing entitled dates*/
--where a.subscription_plan_id is null

/*Update any entitled dates that are missed due to missing pas table data 3/21/2017*/
update [Archive].[TGCPlus_User]   
set entitled_dt =  VL_entitled_dt
WHERE entitled_dt IS NULL AND VL_entitled_dt IS NOT null
 
/*Update TGCPLus campaign (Integer)*/  
                  
Update [Archive].[TGCPlus_User]  
set TGCPluscampaign = Case when subscription_plan_id = 27 then 120093 /* Beta Users*/          
         when registered_via_platform = 'Roku' and campaign is null then 120092 /* Roku */          
         when subscribed_via_platform = 'Roku' and registered_via_platform is null and campaign is NULL then 120092 /* Roku */          
         when patindex('%[a-z]%', campaign)> 0 then 120091 /* Default*/          
         when patindex(@specialchars, campaign)> 0 then 120091 /* Default*/  
         When isnumeric(campaign) = 0 then 120091 /* Default*/  
		 when isnull(campaign,'') = '' then 120091 /* Default*/          
         when cast(campaign as int)> @adcode then 120091 /* Default*/         
         else campaign end            

/*Fix for Roku Email issue free roku device*/

update a 
set a.TGCPlusCampaign = case when left(campaign,6) in ('130509','130510','130511','130512','130513','130514','130515','130516','130517','130518','130519','130520')  
                             then left(campaign,6) 
							 else TGCPluscampaign 
                             end 
from Archive.TGCPlus_User a
 

/*Update Counts*/
exec SP_TGCPlus_UpdateCurrentCounts @TGCPlusTableName = 'TGCPlus_User'
 

 /* Audit trail */

	INSERT INTO Archive.TGCPlus_User_Audit_trail
	SELECT Prev.uuid,
		Prev.email AS Prev_Email, U.Email ,CASE WHEN Prev.email <> U.Email THEN 1 ELSE 0 END AS Email_Mismatch, 
		Prev.campaign AS Prev_campaign, U.campaign,CASE WHEN Prev.campaign <> U.campaign THEN 1 ELSE 0 END AS campaign_Mismatch,
		Prev.TGCPluscampaign AS Prev_TGCPluscampaign, U.TGCPluscampaign,CASE WHEN Prev.TGCPluscampaign <> U.TGCPluscampaign THEN 1 ELSE 0 END AS TGCPluscampaign_Mismatch,
		Prev.entitled_dt AS Prev_entitled_dt, U.entitled_dt,CASE WHEN Prev.entitled_dt <> U.entitled_dt THEN 1 ELSE 0 END AS entitled_dtMismatch,
		Prev.joined AS Prev_joined, U.joined,CASE WHEN Prev.joined <> U.joined THEN 1 ELSE 0 END AS joined_Mismatch,
		Prev.payment_handler AS Prev_payment_handler, U.payment_handler,CASE WHEN Prev.payment_handler <> U.payment_handler THEN 1 ELSE 0 END AS payment_handler_Mismatch,
		Prev.registered_via_platform AS Prev_registered_via_platform, U.registered_via_platform,CASE WHEN Prev.registered_via_platform <> U.registered_via_platform THEN 1 ELSE 0 END AS registered_via_platform_Mismatch,
		Prev.subscribed_via_platform AS Prev_subscribed_via_platform, U.subscribed_via_platform,CASE WHEN Prev.subscribed_via_platform <> U.subscribed_via_platform THEN 1 ELSE 0 END AS subscribed_via_platform_Mismatch,
		Prev.registration_type AS Prev_registration_type, U.registration_type,CASE WHEN Prev.registration_type <> U.registration_type THEN 1 ELSE 0 END AS registration_type_Mismatch
		,GETDATE() AS DMlastupdated
	FROM [staging].[TGCPlus_PrevDay_User] Prev
	JOIN [Archive].[TGCPlus_User]  U
	ON U.uuid = Prev.uuid
	WHERE U.id <> Prev.id
	OR Prev.email <> U.Email
	OR Prev.campaign <> U.campaign
	OR Prev.TGCPluscampaign <> U.TGCPluscampaign
	OR Prev.entitled_dt <> U. entitled_dt
	OR Prev.joined <> U.Joined
	OR Prev.payment_handler <> U.payment_handler
	OR Prev.registered_via_platform <> U.registered_via_platform
	OR Prev.subscribed_via_platform <> U.subscribed_via_platform
	OR Prev.registration_type <> U.registration_type
 
 
   IF EXISTS (SELECT TOP 1 * FROM DataWarehouse.Archive.TGCPlus_user_Audit_trail WHERE CAST(DMlastupdated AS DATE) = CAST(GETDATE() AS DATE))

   BEGIN
   
		DECLARE @p_body AS NVARCHAR(MAX), @p_subject AS NVARCHAR(MAX)
		DECLARE @p_recipients AS NVARCHAR(MAX), @p_profile_name AS NVARCHAR(MAX)
		SET @p_profile_name = N'DL datamart alerts'
		SET @p_recipients = N'~dldatamartalerts@TEACHCO.com'
		SET @p_subject = N'Data Added today to TGCPlus User Audit Trail'
		SET @p_body = 'Check the below table <b> select * from DataWarehouse.Archive.TGCPlus_user_Audit_trail where cast(DMlastupdated as date) = cast(getdate() as date)</b>.'
		EXEC msdb.dbo.sp_send_dbmail
		  @profile_name = @p_profile_name,
		  @recipients = @p_recipients,
		  @body = @p_body,
		  @body_format = 'HTML',
		  @subject = @p_subject
	END

END   
   





GO
