SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [Staging].[LoadCourseDemographics]
	@Year int = -1
	
/* PR 8/19/2014 Update demographics based on WebDecisions data 8*/
	
AS
begin
	set nocount on

	if @Year = -1 set @Year = year(getdate())
    
  	if object_id('Staging.CourseDemographics') is not null drop table Staging.CourseDemographics
    
	  
	select DC.FlagAudioVideo, 
		  DC.Courseid, 
		  DC.AbbrvCourseName, 
		  DC.SubjectCategory2, 
		  DC.Topic,
		  DC.SubTopic,
	--      DC.CourseHours,
		  DC.CourseParts, 
	--    Year(DC.ReleaseDate) YR_Rls, 
	--      cast(po.DateOrdered as date) OrderDate,
		  year(po.DateOrdered) OrderYear,
		  month(po.DateOrdered) OrderMonth,
		  year(dc.ReleaseDate) CRS_RLS_YR,
		  month(dc.ReleaseDate) CRS_RLS_MO,
	--	  DC.ReleaseDate, 
	--    DC.VideoDL_ReleaseDate, 
		  poi.FormatMedia,
		  pt.PromotionType,
	--      case when (po.DateOrdered >=DC.VideoDL_ReleaseDate) then 'Post_VDL_RLS'
	--      else 'Pre_VDL_RLS' 
	--      end VDL_RLS_Flag,
		  DC.FlagVideoDL,
			 case when (po.ordersource like 'W') then 'Online'
		  else 'Offline' 
		  end Ord_Source,  
		  CS.Gender, 
		 -- CS.AgeBin, -- PR 8/31/2016 changed it to point to dmpurchaseorders table to get age as of purchase date
		 po.AgeBin,
		  CS.HouseHoldIncomeBin,
		  cs.Education,
		  --case when CS.Education = 'Less Than High School Diploma' then 'A: Less Than High School Diploma'
				--  when CS.Education = 'High School Diploma' then 'B: High School Diploma'
				--  when CS.Education = 'Some College' then 'C: Some College'
				--  when CS.Education = 'Bachelor Degree' then 'D: Bachelor Degree'
				--  when CS.Education = 'Graduate Degree' then 'E: Graduate Degree'
				--  when CS.Education = 'NoInfo' then 'F: NoInfo'
				--  end Education,
		  sum(totalquantity) Qty,
		  SUM(TotalParts) TotalParts,
		  SUM(poi.TotalSales) Sales
	into Staging.CourseDemographics           
	from DataWarehouse.Marketing.DMPurchaseOrderItems poi 
	join DataWarehouse.Marketing.DMPurchaseOrders po on po.OrderID = poi.OrderID 
	join DataWarehouse.Mapping.DMCourse DC 	on poi.CourseID = DC.CourseID 
	join datawarehouse.marketing.CampaignCustomerSignature CS on po.CustomerID=CS.Customerid
	left join MarketingCubes.dbo.DimPromotionType pt on po.PromotionType=pt.PromotionTypeID
	--where year(po.DateOrdered)>= @Year
	where po.DateOrdered >= '7/1/2011'
	group by 
			 DC.FlagAudioVideo, 
		  DC.Courseid, 
		  DC.AbbrvCourseName, 
		  DC.SubjectCategory2,
		  DC.Topic,
		  DC.SubTopic,
	--      DC.CourseHours,
		  DC.CourseParts,   
	--    Year(DC.ReleaseDate), 
	--    cast(po.DateOrdered as date),      
			 year(po.DateOrdered) ,
		  month(po.DateOrdered) ,
		  year(dc.ReleaseDate),
		  month(dc.ReleaseDate), 
	 --   DC.VideoDL_ReleaseDate, 
		  poi.FormatMedia,
		  pt.PromotionType,
	--         case when (po.DateOrdered >=DC.VideoDL_ReleaseDate) then 'Post_VDL_RLS'
	--      else 'Pre_VDL_RLS' 
	--      end,
		  DC.FlagVideoDL,
			 case when (po.ordersource like 'W') then 'Online'
		  else 'Offline' 
		  end  ,
		  CS.Gender, 
		  --CS.AgeBin ,  
		  po.AgeBin,
		  CS.HouseHoldIncomeBin,    
		  CS.Education

    
  	if object_id('Marketing.CourseDemographics') is not null drop table Marketing.CourseDemographics
    alter schema Marketing transfer Staging.CourseDemographics
end
GO
