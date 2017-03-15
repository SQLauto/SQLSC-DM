SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE VIEW [Mapping].[vwAdcodesAll]
AS
    SELECT Distinct
    	MAC.AdCode, 
        MAC.Name AS AdcodeName, 
        MAC.Description AS AdcodeDesc,
	    MAC.CatalogCode, 
        MCC.Name AS CatalogName, 
        MCC.Description AS CatalogDesc,
	    MCC.CampaignID as OldCampaignID, 
        oc.[Name] as OldCampaignName,
    	MCC.StartDate, 
        MCC.StopDate, 
        MCC.CurrencyCode,
        MAC.PiecesMailed, 
        MAC.FixedCost, 
        MAC.VariableCost,
	    MAC.AdID,
        mcc.DaxMktRegion as CountryID,
        c.MD_Country,
        mcc.DaxMktTargetType as AudienceID,
        a.MD_Audience,
        mcc.DaxMktChannel as ChannelID,
        ch.MD_Channel,
        mcc.DaxMktPromotionType as MD_PromotionTypeID,
        pt.MD_PromotionType,
        mcc.DaxMktCampaign as MD_CampaignID,
		MC.MD_Campaign as MD_CampaignName, 
        MC.MD_Campaign_Description AS MD_CampaignDesc,        
        mcc.DaxMktPricingType as PriceTypeID,
        p.MD_PriceType,
        dpt.PromotionTypeID, 
        dpt.PromotionType,
        MCC.DaxMktYear MD_Year,
        mcc.DaxPeriodCodeIsPublic,
        case when mcc.DaxMktChannel = 11 and pt.MD_PromotionType like '%Non%Brand%' then 'Search_NonBrand'
			when mcc.DaxMktChannel = 11 and pt.MD_PromotionType not like '%Non%Brand%' then 'Search_Branded'	
			when mcc.DaxMktChannel = 12 and mcc.DaxMktPromotionType <> 144 then 'Display'
			when mcc.DaxMktChannel = 12 and mcc.DaxMktPromotionType = 144 then 'Display_Retargeting'
			when mcc.DaxMktChannel = 4 and p.MD_PriceType like '%Low Price Leader%' then 'Space_Buffet'
			when mcc.DaxMktChannel = 4 and p.MD_PriceType not like '%Low Price Leader%' then 'Space'
			else ch.MD_Channel
		end as IPR_Channel
    FROM Staging.MktAdcodes MAC WITH (NOLOCK) 
    JOIN Staging.MktCatalogcodes MCC WITH (NOLOCK) ON MAC.CatalogCode = MCC.CatalogCode
    left join Mapping.MktCampaign oc (nolock) on oc.CampaignID = mcc.CampaignID
    left JOIN Mapping.MktDim_Campaign MC WITH (NOLOCK) ON MCC.DaxMktCampaign = MC.MD_CampaignID
    left join Mapping.MktDim_Country c (nolock) on c.MD_CountryID = mcc.DaxMktRegion
    left join Mapping.MktDim_Audience a (nolock) on a.MD_AudienceID = mcc.DaxMktTargetType
    left join Mapping.MktDim_Channel ch (nolock) on ch.MD_ChannelID = mcc.DaxMktChannel
    left join Mapping.MktDim_PromotionType pt (nolock) on pt.MD_PromotionTypeID = mcc.DaxMktPromotionType
    left join Mapping.MktDim_PriceType p (nolock) on p.MD_PriceTypeID = mcc.DaxMktPricingType
    left join Mapping.DMPromotionType dmp (nolock) on dmp.CatalogCode = MCC.CatalogCode
	left join MarketingCubes..DimPromotionType dpt (nolock) on dpt.PromotionTypeID = dmp.DimPromotionID





GO
