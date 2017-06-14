SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [Mapping].[Vw_TGCPlus_UTMCodes]
AS

   select distinct AdCode as UTM_Campaign, 
	AdcodeName as UTM_CampaignName,	
	CatalogCode as UTMOfferCode, 
	CatalogName UTMOfferName, 
	StartDate, 
	StopDate,
	year(StartDate) Campaign_StartYear,
	month(StartDate) Campaign_StartMonth,
	MD_Year,
	MD_Country, 
	AudienceID as MD_AudienceID, MD_Audience, 
	ChannelID as MD_ChannelID, MD_Channel, 
	MD_PromotionTypeID, MD_PromotionType, 
	MD_CampaignID, MD_CampaignName, MD_CampaignDesc, 
	DaxPeriodCodeIsPublic,
	GETDATE() ReportDate,
	REPLACE(MD_Country,' ','') + '_' + replace(MD_Channel,' ','') as UTM_Source,
	datawarehouse.dbo.DedupeString(replace(replace(replace(MD_CampaignName,' ',''),':',''),'-','')) as UTM_Medium,
	'?utm_source=' + REPLACE(MD_Country,' ','') + '_' + replace(MD_Channel,' ','') + '&utm_medium=' + replace(replace(replace(MD_CampaignName,' ',''),':',''),'-','') + '&utm_campaign=' + convert(varchar,AdCode) UTMParameters,
	'https://www.thegreatcoursesplus.com/special-offer?utm_source=' + REPLACE(MD_Country,' ','') + '_' + replace(MD_Channel,' ','') + '&utm_medium=' + replace(replace(replace(MD_CampaignName,' ',''),':',''),'-','') + '&utm_campaign=' + convert(varchar,AdCode) URL
  from DataWarehouse.Mapping.vwAdcodesAll	
  where MD_Audience like 'Subscription%'
	union
	   select distinct AdCode as UTM_Campaign, 
	AdcodeName as UTM_CampaignName,	
	CatalogCode as UTMOfferCode, 
	CatalogName UTMOfferName, 
	StartDate, 
	StopDate,
	year(StartDate) Campaign_StartYear,
	month(StartDate) Campaign_StartMonth,
	MD_Year,
	MD_Country, 
	AudienceID as MD_AudienceID, MD_Audience, 
	ChannelID as MD_ChannelID, MD_Channel, 
	MD_PromotionTypeID, MD_PromotionType, 
	MD_CampaignID, MD_CampaignName, MD_CampaignDesc, 
	DaxPeriodCodeIsPublic,
	GETDATE() ReportDate,
	REPLACE(MD_Country,' ','') + '_' + replace(MD_Channel,' ','') as UTM_Source,
	datawarehouse.dbo.DedupeString(replace(replace(replace(MD_CampaignName,' ',''),':',''),'-','')) as UTM_Medium,
	'?utm_source=' + REPLACE(MD_Country,' ','') + '_' + replace(MD_Channel,' ','') + '&utm_medium=' + replace(replace(replace(MD_CampaignName,' ',''),':',''),'-','') + '&utm_campaign=' + convert(varchar,AdCode) UTMParameters,
	'https://www.thegreatcoursesplus.com/special-offer?utm_source=' + REPLACE(MD_Country,' ','') + '_' + replace(MD_Channel,' ','') + '&utm_medium=' + replace(replace(replace(MD_CampaignName,' ',''),':',''),'-','') + '&utm_campaign=' + convert(varchar,AdCode) URL
  from Mapping.vwAdcodesAll a join
		(select distinct TGCPluscampaign
		from Archive.TGCPlus_User)b on a.AdCode = b.TGCPluscampaign



GO
GRANT ALTER ON  [Mapping].[Vw_TGCPlus_UTMCodes] TO [TEACHCO\carrt]
GO
GRANT CONTROL ON  [Mapping].[Vw_TGCPlus_UTMCodes] TO [TEACHCO\carrt]
GO
GRANT SELECT ON  [Mapping].[Vw_TGCPlus_UTMCodes] TO [TEACHCO\carrt]
GO
