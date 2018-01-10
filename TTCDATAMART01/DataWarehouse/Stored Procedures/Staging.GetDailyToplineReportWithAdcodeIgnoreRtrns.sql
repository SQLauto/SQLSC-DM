SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[GetDailyToplineReportWithAdcodeIgnoreRtrns] 
AS
	-- Preethi Ramanujam    2/6/2012 - Get daily top line report
begin


	if object_id('Staging.DailyToplineReportWithAdcodeIgnoreRtrns') is not null drop table Staging.DailyToplineReportWithAdcodeIgnoreRtrns

    select YEAR(a.DateOrdered) YearOrdered,
        MONTH(a.DateOrdered) MonthOrdered,
        DataWarehouse.Staging.GetMonday(a.DateOrdered) WeekOrdered,
        cast(a.DateOrdered as date) DateOrdered,
        a.OrderSource, 
        Case when a.BillingCountryCode IN ('US','USA') then 'US'
            when a.BillingCountryCode IN ('GB','AU','CA') then ltrim(rtrim(a.BillingCountryCode))
            else 'RestOfTheWorld'
        end as CountryCode,
        a.CurrencyCode,
        case when a.SequenceNum = 1 then 'FirstOrder'
            else '2+ Orders'
        end as FlagFirstOrder,
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
		sum(Adj_AudioTapeSales) as Adj_AudioTapeSales,
		sum(Adj_VHSSales) as Adj_VHSSales,
		sum(Adj_AudioDLSales) as Adj_AudioDLSales,
		sum(Adj_VideoDLSales) as Adj_VideoDLSales,
		sum(Adj_TranscriptSales) as Adj_TranscriptSales,
		sum(Adj_DigitalTranscriptSales) as Adj_DigitalTranscriptSales,
		sum(Adj_DigitalSales) as Adj_DigitalSales,
		sum(Adj_PhysicalSales) as Adj_PhysicalSales,
		sum(Adj_TotalMerchandizeSales) as Adj_TotalMerchandizeSales,
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
	    vac.AdCode,
		vac.AdcodeName,
		vac.CatalogCode,
		vac.CatalogName,
		vac.StartDate,
		vac.StopDate,
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
    into staging.DailyToplineReportWithAdcodeIgnoreRtrns	
    from Marketing.DMPurchaseOrdersIgnoreReturns a left join
  		Mapping.CustomerOverlay_WD co on co.CustomerID = a.CustomerID  left join -- PR 8/20 -- Update demographics from WebDecisions table
		Mapping.vwAdcodesAll vac on a.AdCode = vac.AdCode left join
		Marketing.DMSOUPByFormatIgnoreReturns fmt on a.OrderID = fmt.Orderid
    --where year(a.DateOrdered) >= YEAR(getdate())-1
	where cast(a.DateOrdered as date) >= dateadd(month, -24, DATEADD(mm, DATEDIFF(mm,0,cast(getdate() as date)), 0))
    group by YEAR(a.DateOrdered),
        MONTH(a.DateOrdered),
        DataWarehouse.Staging.GetMonday(a.DateOrdered),
        cast(a.DateOrdered as date),
        a.OrderSource, 
        Case when a.BillingCountryCode IN ('US','USA') then 'US'
            when a.BillingCountryCode IN ('GB','AU','CA') then ltrim(rtrim(a.BillingCountryCode))
            else 'RestOfTheWorld'
        end,
        a.CurrencyCode,
        case when a.SequenceNum = 1 then 'FirstOrder'
            else '2+ Orders'
        end,
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
	    vac.AdCode,
		vac.AdcodeName,
		vac.CatalogCode,
		vac.CatalogName,
		vac.StartDate,
		vac.StopDate,
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


  	if object_id('Marketing.DailyToplineReportWithAdcodeIgnoreRtrns') is not null drop table Marketing.DailyToplineReportWithAdcodeIgnoreRtrns
    alter schema Marketing transfer Staging.DailyToplineReportWithAdcodeIgnoreRtrns



end
GO
