SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

 
CREATE Proc [Staging].[SP_VL_Load_TGCplus_AcqsnDashboard]   
as        
Begin 

    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'TGCPlus_Acqsn_Summary_TEMPReg')
        DROP TABLE Staging.TGCPlus_Acqsn_Summary_TEMPReg

											
	select a.RegisteredYear as ActivityYear, 
		a.RegisteredMonth as ActivityMonth, 
		a.RegisteredWeek as ActivityWeek, 
		a.RegisteredDate as ActivityDate, 
		a.IntlCampaign, 
		a.IntlCampaignName, 
		a.IntlCamapaignOfferCode, 
		a.IntlCamapaignOfferName, 
		a.IntlMD_Audience, 
		a.IntlMD_Year, 
		a.IntlMD_ChannelID, 
		a.IntlMD_Channel, 
		a.IntlMD_PromotionTypeID, 
		a.IntlMD_PromotionType, 
		a.IntlMD_CampaignID, 
		a.IntlMD_CampaignName, 
		a.Intl_Cmpn_StartDate, 
		a.Intl_Cmpn_StopDate,									
		c.UTM_CampaignName,									
		c.UTM_Medium, 
		c.UTM_Source,	 
		sum(a.CustCount) DM_Registrations,
		sum(case when FlagTGCCust = 1 then CustCount else 0 end) as TGCCustCountREG,
		sum(case when FlagTGCCust = 0 then CustCount else 0 end) as NonTGCCustCountREG
		,convert(int,0) as DM_Subscribers
		,convert(int,0) as DM_MonthlySubs
		,convert(int,0) as DM_YearlySubs
		,convert(int,0) as TGCCustCountSUB
		,convert(int,0) as NonTGCCustCountSUB
		,convert(int,0) as GA_Sessions										
		,convert(int,0) GA_NewUsers												
		,convert(int,0) GA_AllUsers							
		,convert(int,0) as GA_PageView									
		,convert(int,0) as GA_Goal1_RegComplete									
		,convert(int,0) as GA_Goal2_SignupComplete
	into Staging.TGCPlus_Acqsn_Summary_TEMPReg
	from marketing.TGCPlus_UserSummary a 
		left join Mapping.Vw_TGCPlus_UTMCodes c on a.IntlCampaign = c.UTM_Campaign
	--where cast(a.registeredDate as date) = '11/30/2015'
	--and a.VLcampaign = 119477	
	group by a.RegisteredYear, 
		a.RegisteredMonth, 
		a.RegisteredWeek, 
		a.RegisteredDate,
		a.IntlCampaign, 
		a.IntlCampaignName, 
		a.IntlCamapaignOfferCode, 
		a.IntlCamapaignOfferName, 
		a.IntlMD_Audience, 
		a.IntlMD_Year, 
		a.IntlMD_ChannelID, 
		a.IntlMD_Channel, 
		a.IntlMD_PromotionTypeID, 
		a.IntlMD_PromotionType, 
		a.IntlMD_CampaignID, 
		a.IntlMD_CampaignName, 
		a.Intl_Cmpn_StartDate, 
		a.Intl_Cmpn_StopDate,									
		c.UTM_CampaignName,									
		c.UTM_Medium, 
		c.UTM_Source									


  IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'TGCPlus_Acqsn_Summary_TempSub')
        DROP TABLE Staging.TGCPlus_Acqsn_Summary_TempSub

											
	select a.IntlSubscribedYear as ActivityYear, 
		a.IntlSubscribedMonth as ActivityMonth, 
		a.IntlSubscribedWeek as ActivityWeek, 
		a.IntlSubscribedDate as ActivityDate, 
		a.IntlCampaign, 
		a.IntlCampaignName, 
		a.IntlCamapaignOfferCode, 
		a.IntlCamapaignOfferName, 
		a.IntlMD_Audience, 
		a.IntlMD_Year, 
		a.IntlMD_ChannelID, 
		a.IntlMD_Channel, 
		a.IntlMD_PromotionTypeID, 
		a.IntlMD_PromotionType, 
		a.IntlMD_CampaignID, 
		a.IntlMD_CampaignName, 
		a.Intl_Cmpn_StartDate, 
		a.Intl_Cmpn_StopDate,									
		c.UTM_CampaignName,									
		c.UTM_Medium, 
		c.UTM_Source	 
		,convert(int,0) as  DM_Registrations
		,convert(int,0) as TGCCustCountREG
		,convert(int,0) as NonTGCCustCountREG
		,sum(a.CustCount) DM_Subscribers
		,sum(case when SubscriptionType = 'Month' then CustCount else 0 end) as DM_MonthlySubs
		,sum(case when SubscriptionType = 'Year' then CustCount else 0 end) as DM_YearlySubs
		,sum(case when FlagTGCCust = 1 then CustCount else 0 end) as TGCCustCountSUB
		,sum(case when FlagTGCCust = 0 then CustCount else 0 end) as NonTGCCustCountSUB
		,convert(int,0) as GA_Sessions										
		,convert(int,0) GA_NewUsers												
		,convert(int,0) GA_AllUsers							
		,convert(int,0) as GA_PageView									
		,convert(int,0) as GA_Goal1_RegComplete									
		,convert(int,0) as GA_Goal2_SignupComplete
	into Staging.TGCPlus_Acqsn_Summary_TempSub
	from marketing.TGCPlus_UserSummary a 
		left join Mapping.Vw_TGCPlus_UTMCodes c on a.IntlCampaign = c.UTM_Campaign
	where cast(a.IntlSubscribedDate as date) is not null
	--and a.VLcampaign = 119477	
	group by a.IntlSubscribedYear, 
		a.IntlSubscribedMonth, 
		a.IntlSubscribedWeek, 
		a.IntlSubscribedDate,
		a.IntlCampaign, 
		a.IntlCampaignName, 
		a.IntlCamapaignOfferCode, 
		a.IntlCamapaignOfferName, 
		a.IntlMD_Audience, 
		a.IntlMD_Year, 
		a.IntlMD_ChannelID, 
		a.IntlMD_Channel, 
		a.IntlMD_PromotionTypeID, 
		a.IntlMD_PromotionType, 
		a.IntlMD_CampaignID, 
		a.IntlMD_CampaignName, 
		a.Intl_Cmpn_StartDate, 
		a.Intl_Cmpn_StopDate,									
		c.UTM_CampaignName,									
		c.UTM_Medium, 
		c.UTM_Source	


  IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'TGCPlus_Acqsn_Summary_TempGA')
        DROP TABLE Staging.TGCPlus_Acqsn_Summary_TempGA


											
	select year(a.date) as ActivityYear, 
		month(a.date) as ActivityMonth, 
		staging.getmonday(a.date) as ActivityWeek, 
		cast(a.date as date) as ActivityDate, 
		case when isnull(a.Campaign, '(no set)') like '%no%set%' then 120091	-- 120091	TGCPlus: Default CampaignCode
			else a.Campaign
		end	IntlCampaign, 
		c.AdcodeName IntlCampaignName, 
		c.CatalogCode IntlCamapaignOfferCode, 
		c.CatalogName IntlCamapaignOfferName, 
		c.MD_Audience IntlMD_Audience, 
		c.MD_Year IntlMD_Year, 
		c.ChannelID IntlMD_ChannelID, 
		c.MD_Channel IntlMD_Channel, 
		c.MD_PromotionTypeID IntlMD_PromotionTypeID, 
		c.MD_PromotionType IntlMD_PromotionType, 
		c.MD_CampaignID IntlMD_CampaignID, 
		c.MD_CampaignName IntlMD_CampaignName, 
		c.StartDate Intl_Cmpn_StartDate, 
		c.StopDate Intl_Cmpn_StopDate,									
		c.AdcodeName UTM_CampaignName,	
		datawarehouse.dbo.DedupeString(replace(replace(replace(MD_CampaignName,' ',''),':',''),'-','')) as UTM_Medium,
		REPLACE(MD_Country,' ','') + '_' + replace(MD_Channel,' ','') as UTM_Source
		,convert(int,0) as  DM_Registrations
		,convert(int,0) as TGCCustCountREG
		,convert(int,0) as NonTGCCustCountREG
		,convert(int,0) as DM_Subscribers
		,convert(int,0) as DM_MonthlySubs
		,convert(int,0) as DM_YearlySubs
		,convert(int,0) as TGCCustCountSUB
		,convert(int,0) as NonTGCCustCountSUB
		,sum(a.sessions) GA_Sessions
		,sum(a.new_users) GA_NewUsers
		,sum(a.AllUsers) GA_AllUsers							
		,sum(a.PageViews) as GA_PageView									
		,sum(a.Goal_1_completions_Finished_Registration) as GA_Goal1_RegComplete									
		,sum(a.Goal_2_completions_Signedup_For_Subscription) as GA_Goal2_SignupComplete
	into Staging.TGCPlus_Acqsn_Summary_TempGA
	from Marketing.TGCPlus_GA_Metrics a 
		left join Mapping.vwAdcodesAll c on a.Campaign = c.AdCode
	--where cast(a.IntlSubscribedDate as date) = '11/30/2015'
	--and a.VLcampaign = 119477	
	group by year(a.date), 
		month(a.date), 
		staging.getmonday(a.date), 
		cast(a.date as date), 
		case when isnull(a.Campaign, '(no set)') like '%no%set%' then 120091	-- 120091	TGCPlus: Default CampaignCode
			else a.Campaign
		end, 
		c.AdcodeName, 
		c.CatalogCode, 
		c.CatalogName, 
		c.MD_Audience, 
		c.MD_Year, 
		c.ChannelID, 
		c.MD_Channel, 
		c.MD_PromotionTypeID, 
		c.MD_PromotionType, 
		c.MD_CampaignID, 
		c.MD_CampaignName, 
		c.StartDate, 
		c.StopDate,									
		c.AdcodeName,	
		datawarehouse.dbo.DedupeString(replace(replace(replace(MD_CampaignName,' ',''),':',''),'-','')),
		REPLACE(MD_Country,' ','') + '_' + replace(MD_Channel,' ','') 





    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'TGCPlus_Acqsn_Summary_TEMP2')
        DROP TABLE Staging.TGCPlus_Acqsn_Summary_TEMP2

	select fnl.ActivityYear, fnl.ActivityMonth, fnl.ActivityWeek, fnl.ActivityDate, 
		fnl.IntlCampaign, fnl.IntlCampaignName, fnl.IntlCamapaignOfferCode, fnl.IntlCamapaignOfferName, 
		fnl.IntlMD_Audience, fnl.IntlMD_Year, 
		fnl.IntlMD_ChannelID, fnl.IntlMD_Channel, 
		fnl.IntlMD_PromotionTypeID, fnl.IntlMD_PromotionType, 
		fnl.IntlMD_CampaignID, fnl.IntlMD_CampaignName, 
		fnl.Intl_Cmpn_StartDate, fnl.Intl_Cmpn_StopDate, 
		fnl.UTM_CampaignName, fnl.UTM_Medium, fnl.UTM_Source, 
		sum(fnl.DM_Registrations) as DM_Registrations, 
		sum(fnl.TGCCustCountREG) as TGCCustCountREG, 
		sum(fnl.NonTGCCustCountREG) as NonTGCCustCountREG, 
		sum(fnl.DM_Subscribers) as DM_Subscribers, 
		sum(fnl.DM_MonthlySubs) as DM_MonthlySubs , 
		sum(fnl.DM_YearlySubs) as DM_YearlySubs, 
		sum(fnl.TGCCustCountSUB) as TGCCustCountSUB, 
		sum(fnl.NonTGCCustCountSUB) as NonTGCCustCountSUB, 
		sum(fnl.GA_Sessions) as GA_Sessions, 
		sum(fnl.GA_NewUsers) as GA_NewUsers, 
		sum(fnl.GA_AllUsers) as GA_AllUsers, 
		sum(fnl.GA_PageView) as GA_PageView, 
		sum(fnl.GA_Goal1_RegComplete) as GA_Goal1_RegComplete, 
		sum(fnl.GA_Goal2_SignupComplete) as GA_Goal2_SignupComplete
	into Staging.TGCPlus_Acqsn_Summary_TEMP2
	from (select * from [Staging].[TGCPlus_Acqsn_Summary_TempGA]
		union
		select * from [Staging].[TGCPlus_Acqsn_Summary_TEMPReg]
		union
		select * from [Staging].[TGCPlus_Acqsn_Summary_TempSub])fnl
	--where fnl.ActivityDate = '5/9/2016'
	group by fnl.ActivityYear, fnl.ActivityMonth, fnl.ActivityWeek, fnl.ActivityDate, 
		fnl.IntlCampaign, fnl.IntlCampaignName, fnl.IntlCamapaignOfferCode, fnl.IntlCamapaignOfferName, 
		fnl.IntlMD_Audience, fnl.IntlMD_Year, 
		fnl.IntlMD_ChannelID, fnl.IntlMD_Channel, 
		fnl.IntlMD_PromotionTypeID, fnl.IntlMD_PromotionType, 
		fnl.IntlMD_CampaignID, fnl.IntlMD_CampaignName, 
		fnl.Intl_Cmpn_StartDate, fnl.Intl_Cmpn_StopDate, 
		fnl.UTM_CampaignName, fnl.UTM_Medium, fnl.UTM_Source
														
	declare @MaxDate date
	select @MaxDate = max(ActivityDate)
	from Staging.TGCPlus_Acqsn_Summary_TEMP2														
														


--select * from Staging.TGCPlus_Acqsn_Summary_TEMP2
--union
--select * from Staging.TGCPlus_Acqsn_Summary_TEMP3

--select a.* from Staging.TGCPlus_Acqsn_Summary_TEMP3 a left join
--	Staging.TGCPlus_Acqsn_Summary_TEMP2 b on a.intlcampaign = b.intlcampaign
--									and a.activitydate = b.activitydate
--where b.intlcampaign  is null	
--union
--select * from Staging.TGCPlus_Acqsn_Summary_TEMP2								
   
     IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'TGCPlus_Acqsn_Summary')
        DROP TABLE Marketing.TGCPlus_Acqsn_Summary
			
	--truncate table Marketing.TGCPlus_Acqsn_Summary
	
	--insert into Marketing.TGCPlus_Acqsn_Summary		        
	  select *
			,@MaxDate as MaxActivityDate
			,GETDATE() as ReportDate
	  into Marketing.TGCPlus_Acqsn_Summary
	  from Staging.TGCPlus_Acqsn_Summary_TEMP2

 
    --IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'TGCPlus_Acqsn_Summary_TEMPReg')
    --    DROP TABLE Staging.TGCPlus_Acqsn_Summary_TEMPReg  
        
    --IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'TGCPlus_Acqsn_Summary_TEMP2')
    --    DROP TABLE Staging.TGCPlus_Acqsn_Summary_TEMP2
        
    --IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'TGCPlus_Acqsn_Summary_TEMP3')
    --    DROP TABLE Staging.TGCPlus_Acqsn_Summary_TEMP3 
       
END 

GO
