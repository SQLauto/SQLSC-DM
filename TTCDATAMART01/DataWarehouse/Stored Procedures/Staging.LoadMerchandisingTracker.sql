SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [Staging].[LoadMerchandisingTracker]

-- PR 9/19/2012 - New
-- -- PR -- 8/8/2013 -- split HS formats into actual formats based on Ashit's request
	@Year int = -1
AS
begin
	set nocount on

	if @Year = -1 set @Year = year(getdate())
    
  	if object_id('Staging.MerchandisingTracker') is not null drop table Staging.MerchandisingTracker
    
		  
		
	select DC.FlagAudioVideo, 
		  DC.Courseid, 
		  DC.AbbrvCourseName, 
		  DC.CourseName,
		  DC.SubjectCategory2, 
		  DC.Topic,
		  DC.CourseParts,   
		  Year(DC.ReleaseDate) YR_Rls, 
	--      cast(po.DateOrdered as date) OrderDate,
		  year(po.DateOrdered) OrderYear,
		  month(po.DateOrdered) OrderMonth,
		Case when po.BillingCountryCode IN ('US','USA') then 'US'
			when po.BillingCountryCode IN ('GB','AU','CA') then ltrim(rtrim(po.BillingCountryCode))
			else 'RestOfTheWorld'
		end as CountryCode,
		Case when po.BillingCountryCode IN ('US','USA','CA') then ltrim(rtrim(po.BillingRegion)) -- 9/13/2016 added billing state and Ship country and state as per Joe's request
			else 'ROW'
		end as BillingState,
		Case when po.ShipCountryCode IN ('US','USA') then 'US'
			when po.ShipCountryCode IN ('GB','AU','CA') then ltrim(rtrim(po.ShipCountryCode))
			else 'RestOfTheWorld'
		end as ShipCountryCode,
		Case when po.ShipCountryCode IN ('US','USA','CA') then ltrim(rtrim(po.ShipRegion))
			else 'ROW'
		end as ShipState,
		po.CurrencyCode,
		  year(dc.ReleaseDate) CRS_RLS_YR,
		  month(dc.ReleaseDate) CRS_RLS_MO,
		case when po.SequenceNum = 1 then 'Prospect'
			when po.SequenceNum > 1 then 'House'
		end as customer_type,
		case when (po.DownStreamDays) <= 1080 then '0-3 Years'
			when (po.DownStreamDays) > 1080 then '4+ Years'
		end TenureBin,
	--    DC.ReleaseDate, 
		  DC.VideoDL_ReleaseDate, 
	-- 	  poi.FormatMedia,    -- PR -- 8/8 -- split HS formats into actual formats based on Ashit's request
		 ii.MediaTypeID as FormatMedia,
		  pt.PromotionType,
		  pt.IPR_Channel,
		  case when (po.DateOrdered >=DC.VideoDL_ReleaseDate) then 'Post_VDL_RLS'
			else 'Pre_VDL_RLS' 
		  end VDL_RLS_Flag,
		  DC.FlagVideoDL,
		  case when (po.ordersource like 'W') then 'Online'
			else 'Offline' 
		  end Ord_Source,
		  cdcr.FormatAVCat,
		  po.CustomerSegmentPrior,
		  po.FrequencyPrior,    
		  po.CustomerSegment2Prior,
		  po.CustomerSegmentFnlPrior, 
		  sum(totalquantity) Qty,
		  SUM(TotalParts) TotalParts,
		  SUM(poi.TotalSales) Sales,
		  GETDATE() ReportDate
	into Staging.MerchandisingTracker      
	from DataWarehouse.Marketing.DMPurchaseOrderItems poi 
	join DataWarehouse.Marketing.DMPurchaseOrders po on po.OrderID = poi.OrderID 
		and po.dateordered between '1/1/2002' and getdate() -- dateadd(day,-(DATEPART(day,getdate())-1),convert(date,GETDATE()))
	--  and po.ordersource like 'W' 
	join DataWarehouse.Mapping.DMCourse DC on poi.CourseID = DC.CourseID 
	--    and po.DateOrdered >=DC.VideoDL_ReleaseDate 
	--    and DC.FlagVideoDL = 1
	-- left join MarketingCubes.dbo.DimPromotionType pt on po.PromotionType=pt.PromotionTypeID
	left join DataWarehouse.Mapping.vwAdcodesAll pt on po.AdCode = pt.AdCode
	left join Staging.InvItem ii on poi.StockItemID = ii.StockItemID 
	left join Marketing.CustomerDynamicCourseRank cdcr on po.CustomerID = cdcr.CustomerID
	group by DC.FlagAudioVideo, 
			DC.Courseid, 
			DC.AbbrvCourseName, 
			DC.CourseName,
			DC.SubjectCategory2,
			DC.Topic,
			DC.CourseParts,   
			Year(DC.ReleaseDate), 
			--	  cast(po.DateOrdered as date),      
			year(po.DateOrdered) ,
			month(po.DateOrdered) ,
			Case when po.BillingCountryCode IN ('US','USA') then 'US'
				when po.BillingCountryCode IN ('GB','AU','CA') then ltrim(rtrim(po.BillingCountryCode))
				else 'RestOfTheWorld'
			end,
		Case when po.BillingCountryCode IN ('US','USA','CA') then ltrim(rtrim(po.BillingRegion))
			else 'ROW'
		end,
		Case when po.ShipCountryCode IN ('US','USA') then 'US'
			when po.ShipCountryCode IN ('GB','AU','CA') then ltrim(rtrim(po.ShipCountryCode))
			else 'RestOfTheWorld'
		end,
		Case when po.ShipCountryCode IN ('US','USA','CA') then ltrim(rtrim(po.ShipRegion))
			else 'ROW'
		end,
			po.CurrencyCode,
			year(dc.ReleaseDate),
			month(dc.ReleaseDate), 
			case when po.SequenceNum = 1 then 'Prospect'
				when po.SequenceNum > 1 then 'House'
			end,
			case when (po.DownStreamDays) <= 1080 then '0-3 Years'
				when (po.DownStreamDays) > 1080 then '4+ Years'
			end ,
			DC.VideoDL_ReleaseDate, 
			-- poi.FormatMedia,  -- PR -- 8/8 -- split HS formats into actual formats based on Ashit's request
			ii.MediaTypeID,
			pt.PromotionType,
			pt.IPR_Channel,
			case when (po.DateOrdered >=DC.VideoDL_ReleaseDate) then 'Post_VDL_RLS'
				else 'Pre_VDL_RLS' 
			end,
			DC.FlagVideoDL,
			case when (po.ordersource like 'W') then 'Online'
				else 'Offline' 
			end,
			cdcr.FormatAVCat,
			po.CustomerSegmentPrior,
			po.FrequencyPrior,
			po.CustomerSegment2Prior,
			po.CustomerSegmentFnlPrior

  	if object_id('Marketing.MerchandisingTracker') is not null drop table Marketing.MerchandisingTracker
    alter schema Marketing transfer Staging.MerchandisingTracker
end
GO
