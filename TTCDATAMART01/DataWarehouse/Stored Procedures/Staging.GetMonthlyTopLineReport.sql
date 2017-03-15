SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[GetMonthlyTopLineReport] 
AS
	-- Preethi Ramanujam    2/6/2012 - Get monthly top line report
	-- PR -- 2/7/2014  -- Include Marketing dimensions as per Amit's request
	-- PR -- 8/20/2014 -- Update demographics from WebDecisions table
	-- PR -- 9/12/2014 -- Remove FlagAdcodeType and CustType. They are inlcuded in other reports.
	-- PR -- 6/3/2015 -- Added IPR_Channel to the table.
begin

    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'MonthlyToplineReport')
        DROP TABLE Marketing.MonthlyToplineReport



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
        SUM(a.Netorderamount) TotalSales,
        COUNT(a.OrderID) TotalOrders,
        SUM(a.TotalCourseQuantity) TotalUnits,
        SUM(a.TotalCourseParts) TotalParts,
        SUM(a.TotalTranscriptQuantity) TotalTranscripts,
        SUM(a.TotalTranscriptParts) TotalTranscriptParts ,
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
    into Marketing.MonthlyToplineReport	
    from Marketing.DMPurchaseOrders a left join
        MarketingCubes..DimPromotionType b on a.PromotionType = b.PromotionTypeID 
        left join 
--		Mapping.CustomerOverLay co on co.CustomerID = a.CustomerID  left join
		Mapping.CustomerOverlay_WD co on co.CustomerID = a.CustomerID  left join -- PR 8/20 -- Update demographics from WebDecisions table
		--(select CustomerID, OrderID, DateOrdered,       --PR 9/12 -- This variable is causing confusion. So, removing after discussing with Amit
		--	case when DateOrdered < '1/1/2010' then 'Old'
		--	else 'New'
		--end as CustType
		--from Marketing.DMPurchaseOrders
		--where SequenceNum = 1)fo on a.CustomerID = fo.CustomerID left join
		Mapping.vwAdcodesAll vac on a.AdCode = vac.AdCode
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

-- Only Promotion type 
  -- select YEAR(a.DateOrdered) YearOrdered,
  --      MONTH(a.DateOrdered) MonthOrdered,
  --      a.OrderSource, 
  --      a.PromotionType as PromotionTypeID,
  --      b.PromotionType,
  --      Case when a.BillingCountryCode IN ('US','USA') then 'US'
  --          when a.BillingCountryCode IN ('GB','AU','CA') then ltrim(rtrim(a.BillingCountryCode))
  --          else 'RestOfTheWorld'
  --      end as CountryCode,
  --      a.CurrencyCode,
  --      case when a.SequenceNum = 1 then 'FirstOrder'
  --          else '2+ Orders'
  --      end as FlagFirstOrder,
  --      case when a.AdCode = 16281 then 'WebDefault'
  --          else 'OtherAdcodes'
  --      end as FlagAdcodeType,
  --      SUM(a.Netorderamount) TotalSales,
  --      COUNT(a.OrderID) TotalOrders,
  --      SUM(a.TotalCourseQuantity) TotalUnits,
  --      SUM(a.TotalCourseParts) TotalParts,
  --      SUM(a.TotalTranscriptQuantity) TotalTranscripts,
  --      SUM(a.TotalTranscriptParts) TotalTranscriptParts ,
  --      GETDATE() as ReportDate,
  --      a.AgeBin,
  --      co.Gender,
  --      co.HouseHoldIncomeBin,
  --      co.Education,
  --      a.CustomerSegmentPrior,
  --      a.FrequencyPrior,
  --      a.NewsegPrior, a.NamePrior, a.A12mfPrior,
  --      fo.CustType
  --  into Marketing.MonthlyToplineReport	
  --  from Marketing.DMPurchaseOrders a left join
  --      MarketingCubes..DimPromotionType b on a.PromotionType = b.PromotionTypeID 
  --      left join 
		--Mapping.CustomerOverLay co on co.CustomerID = a.CustomerID  left join
		--(select CustomerID, OrderID, DateOrdered,
		--	case when DateOrdered < '1/1/2010' then 'Old'
		--	else 'New'
		--end as CustType
		--from Marketing.DMPurchaseOrders
		--where SequenceNum = 1)fo on a.CustomerID = fo.CustomerID
  --  where year(a.DateOrdered) >= YEAR(getdate())-7
  --  group by YEAR(a.DateOrdered),
  --      MONTH(a.DateOrdered),
  --      a.OrderSource, 
  --      a.PromotionType,
  --      b.PromotionType,
  --      Case when a.BillingCountryCode IN ('US','USA') then 'US'
  --          when a.BillingCountryCode IN ('GB','AU','CA') then ltrim(rtrim(a.BillingCountryCode))
  --          else 'RestOfTheWorld'
  --      end,
  --      a.CurrencyCode,
  --      case when a.SequenceNum = 1 then 'FirstOrder'
  --          else '2+ Orders'
  --      end,
  --      case when a.AdCode = 16281 then 'WebDefault'
  --          else 'OtherAdcodes'
  --      end,
  --      a.AgeBin,
  --      co.Gender,
  --      co.HouseHoldIncomeBin,
  --      co.Education,
  --      a.CustomerSegmentPrior,
  --      a.FrequencyPrior,
  --      a.NewsegPrior, a.NamePrior, a.A12mfPrior,
  --      fo.CustType       
  --  order by 1,2	

end
GO
