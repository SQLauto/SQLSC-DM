SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

 
create Proc [Staging].[SP_VL_Load_TGCplus_AcqsnDashboardBKPDEL]   
as        
Begin 

    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'TGCPlus_Acqsn_Summary_TEMP1')
        DROP TABLE Staging.TGCPlus_Acqsn_Summary_TEMP1

											
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
	into Staging.TGCPlus_Acqsn_Summary_TEMP1
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


    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'TGCPlus_Acqsn_Summary_TEMP2')
        DROP TABLE Staging.TGCPlus_Acqsn_Summary_TEMP2

	select a.* 
		,isnull(sub.DM_Subscribers,0) as DM_Subscribers
		,isnull(sub.DM_MonthlySubs,0) as DM_MonthlySubs
		,isnull(sub.DM_YearlySubs,0) as DM_YearlySubs
		,isnull(sub.TGCCustCountSUB,0) as TGCCustCountSUB
		,isnull(sub.NonTGCCustCountSUB,0) as NonTGCCustCountSUB
		,isnull(ga.Sessions,0) as GA_Sessions										
		,isnull(ga.New_Users,0) GA_NewUsers												
		,isnull(ga.AllUsers,0) GA_AllUsers							
		,isnull(ga.PageViews,0) as GA_PageView									
		,isnull(ga.Goal_1_completions_Finished_Registration,0) as GA_Goal1_RegComplete									
		,isnull(ga.Goal_2_completions_Signedup_For_Subscription,0) as GA_Goal2_SignupComplete
	into Staging.TGCPlus_Acqsn_Summary_TEMP2		
	from Staging.TGCPlus_Acqsn_Summary_TEMP1 a
		left join (select IntlCampaign,
					IntlSubscribedDate,
					SUM(custCount) DM_Subscribers,
					sum(case when SubscriptionType = 'Month' then CustCount else 0 end) as DM_MonthlySubs,
					sum(case when SubscriptionType = 'Year' then CustCount else 0 end) as DM_YearlySubs,
					sum(case when FlagTGCCust = 1 then CustCount else 0 end) as TGCCustCountSUB,
					sum(case when FlagTGCCust = 0 then CustCount else 0 end) as NonTGCCustCountSUB
				from Marketing.TGCPlus_UserSummary
				where IntlSubscribedDate is not null
				group by IntlCampaign,
					IntlSubscribedDate) sub on a.IntlCampaign = sub.IntlCampaign
										and a.ActivityDate = sub.IntlSubscribedDate
		left join Marketing.TGCPlus_GA_Metrics ga on convert(varchar, a.IntlCampaign) = case when isnull(ga.Campaign, '(no set)') like '%no%set%' then 120091	-- 120091	TGCPlus: Default CampaignCode
																										else ga.Campaign
																									end																										
														and a.ActivityDate = ga.Date	
														
	declare @MaxDate date
	select @MaxDate = max(ActivityDate)
	from Staging.TGCPlus_Acqsn_Summary_TEMP2														
														
    IF EXISTS (SELECT 8 FROM SYSOBJECTS WHERE NAME = 'TGCPLUS_ACQSN_SUMMARY_TEMP3')
        DROP TABLE STAGING.TGCPLUS_ACQSN_SUMMARY_TEMP3							
       
			
	select year(a.Date) as ActivityYear 
		,month(a.Date) as ActivityMonth 
		,staging.getmonday(a.Date) as ActivityWeek
		,cast(a.date as date) as ActivityDate 
		,a.Campaign  as IntlCampaign
		,c.UTM_CampaignName as IntlCampaignName
		,c.UTMOfferCode as IntlCamapaignOfferCode
		,c.UTMOfferName as IntlCamapaignOfferName
		,c.MD_Audience as IntlMD_Audience 
		,c.MD_Year as IntlMD_Year
		,c.MD_ChannelID as IntlMD_ChannelID
		,c.MD_Channel as IntlMD_Channel
		,c.MD_PromotionTypeID as IntlMD_PromotionTypeID
		,c.MD_PromotionType as IntlMD_PromotionType 
		,c.MD_CampaignID as IntlMD_CampaignID
		,c.MD_CampaignName as IntlMD_CampaignName
		,c.StartDate Intl_Cmpn_StartDate
		,c.StopDate Intl_Cmpn_StopDate							
		,c.UTM_CampaignName						
		,c.UTM_Medium
		,c.UTM_Source
		,0 as DM_Registrations
		,0 as TGCCustCountREG
		,0 as NonTGCCustCountREG
		,0 as DM_Subscribers
		,0 as DM_MonthlySubs
		,0 as DM_YearlySubs
		,0 as TGCCustCountSUB
		,0 as NonTGCCustCountSUB	 
		,sum(a.Sessions) as GA_Sessions										
		,sum(a.New_Users) GA_NewUsers										
		,sum(a.AllUsers) GA_AllUsers							
		,sum(a.PageViews) as GA_PageView									
		,sum(a.Goal_1_completions_Finished_Registration) as GA_Goal1_RegComplete									
		,sum(a.Goal_2_completions_Signedup_For_Subscription) as GA_Goal2_SignupComplete
	into Staging.TGCPlus_Acqsn_Summary_TEMP3
	from Marketing.TGCPlus_GA_Metrics a 
		left join Mapping.Vw_TGCPlus_UTMCodes c on a.Campaign = c.UTM_Campaign
	--where cast(a.registeredDate as date) = '11/30/2015'
	--and a.VLcampaign = 119477	
	group by year(a.Date) 
		,month(a.Date) 
		,staging.getmonday(a.Date)
		,cast(a.date as date) 
		,a.Campaign
		,c.UTM_CampaignName
		,c.UTMOfferCode
		,c.UTMOfferName 
		,c.MD_Audience 
		,c.MD_Year
		,c.MD_ChannelID
		,c.MD_Channel
		,c.MD_PromotionTypeID
		,c.MD_PromotionType
		,c.MD_CampaignID
		,c.MD_CampaignName
		,c.StartDate
		,c.StopDate	
		,c.UTM_CampaignName						
		,c.UTM_Medium
		,c.UTM_Source							

	delete a from Staging.TGCPlus_Acqsn_Summary_TEMP3 a  join
		Staging.TGCPlus_Acqsn_Summary_TEMP2 b on a.intlcampaign = b.intlcampaign
										and a.activitydate = b.activitydate

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
	  union
	  select *
			,@MaxDate as MaxActivityDate
			,GETDATE() as ReportDate
	  from Staging.TGCPlus_Acqsn_Summary_TEMP3
 
    --IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'TGCPlus_Acqsn_Summary_TEMP1')
    --    DROP TABLE Staging.TGCPlus_Acqsn_Summary_TEMP1  
        
    --IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'TGCPlus_Acqsn_Summary_TEMP2')
    --    DROP TABLE Staging.TGCPlus_Acqsn_Summary_TEMP2
        
    --IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'TGCPlus_Acqsn_Summary_TEMP3')
    --    DROP TABLE Staging.TGCPlus_Acqsn_Summary_TEMP3 
       
END 

GO
