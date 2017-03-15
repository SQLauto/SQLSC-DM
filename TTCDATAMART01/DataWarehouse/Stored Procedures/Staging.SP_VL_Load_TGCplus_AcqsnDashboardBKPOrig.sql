SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

 
CREATE Proc [Staging].[SP_VL_Load_TGCplus_AcqsnDashboardBKPOrig]   
as        
Begin 

    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'TGCPlus_Acqsn_Summary_TEMP1')
        DROP TABLE Staging.TGCPlus_Acqsn_Summary_TEMP1

											
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
		c.UTM_Source,	 
		sum(a.CustCount) DM_Subscribers,
		sum(case when a.SubscriptionType = 'Month' then a.CustCount else 0 end) as DM_MonthlySubs,
		sum(case when a.SubscriptionType = 'Year' then a.CustCount else 0 end) as DM_YearlySubs,
		sum(case when FlagTGCCust = 1 then CustCount else 0 end) as TGCCustCountSUB,
		sum(case when FlagTGCCust = 0 then CustCount else 0 end) as NonTGCCustCountSUB
	into Staging.TGCPlus_Acqsn_Summary_TEMP1
	from DataWarehouse.marketing.TGCPlus_UserSummary a 
		left join DataWarehouse.Mapping.Vw_TGCPlus_UTMCodes c on a.IntlCampaign = c.UTM_Campaign	
	--where cast(a.IntlSubscribedDate as date) = '11/30/2015'
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


    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'TGCPlus_Acqsn_Summary_TEMP2')
        DROP TABLE Staging.TGCPlus_Acqsn_Summary_TEMP2

	select a.* 
		,reg.DM_Registrations
		,reg.TGCCustCountREG
		,reg.NonTGCCustCountREG
		,ga.Sessions as GA_Sessions										
		,ga.New_Users GA_NewUsers									
		,ga.PageViews as GA_PageView									
		,ga.Goal_1_completions_Finished_Registration as GA_Goal1_RegComplete									
		,ga.Goal_2_completions_Signedup_For_Subscription as GA_Goal2_SignupComplete
	into Staging.TGCPlus_Acqsn_Summary_TEMP2		
	from Staging.TGCPlus_Acqsn_Summary_TEMP1 a
		left join (select IntlCampaign,
					RegisteredDate,
					SUM(custCount) DM_Registrations,
					sum(case when FlagTGCCust = 1 then CustCount else 0 end) as TGCCustCountREG,
					sum(case when FlagTGCCust = 0 then CustCount else 0 end) as NonTGCCustCountREG
				from Marketing.TGCPlus_UserSummary
				group by IntlCampaign,
					RegisteredDate) reg on a.IntlCampaign = reg.IntlCampaign
										and a.ActivityDate = reg.RegisteredDate	
		left join DataWarehouse.Staging.GA_ssis_Metrics ga on convert(varchar, a.IntlCampaign) = case when isnull(ga.Campaign, '(no set)') like '%no%set%' then 120091	-- 120091	TGCPlus: Default CampaignCode
																										else ga.Campaign
																									end																										
														and a.ActivityDate = ga.Date	
																	
	
	  
   
     IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'TGCPlus_Acqsn_Summary')
        DROP TABLE Marketing.TGCPlus_Acqsn_Summary
			
	--truncate table Marketing.TGCPlus_Acqsn_Summary
	
	--insert into Marketing.TGCPlus_Acqsn_Summary			        
	  select *
	  into Marketing.TGCPlus_Acqsn_Summary
	  from Staging.TGCPlus_Acqsn_Summary_TEMP2
 
    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'TGCPlus_Acqsn_Summary_TEMP1')
        DROP TABLE Staging.TGCPlus_Acqsn_Summary_TEMP1  
        
    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'TGCPlus_Acqsn_Summary_TEMP2')
        DROP TABLE Staging.TGCPlus_Acqsn_Summary_TEMP2
    
END 

GO
