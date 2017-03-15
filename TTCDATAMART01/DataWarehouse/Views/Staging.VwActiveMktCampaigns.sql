SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Staging].[VwActiveMktCampaigns]
AS
	select Staging.GetMonday(cast(getdate() as date)) as ForecastWeek,
		StartDate, StopDate,
		MD_Year, MD_Audience,
		ChannelID as MD_ChannelID,
		MD_Channel,
		MD_Country,
		MD_PromotionTypeID,
		MD_PromotionType,
		MD_CampaignID,
		MD_CampaignName,
		AdCode, AdcodeName, 
		CatalogCode, CatalogName
	from DataWarehouse.Mapping.vwAdcodesAll
	where StopDate >= DataWarehouse.Staging.GetSunday(cast(getdate() as date))
	and StartDate < DataWarehouse.Staging.GetSunday(cast(dateadd(week,1,getdate()) as date))


GO
