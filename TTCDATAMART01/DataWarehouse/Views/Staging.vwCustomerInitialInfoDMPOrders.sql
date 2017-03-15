SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Staging].[vwCustomerInitialInfoDMPOrders]
AS
	select a.CustomerID, a.OrderID, a.NetOrderAmount, a.DateOrdered,
		a.OrderSource, a.BillingCountryCode, a.FlagAudioVideo,
		a.FlagDigitalPhysical,
		case when a.NetOrderAmount between 1 and 50 then '1. $1-50'
			when a.NetOrderAmount > 50 and a.NetOrderAmount <= 100 then '2. $50.1-100'
			when a.NetOrderAmount > 100 and a.NetOrderAmount <= 150 then '3. $100.1-150'
			when a.NetOrderAmount > 150 then '4. 150+'
			else 'None'
		end as IntlAOSBin,
		a.AdCode, b.AdcodeName, b.CatalogCode, b.CatalogName,
		b.PromotionTypeID, b.PromotionType, 
		b.CountryID as MD_CountryID, b.MD_Country,
		b.MD_Audience,
		b.ChannelID MD_ChannelID, b.MD_Channel,
		b.MD_PromotionTypeID, b.MD_PromotionType,
		b.MD_CampaignID, b.MD_CampaignName,
		b.MD_PriceType
	from Marketing.DMPurchaseOrders a join
		Mapping.vwAdcodesAll b on a.AdCode = b.AdCode
	where a.SequenceNum = 1		
	

GO
