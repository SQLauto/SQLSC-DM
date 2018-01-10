SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROCEDURE [Staging].[GetMonthlyToplineReportIgnoreReturnsIgnoreReturns] 
AS
	-- Preethi Ramanujam    2/6/2012 - Get monthly top line report
	-- PR -- 2/7/2014  -- Include Marketing dimensions as per Amit's request
	-- PR -- 8/20/2014 -- Update demographics from WebDecisions table
	-- PR -- 9/12/2014 -- Remove FlagAdcodeType and CustType. They are inlcuded in other reports.
	-- PR -- 6/3/2015 -- Added IPR_Channel to the table.
begin

    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'MonthlyToplineReportIgnoreReturns')
        DROP TABLE Marketing.MonthlyToplineReportIgnoreReturns



    select YEAR(a.DateOrdered) YearOrdered,
        MONTH(a.DateOrdered) MonthOrdered,
        a.OrderSource, 
        a.PromotionType as PromotionTypeID,
        b.PromotionType,
        Case when a.BillingCountryCode IN ('US','USA') then 'US'
            when a.BillingCountryCode IN ('GB','AU','CA') then ltrim(rtrim(a.BillingCountryCode))
            else 'RestOfTheWorld'
        end as CountryCode,
        a.CurrencyCode,
        case when a.SequenceNum = 1 then 'FirstOrder'
            else '2+ Orders'
        end as FlagFirstOrder,
        --case when a.AdCode = 16281 then 'WebDefault'
        --    else 'OtherAdcodes'
        --end as FlagAdcodeType, --PR 9/12 -- This variable is not needed in this report. Is included in daily report
		
		a.FlagDigitalPhysical,
        --case when a.AdCode = 16281 then 'WebDefault'
        --    else 'OtherAdcodes'
        --end as FlagAdcodeType, --PR 9/12 -- This variable is not needed in this report. Is included in daily report
        SUM(a.Netorderamount) TotalSales,
        COUNT(a.OrderID) TotalOrders,
		sum(a.Tax) TotalTaxes,
        SUM(a.TotalCourseQuantity) TotalUnits,
        SUM(a.TotalCourseParts) TotalParts,
        SUM(a.TotalTranscriptSales) TranscriptSales,
        SUM(a.TotalTranscriptQuantity) TranscriptUnits,
        SUM(a.TotalTranscriptParts) TranscriptParts ,
        SUM(a.TotalDigitalCourseSales) DigitalSales,
        SUM(a.TotalDigitalCourseUnits) DigitalUnits,
        SUM(a.TotalDigitalCourseParts) DigitalParts,
        SUM(a.TotalPhysicalCourseSales) PhysicalSales,
        SUM(a.TotalPhysicalCourseUnits) PhysicalUnits,
        SUM(a.TotalPhysicalCourseParts) PhysicalParts,
        SUM(a.TotalDigitalTranscriptSales) DigitalTranscriptSales,
        SUM(a.TotalDigitalTranscriptQuantity) DigitalTranscriptUnits,
        SUM(a.TotalDigitalTranscriptParts) DigitalTranscriptParts,
		SUM(fmt.CDSales) CDSales,
		SUM(fmt.CDUnits) CDUnits, 
		SUM(fmt.CDParts) CDParts, 
		SUM(fmt.DVDSales) DVDSales, 
		SUM(fmt.DVDUnits) DVDUnits, 
		SUM(fmt.DVDParts) DVDParts, 
		SUM(fmt.AudioTapeSales) AudioTapeSales, 
		SUM(fmt.AudioTapeUnits) AudioTapeUnits, 
		SUM(fmt.AudioTapeParts) AudioTapeParts, 
		SUM(fmt.VHSSales) VHSSales, 
		SUM(fmt.VHSUnits) VHSUnits, 
		SUM(fmt.VHSParts) VHSParts, 
		SUM(fmt.AudioDLSales) AudioDLSales, 
		SUM(fmt.AudioDLUnits) AudioDLUnits, 
		SUM(fmt.AudioDLParts) AudioDLParts, 
		SUM(fmt.VideoDLSales) VideoDLSales, 
		SUM(fmt.VideoDLUnits) VideoDLUnits, 
		SUM(fmt.VideoDLParts) VideoDLParts,
		sum(a.ShippingCharge) ShippingCharge, 
		sum(a.DiscountAmount) DiscountAmount,
		sum(fmt.TotalMerchandizeSales) TotalMerchandizeSales,
		sum(fmt.TotalMerchandizeUnits) TotalMerchandizeUnits,
		sum(fmt.TotalMerchandizeParts) TotalMerchandizeParts,
		sum(fmt.Adj_CDSales) as Adj_CDSales,
		sum(fmt.Adj_DVDSales) as Adj_DVDSales,
		sum(fmt.Adj_AudioTapeSales) as Adj_AudioTapeSales,
		sum(fmt.Adj_VHSSales) as Adj_VHSSales,
		sum(fmt.Adj_AudioDLSales) as Adj_AudioDLSales,
		sum(fmt.Adj_VideoDLSales) as Adj_VideoDLSales,
		sum(fmt.Adj_TranscriptSales) as Adj_TranscriptSales,
		sum(fmt.Adj_DigitalTranscriptSales) as Adj_DigitalTranscriptSales,
		sum(fmt.Adj_DigitalSales) as Adj_DigitalSales,
		sum(fmt.Adj_PhysicalSales) as Adj_PhysicalSales,
		sum(fmt.Adj_TotalMerchandizeSales) as Adj_TotalMerchandizeSales,
        GETDATE() as ReportDate,
        a.AgeBin,
        isnull(left(co.Gender,1),'U') as Gender,
        -- co.HouseHoldIncomeBin,  -- PR 8/20 -- Update demographics from WebDecisions table
        case when co.IncomeDescription in ('1: $0-$14,999','2: $15,000 - $19,999',  -- PR 8/20 -- Update demographics from WebDecisions table
									'3: $20,000 - $29,999','4: $30,000 - $39,999',
									'5: $40,000 - $49,999') then 'LessThan$50K'
			when co.IncomeDescription in ('6: $50,000 - $74,999') then '$50K-$74K'
			when co.IncomeDescription in ('7: $75,000 - $99,999','8: $100,000 - $124,999') then '$75K-$124K'
			when co.IncomeDescription in ('9: $125,000 - $149,999','10: $150,000 - $174,999',
											'11: $175,000 - $199,999','12: $200,000 - $249,000',
											'13: $250,000+') then '$125k+'
			else 'NoInfo'
		End as HouseHoldIncomeBin,
        co.Education,
        a.CustomerSegmentPrior,
        a.FrequencyPrior,
        a.CustomerSegmentFnlPrior,
        a.NewsegPrior, a.NamePrior, a.A12mfPrior,
       -- fo.CustType,		--PR 9/12 -- This variable is causing confusion. So, removing after discussing with Amit
        vac.MD_Audience,
        vac.MD_Year,
        vac.MD_Country,
        vac.MD_PriceType,
        vac.ChannelID as MD_ChannelID,
        vac.MD_Channel,
        vac.MD_PromotionTypeID,
        vac.MD_PromotionType,
        vac.MD_CampaignID,
        vac.MD_CampaignName,
        vac.IPR_Channel
    into Marketing.MonthlyToplineReportIgnoreReturns	
    from Marketing.DMPurchaseOrders a left join
        MarketingCubes..DimPromotionType b on a.PromotionType = b.PromotionTypeID left join 
		Mapping.CustomerOverlay_WD co on co.CustomerID = a.CustomerID  left join -- PR 8/20 -- Update demographics from WebDecisions table
		Mapping.vwAdcodesAll vac on a.AdCode = vac.AdCode left join
		Marketing.DMSOUPByFormatIgnoreReturns fmt on a.OrderID = fmt.Orderid
   -- where year(a.DateOrdered) >= YEAR(getdate())-1
   where year(a.DateOrdered) >= YEAR(getdate())-7
    group by YEAR(a.DateOrdered),
        MONTH(a.DateOrdered),
        a.OrderSource, 
        a.PromotionType,
        b.PromotionType,
        Case when a.BillingCountryCode IN ('US','USA') then 'US'
            when a.BillingCountryCode IN ('GB','AU','CA') then ltrim(rtrim(a.BillingCountryCode))
            else 'RestOfTheWorld'
        end,
        a.CurrencyCode,
        case when a.SequenceNum = 1 then 'FirstOrder'
            else '2+ Orders'
        end,
        --case when a.AdCode = 16281 then 'WebDefault'    --PR 9/12 -- This variable is not needed in this report. Is included in daily report
        --    else 'OtherAdcodes'
        --end,
		a.FlagDigitalPhysical,
        a.AgeBin,
        isnull(left(co.Gender,1),'U'),
        case when co.IncomeDescription in ('1: $0-$14,999','2: $15,000 - $19,999',  -- PR 8/20 -- Update demographics from WebDecisions table
									'3: $20,000 - $29,999','4: $30,000 - $39,999',
									'5: $40,000 - $49,999') then 'LessThan$50K'
			when co.IncomeDescription in ('6: $50,000 - $74,999') then '$50K-$74K'
			when co.IncomeDescription in ('7: $75,000 - $99,999','8: $100,000 - $124,999') then '$75K-$124K'
			when co.IncomeDescription in ('9: $125,000 - $149,999','10: $150,000 - $174,999',
											'11: $175,000 - $199,999','12: $200,000 - $249,000',
											'13: $250,000+') then '$125k+'
			else 'NoInfo'
		End,
        co.Education,
        a.CustomerSegmentPrior,
        a.FrequencyPrior,
        a.CustomerSegmentFnlPrior,
        a.NewsegPrior, a.NamePrior, a.A12mfPrior,
       -- fo.CustType,  --PR 9/12 -- This variable is causing confusion. So, removing after discussing with Amit
        vac.MD_Audience,
        vac.MD_Year,
        vac.MD_Country,
        vac.MD_PriceType,
        vac.ChannelID ,
        vac.MD_Channel,
        vac.MD_PromotionTypeID,
        vac.MD_PromotionType,
        vac.MD_CampaignID,
        vac.MD_CampaignName ,
        vac.IPR_Channel   
    order by 1,2	


end
GO
