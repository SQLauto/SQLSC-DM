SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[LoadFBToplineReport]
AS
BEGIN
	set nocount on

	 if object_id('staging.TempFBToplineReport') is not null 
			drop table staging.TempFBToplineReport

	select ReportingStarts, 
			ReportingEnds, 
			a.Campaign, 
			a.AdSet, 
			a.Ad, 
			b.[Source Code] Adcode, 
			Ad.IPR_Channel, Ad.MD_Audience, Ad.MD_CampaignID, 
			Ad.MD_Country, Ad.MD_Year, Ad.MD_Channel, Ad.MD_CampaignName, 
			Ad.MD_PriceType, Ad.MD_PromotionType, Ad.MD_PromotionTypeID, Ad.MD_Channel as MD_ChannelID, 
			Ad.CatalogCode, Ad.CatalogName, Ad.AdcodeName,
			sum(Impressions) Impressions, 
			sum(Reach) Reach, 
			--(sum(Impressions) / sum(Reach)) Frequency, 
			sum(Clicks) Clicks, 
			sum(UniqueClicks) UniqueClicks, 
			sum(Actions) Actions,
			sum(AmountSpent) AmountSpent,
			sum(PurchaseConversionValueFacebookPixel) as Revenue_FB,
			sum(PurchaseConversionValueFacebookPixelby1d_click) as Revenue_FB_1d,
			sum(PurchaseFacebookPixel) as Orders_FB,
			sum(PurchaseFacebookPixelby1d_click) as Orders_FB_1d
	INTO staging.TempFBToplineReport
	from archive.FB_TGC_Raw (nolock) a
		left join archive.fb_tgc_adcodes (nolock) b on a.Ad = b.Ad and a.Campaign = b.Campaign and a.Adset = b.AdSet
		left join Mapping.vwAdcodesAll ad on b.[Source Code] = ad.AdCode
	where b.[Source Code] > 0
	group by 
	ReportingStarts, ReportingEnds, a.Campaign, a.AdSet, a.Ad, b.[Source Code],
	Ad.IPR_Channel, Ad.MD_Audience, Ad.MD_CampaignID, 
	Ad.MD_Country, Ad.MD_Year, Ad.MD_Channel, Ad.MD_CampaignName, 
	Ad.MD_PriceType, Ad.MD_PromotionType, Ad.MD_PromotionTypeID, Ad.MD_Channel, 
	Ad.CatalogCode, Ad.CatalogName, Ad.AdcodeName


    
	 if object_id('staging.FBToplineReport') is not null 
			drop table staging.FBToplineReport
        
	Select
			FB.ReportingStarts, FB.ReportingEnds, 
			Staging.GetMonday(FB.ReportingStarts) WeekReportingStarts,
			month(FB.ReportingStarts) MonthReportingStarts,
			year(FB.ReportingStarts) YearReportingStarts,
			FB.Campaign, FB.Adset, FB.Ad, FB.Adcode, 
			Orders.DateOrdered, FB.IPR_Channel, FB.MD_Audience, FB.MD_CampaignID, 
			FB.MD_Country, FB.MD_Year, FB.MD_Channel, FB.MD_CampaignName, 
			FB.MD_PriceType, FB.MD_PromotionType, FB.MD_PromotionTypeID, FB.MD_ChannelID, 
			FB.CatalogCode, FB.CatalogName, FB.AdcodeName, 
			Orders.WeekOrdered, Orders.MonthOrdered, Orders.YearOrdered, 
			--isnull(sum(FB.Impressions),0) Impressions, 
			--isnull(sum(FB.Frequency),0) Frequency, 
			--isnull(sum(FB.Reach),0) Reach, 
			--isnull(sum(FB.Clicks),0) Clicks, 
			--isnull(sum(FB.UniqueClicks),0) UniqueClicks, 
			--isnull(sum(FB.Actions),0) Actions, 
			--isnull(sum(FB.AmountSpent),0) AmountSpent,
			isnull(FB.Impressions,0) Impressions, 
			--isnull(FB.Frequency,0) Frequency, 
			isnull(FB.Reach,0) Reach, 
			isnull(FB.Clicks,0) Clicks, 
			isnull(FB.UniqueClicks,0) UniqueClicks, 
			isnull(FB.Actions,0) Actions, 
			isnull(FB.AmountSpent,0) AmountSpent,
			isnull(FB.Revenue_FB,0) Revenue_FB,
			isnull(FB.Revenue_FB_1d,0) Revenue_FB_1d,
			isnull(FB.Orders_FB,0) Orders_FB,
			isnull(FB.Orders_FB_1d,0) Order_FB_1d,
			isnull(sum(Orders.TotalSales),0) TotalSales,
			isnull(sum(Orders.TotalOrders),0) TotalOrders,
			isnull(sum(Orders.TotalUnits),0) TotalUnits,
			isnull(sum(case when Orders.FlagFirstOrder = 'FirstOrder' then  Orders.TotalSales else 0 end),0) TotalSalesNew,
			isnull(sum(case when Orders.FlagFirstOrder = 'FirstOrder' then  Orders.TotalOrders else 0 end),0) TotalOrdersNew,
			isnull(sum(case when Orders.FlagFirstOrder = 'FirstOrder' then  Orders.TotalUnits else 0 end),0) TotalUnitsNew,
			isnull(sum(Orders.PhysicalUnits),0) PhysicalUnits,
			isnull(sum(Orders.PhysicalSales),0) PhysicalSales,
			isnull(sum(Orders.DigitalUnits),0) DigitalUnits,
			isnull(sum(Orders.DigitalSales),0) DigitalSales,
			isnull(sum(case when Orders.FlagFirstOrder = 'FirstOrder' then  Orders.DigitalSales else 0 end),0) DigitalSalesNew,
			isnull(sum(case when Orders.FlagFirstOrder = 'FirstOrder' then  Orders.DigitalUnits else 0 end),0) DigitalUnitsNew,
			isnull(sum(Orders.DVDUnits),0) DVDUnits,
			isnull(sum(Orders.DVDSales),0) DVDSales,
			isnull(sum(Orders.CDUnits),0) CDUnits,
			isnull(sum(Orders.CDSales),0) CDSales,
			isnull(sum(Orders.VideoDLUnits),0) VideoDLUnits,
			isnull(sum(Orders.VideoDLSales),0) VideoDLSales,
			isnull(sum(Orders.AudioDLUnits),0) AudioDLUnits,
			isnull(sum(Orders.AudioDLSales),0) AudioDLSales,
			isnull(sum(Orders.TranscriptUnits),0) TranscriptUnits,
			isnull(sum(Orders.TranscriptSales),0) TranscriptSales,
			isnull(sum(Orders.DigitalTranscriptUnits),0) DigitalTranscriptUnits,
			isnull(sum(Orders.DigitalTranscriptSales),0) DigitalTranscriptSales,
			isnull(sum(Orders.ShippingCharge),0) ShippingCharge,
			isnull(sum(Orders.TotalTaxes),0) TotalTaxes,
			isnull(sum(Orders.DiscountAmount),0) DiscountAmount,
			isnull(sum(Orders.TotalMerchandizeSales),0) TotalMerchandizeSales,
			isnull(sum(Orders.TotalMerchandizeUnits),0) TotalMerchandizeUnits,
			isnull(sum(Orders.TotalMerchandizeParts),0) TotalMerchandizeParts,
			isnull(sum(Orders.Adj_CDSales),0) as Adj_CDSales,
			isnull(sum(Orders.Adj_DVDSales),0) as Adj_DVDSales,
			isnull(sum(Orders.Adj_AudioTapeSales),0) as Adj_AudioTapeSales,
			isnull(sum(Orders.Adj_VHSSales),0) as Adj_VHSSales,
			isnull(sum(Orders.Adj_AudioDLSales),0) as Adj_AudioDLSales,
			isnull(sum(Orders.Adj_VideoDLSales),0) as Adj_VideoDLSales,
			isnull(sum(Orders.Adj_TranscriptSales),0) as Adj_TranscriptSales,
			isnull(sum(Orders.Adj_DigitalTranscriptSales),0) as Adj_DigitalTranscriptSales,
			isnull(sum(Orders.Adj_DigitalSales),0) as Adj_DigitalSales,
			isnull(sum(Orders.Adj_PhysicalSales),0) as Adj_PhysicalSales,
			isnull(sum(Orders.Adj_TotalMerchandizeSales),0) as Adj_TotalMerchandizeSales,
			getdate() as ReportDate
	into staging.FBToplineReport
	from staging.TempFBToplineReport FB
	left join 
		Marketing.DailyToplineReportWithAdcodeIgnoreRtrns (nolock) Orders on FB.Adcode = Orders.AdCode and FB.ReportingEnds = Orders.DateOrdered
	group by
		FB.ReportingStarts, FB.ReportingEnds, 
		Staging.GetMonday(FB.ReportingStarts),
		month(FB.ReportingStarts),
		year(FB.ReportingStarts),
		FB.Campaign, FB.Adset, FB.Ad, FB.Adcode, 
		Orders.DateOrdered, FB.IPR_Channel, FB.MD_Audience, FB.MD_CampaignID, 
		FB.MD_Country, FB.MD_Year, FB.MD_Channel, FB.MD_CampaignName, 
		FB.MD_PriceType, FB.MD_PromotionType, FB.MD_PromotionTypeID, FB.MD_ChannelID, 
		FB.CatalogCode, FB.CatalogName, FB.AdcodeName, Orders.WeekOrdered, Orders.MonthOrdered, Orders.YearOrdered, 
		isnull(FB.Impressions,0), 
		--isnull(FB.Frequency,0), 
		isnull(FB.Reach,0), 
		isnull(FB.Clicks,0), 
		isnull(FB.UniqueClicks,0), 
		isnull(FB.Actions,0), 
		isnull(FB.AmountSpent,0),
		isnull(FB.Revenue_FB,0),
		isnull(FB.Revenue_FB_1d,0),
		isnull(FB.Orders_FB,0),
		isnull(FB.Orders_FB_1d,0)


	if object_id('Marketing.FBToplineReport') is not null drop table Marketing.FBToplineReport
    alter schema Marketing transfer Staging.FBToplineReport
		
END
GO
