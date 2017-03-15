SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[CourseLTDSOUP] 
	@CourseID Int = 0
AS
-- Preethi Ramanujam    3/16/2012  Get Course Downstream SOUP
	
begin

if object_id('Staging.TempCourse_LTD_SOUP') is not null drop table Staging.TempCourse_LTD_SOUP

select GETDATE() as ReportDate,
	a.ordersource, 
	case when a.SequenceNum = 1 then '1'
		else '2+'
	end as SequenceNum,
	d.MD_Audience, d.ChannelID as MD_ChannelID, d.MD_Channel,
	d.MD_PromotionTypeID, d.MD_PromotionType,
	d.MD_CampaignID, d.MD_CampaignName,
	d.MD_Year, d.MD_Country, d.MD_PriceType,
	b.CourseID,		
	c.AbbrvCourseName, c.CourseParts, c.CourseHours, c.SubjectCategory2,
	c.Topic, c.SubTopic, c.FlagAudioVideo, c.FlagCD, c.FlagDVD, 
	c.FlagAudioDL, c.FlagVideoDL, 
	c.PreReleaseCoursePref, c.PreReleaseSubjectMultiplier, c.PrefPoint,
	case when (b.DateOrdered >= c.VideoDL_ReleaseDate) then 'Post_VDL_RLS'
      else 'Pre_VDL_RLS' 
      end VDL_RLS_Flag,
	year(c.ReleaseDate) ReleaseYear, MONTH(c.ReleaseDate) ReleaseMonth,	
	c.ReleaseDate, 
	case when month(c.ReleaseDate) = 12 and DAY(c.ReleaseDate) > 15 then YEAR(c.ReleaseDate) + 1
		else YEAR(c.ReleaseDate) 
	end as CatalogYear,
	case when month(c.ReleaseDate) = 12 and DAY(c.ReleaseDate) > 15 then 1
		 when DAY(c.ReleaseDate) < 6 then MONTH(c.ReleaseDate)
		else MONTH(c.ReleaseDate) + 1 
	end as CatalogMonth,	
	DATEDIFF(Day,c.ReleaseDate,getdate()) DaysSinceRelease,
	DATEDIFF(Day,c.ReleaseDate,getdate())/30 MonthsSinceRelease,
	DATEDIFF(Day,c.ReleaseDate,getdate())/365 YearsSinceRelease,
	b.FormatMedia, 
	year(a.DateOrdered) YearOrdered,
	Month(a.DateOrdered) MonthOrdered,
	DataWarehouse.Staging.GetMonday(a.dateordered) as WeekOrdered,
	-- SOUP
	sum(b.TotalSales) TotalSales,	
	sum(b.TotalQuantity) TotalUnits,	
	sum(b.TotalParts) TotalParts	
into Staging.TempCourse_LTD_SOUP		
from Marketing.DMPurchaseOrders a join		
	Marketing.DMPurchaseOrderItems b on a.OrderID = b.OrderID join	
	Mapping.DMCourse c on b.CourseID = c.CourseID	and b.DateOrdered>= c.ReleaseDate left join
	Mapping.vwAdcodesAll d on a.AdCode = d.AdCode
where c.BundleFlag = 0	
and c.CourseID > 50	
--and c.ReleaseDate < '1/1/1995'
group by a.ordersource, 
	case when a.SequenceNum = 1 then '1'
		else '2+'
	end,
	d.MD_Audience, d.ChannelID, d.MD_Channel,
	d.MD_PromotionTypeID, d.MD_PromotionType,
	d.MD_CampaignID, d.MD_CampaignName,
	d.MD_Year, d.MD_Country, d.MD_PriceType,
	b.CourseID,		
	c.AbbrvCourseName, c.CourseParts, c.CourseHours, c.SubjectCategory2,
	c.Topic, c.SubTopic, c.FlagAudioVideo, c.FlagCD, c.FlagDVD, 
	c.FlagAudioDL, c.FlagVideoDL,
	c.PreReleaseCoursePref, c.PreReleaseSubjectMultiplier, c.PrefPoint,
	case when (b.DateOrdered >= c.VideoDL_ReleaseDate) then 'Post_VDL_RLS'
      else 'Pre_VDL_RLS' 
      end,	 	
	year(c.ReleaseDate) , MONTH(c.ReleaseDate),	
	c.ReleaseDate,
	case when month(c.ReleaseDate) = 12 and DAY(c.ReleaseDate) > 15 then YEAR(c.ReleaseDate) + 1
		else YEAR(c.ReleaseDate) 
	end,
	case when month(c.ReleaseDate) = 12 and DAY(c.ReleaseDate) > 15 then 1
		 when DAY(c.ReleaseDate) < 6 then MONTH(c.ReleaseDate)
		else MONTH(c.ReleaseDate) + 1 
	end, 
	b.FormatMedia, 
	DATEDIFF(Day,c.ReleaseDate,getdate()),
	DATEDIFF(Day,c.ReleaseDate,getdate())/30,
	DATEDIFF(Day,c.ReleaseDate,getdate())/365,
	year(a.DateOrdered),
	Month(a.DateOrdered),
	DataWarehouse.Staging.GetMonday(a.dateordered)
	
truncate table Marketing.Course_LTD_SOUP

insert into Marketing.Course_LTD_SOUP
select * 
from Staging.TempCourse_LTD_SOUP

drop table Staging.TempCourse_LTD_SOUP
	
end
GO
