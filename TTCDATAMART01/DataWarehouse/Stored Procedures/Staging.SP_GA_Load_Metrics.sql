SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [Staging].[SP_GA_Load_Metrics]
as
Begin
Declare @adcode int      
select @adcode = MAX(adcode)+ 1000  from DataWarehouse.Mapping.vwAdcodesAll           
    
Declare @specialchars varchar(200)  = '%[~,@,#,$,%,&,*,(,),.,!^?:]%'      
          
 
/*Update TGCPLus campaign (Integer)*/    
Update Staging.GA_ssis_Metrics     
set Campaign = 
		Case when left(campaign,6) in ('130509','130510','130511','130512','130513','130514','130515','130516','130517','130518','130519','130520')
						then left(campaign,6)      -- PR 6/16/2016 to fix the issue with Roku email capture
		 when LEN(campaign)>10 then 120091 /* Default*/     
         when patindex('%[a-z]%', campaign)> 0 then 120091 /* Default*/            
         when patindex(@specialchars, campaign)> 0 then 120091 /* Default*/    
         when isnull(campaign,'') = '' then 120091 /* Default*/            
		 when ISNUMERIC(campaign)=0 then 120091 /* Default*/
         when cast(campaign as int)> @adcode then 120091 /* Default*/           
         else campaign end              

select 
Campaign, DATE,
sum(convert(int,Sessions)) Sessions, 
sum(convert(int,New_users)) New_users, 
sum(convert(int,Pageviews)) Pageviews,
sum(convert(int,Goal_1_completions_Finished_Registration)) Goal_1_completions_Finished_Registration,
sum(convert(int,Goal_2_completions_Signedup_For_Subscription)) Goal_2_completions_Signedup_For_Subscription ,
sum(CAST(REPLACE(RTRIM(LTRIM(users)),CHAR(13),'') AS INT)) AllUsers
into #Metrics 
from Staging.GA_ssis_Metrics 
group by Campaign, date 

Delete from Marketing.TGCPLus_GA_Metrics 
where DATE in (select cast (Date as date) from #Metrics group by cast (Date as date))

insert into Marketing.TGCPLus_GA_Metrics  
select * from #Metrics

Drop table #Metrics

END
GO
