SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [Staging].[LoadMerchandisingTrackerDaily]

-- PR 9/12/2014 - New
-- 

AS
begin
	set nocount on
    
  	if object_id('Staging.MerchandisingTrackerDaily') is not null drop table Staging.MerchandisingTrackerDaily
		
	select DC.FlagAudioVideo, 
		  DC.Courseid, 
		  DC.AbbrvCourseName, 
		  DC.CourseName,
		  DC.SubjectCategory2, 
		  DC.Topic,
		  DC.CourseParts,   
		  year(po.DateOrdered) OrderYear,
		  month(po.DateOrdered) OrderMonth,
		  Staging.GetMonday(po.dateordered) OrderWeek,
		  datediff(week,po.DateOrdered,GETDATE()) WeekSince,
		  cast(po.DateOrdered as date) OrderDate,
		Case when po.BillingCountryCode IN ('US','USA') then 'US'
			when po.BillingCountryCode IN ('GB','AU','CA') then ltrim(rtrim(po.BillingCountryCode))
			else 'RestOfTheWorld'
		end as CountryCode,
		  year(dc.ReleaseDate) CRS_RLS_YR,
		  month(dc.ReleaseDate) CRS_RLS_MO,
		  dc.ReleaseDate CRS_RLS_DT,
		case when po.SequenceNum = 1 then 'Prospect'
			when po.SequenceNum > 1 then 'House'
		end as CustomerType,
		 ii.MediaTypeID as FormatMedia,
		 poi.StockItemID,
		  case when (po.ordersource like 'W') then 'Online'
			else 'Offline' 
		  end OrderSource,
		  va.MD_Channel,
		  sum(totalquantity) TotalUnits,
		  SUM(TotalParts) TotalParts,
		  SUM(poi.TotalSales) Sales,
		  GETDATE() ReportDate
	into Staging.MerchandisingTrackerDaily      
	from DataWarehouse.Marketing.DMPurchaseOrderItems poi 
	join DataWarehouse.Marketing.DMPurchaseOrders po on po.OrderID = poi.OrderID 
												and po.dateordered between dateadd(month,-13,getdate()) and getdate()
	join (select *
		from DataWarehouse.Mapping.DMCourse 
		where releasedate < getdate())DC on poi.CourseID = DC.CourseID 
	left join MarketingCubes.dbo.DimPromotionType pt on po.PromotionType=pt.PromotionTypeID
	left join Staging.InvItem ii on poi.StockItemID = ii.StockItemID 
	left join Mapping.vwAdcodesAll va on po.AdCode = va.AdCode
	group by DC.FlagAudioVideo, 
		  DC.Courseid, 
		  DC.AbbrvCourseName, 
		  DC.CourseName,
		  DC.SubjectCategory2, 
		  DC.Topic,
		  DC.CourseParts,   
		  year(po.DateOrdered),
		  month(po.DateOrdered),
		  Staging.GetMonday(po.dateordered),
		  datediff(week,po.dateOrdered,GETDATE()),
		  cast(po.DateOrdered as date),
		Case when po.BillingCountryCode IN ('US','USA') then 'US'
			when po.BillingCountryCode IN ('GB','AU','CA') then ltrim(rtrim(po.BillingCountryCode))
			else 'RestOfTheWorld'
		end,
		  year(dc.ReleaseDate),
		  month(dc.ReleaseDate),
		  dc.ReleaseDate,
		case when po.SequenceNum = 1 then 'Prospect'
			when po.SequenceNum > 1 then 'House'
		end,
		 ii.MediaTypeID,
		 poi.StockItemID,
		  case when (po.ordersource like 'W') then 'Online'
			else 'Offline' 
		  end,
		  va.MD_Channel

  	if object_id('Marketing.MerchandisingTrackerDaily') is not null drop table Marketing.MerchandisingTrackerDaily
    alter schema Marketing transfer Staging.MerchandisingTrackerDaily
end
GO
