SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[CourseDownstreamSOUP] 
	@CourseID Int = 0
AS
-- Preethi Ramanujam    3/16/2012  Get Course Downstream SOUP
	
begin

if object_id('Staging.TempCourse_Downstream_SOUP') is not null drop table Staging.TempCourse_Downstream_SOUP

select GETDATE() as ReportDate,
	a.ordersource, 
	case when a.SequenceNum = 1 then '1'
		else '2+'
	end as SequenceNum,
	d.PromotionType,
	b.CourseID,		
	c.AbbrvCourseName, c.CourseParts, c.CourseHours, c.SubjectCategory2,
	c.Topic, c.SubTopic, c.FlagAudioVideo, c.FlagCD, c.FlagDVD, 
	c.FlagAudioDL, c.FlagVideoDL, 
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
	-- 15 days DS	
	sum(case when b.dateordered between c.ReleaseDate and DATEADD(DAY,15,c.ReleaseDate)	
		then b.TotalSales
		else 0
	end) TotalSales_15Days,	
	sum(case when b.dateordered between c.ReleaseDate and DATEADD(DAY,15,c.ReleaseDate)	
		then b.TotalQuantity
		else 0
	end) TotalUnits_15Days,	
	sum(case when b.dateordered between c.ReleaseDate and DATEADD(DAY,15,c.ReleaseDate)	
		then b.TotalParts
		else 0
	end) TotalParts_15Days,	
	CONVERT(money,0) TotalOverallSales_15Days,
	CONVERT(int,0) TotalOverallUnits_15Days,
	CONVERT(money,0) TotalOverallParts_15Days,		
	-- 1 month DS	
	sum(case when b.dateordered between c.ReleaseDate and DATEADD(DAY,30,c.ReleaseDate)	
		then b.TotalSales
		else 0
	end) TotalSales_1Mnth,	
	sum(case when b.dateordered between c.ReleaseDate and DATEADD(DAY,30,c.ReleaseDate)	
		then b.TotalQuantity
		else 0
	end) TotalUnits_1Mnth,	
	sum(case when b.dateordered between c.ReleaseDate and DATEADD(DAY,30,c.ReleaseDate)	
		then b.TotalParts
		else 0
	end) TotalParts_1Mnth,	
	CONVERT(money,0) TotalOverallSales_1Mnth,	
	CONVERT(int,0) TotalOverallUnits_1Mnth,
	CONVERT(money,0) TotalOverallParts_1Mnth,	
	-- 2 month DS		
	sum(case when b.dateordered between c.ReleaseDate and DATEADD(DAY,60,c.ReleaseDate)	
		then b.TotalSales
		else 0
	end) TotalSales_2Mnth,	
	sum(case when b.dateordered between c.ReleaseDate and DATEADD(DAY,60,c.ReleaseDate)	
		then b.TotalQuantity
		else 0
	end) TotalUnits_2Mnth,	
	sum(case when b.dateordered between c.ReleaseDate and DATEADD(DAY,60,c.ReleaseDate)	
		then b.TotalParts
		else 0
	end) TotalParts_2Mnth,	
	CONVERT(money,0) TotalOverallSales_2Mnth,
	CONVERT(int,0) TotalOverallUnits_2Mnth,
	CONVERT(money,0) TotalOverallParts_2Mnth,		
	-- 12 month DS	
	sum(case when b.dateordered between c.ReleaseDate and DATEADD(DAY,360,c.ReleaseDate)	
		then b.TotalSales
		else 0
	end) TotalSales_12Mnth,	
	sum(case when b.dateordered between c.ReleaseDate and DATEADD(DAY,360,c.ReleaseDate)	
		then b.TotalQuantity
		else 0
	end) TotalUnits_12Mnth,	
	sum(case when b.dateordered between c.ReleaseDate and DATEADD(DAY,360,c.ReleaseDate)	
		then b.TotalParts
		else 0
	end) TotalParts_12Mnth,	
	CONVERT(money,0) TotalOverallSales_12Mnth,
	CONVERT(int,0) TotalOverallUnits_12Mnth,
	CONVERT(money,0) TotalOverallParts_12Mnth,		
	-- 6 month DS	
	sum(case when b.dateordered between c.ReleaseDate and DATEADD(DAY,180,c.ReleaseDate)	
		then b.TotalSales
		else 0
	end) TotalSales_6Mnth,	
	sum(case when b.dateordered between c.ReleaseDate and DATEADD(DAY,180,c.ReleaseDate)	
		then b.TotalQuantity
		else 0
	end) TotalUnits_6Mnth,	
	sum(case when b.dateordered between c.ReleaseDate and DATEADD(DAY,180,c.ReleaseDate)	
		then b.TotalParts
		else 0
	end) TotalParts_6Mnth,
	CONVERT(money,0) TotalOverallSales_6Mnth,
	CONVERT(int,0) TotalOverallUnits_6Mnth,
	CONVERT(money,0) TotalOverallParts_6Mnth,
	-- 3 month DS		
	sum(case when b.dateordered between c.ReleaseDate and DATEADD(DAY,90,c.ReleaseDate)	
		then b.TotalSales
		else 0
	end) TotalSales_3Mnth,	
	sum(case when b.dateordered between c.ReleaseDate and DATEADD(DAY,90,c.ReleaseDate)	
		then b.TotalQuantity
		else 0
	end) TotalUnits_3Mnth,	
	sum(case when b.dateordered between c.ReleaseDate and DATEADD(DAY,90,c.ReleaseDate)	
		then b.TotalParts
		else 0
	end) TotalParts_3Mnth,	
	CONVERT(money,0) TotalOverallSales_3Mnth,
	CONVERT(int,0) TotalOverallUnits_3Mnth,
	CONVERT(money,0) TotalOverallParts_3Mnth	
into Staging.TempCourse_Downstream_SOUP		
from Marketing.DMPurchaseOrders a join		
	Marketing.DMPurchaseOrderItems b on a.OrderID = b.OrderID join	
	Mapping.DMCourse c on b.CourseID = c.CourseID	and b.DateOrdered>= c.ReleaseDate left join
	MarketingCubes..DimPromotionType d on a.PromotionType = d.PromotionTypeID
where c.BundleFlag = 0	
and c.CourseID > 50	
group by a.ordersource, 
	case when a.SequenceNum = 1 then '1'
		else '2+'
	end,
	d.PromotionType,
	b.CourseID,		
	c.AbbrvCourseName, c.CourseParts, c.CourseHours, c.SubjectCategory2,
	c.Topic, c.SubTopic, c.FlagAudioVideo, c.FlagCD, c.FlagDVD, 
	c.FlagAudioDL, c.FlagVideoDL,
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
	DATEDIFF(Day,c.ReleaseDate,getdate())/365
	
select distinct ReleaseDate 
into #TempReleaseDate
from Staging.TempCourse_Downstream_SOUP

update a
set a.TotalOverallSales_15Days = b.TotalSales,
	a.TotalOverallUnits_15Days = b.TotalUnits,
	a.TotalOverallParts_15Days = b.TotalParts
from Staging.TempCourse_Downstream_SOUP a join	
	(select SUM(b.totalsales) TotalSales, 
		sum(b.TotalQuantity) TotalUnits,
		SUM(b.TotalParts) TotalParts,
		a.ReleaseDate
	FROM #TempReleaseDate a join
		Marketing.DMPurchaseOrderItems b on b.DateOrdered between a.ReleaseDate and DATEADD(DAY,15,a.ReleaseDate) join
		Marketing.DMPurchaseOrders c on b.OrderID = c.OrderID 
	group by  a.ReleaseDate)b on a.releasedate = b.releasedate

update a
set a.TotalOverallSales_1Mnth = b.TotalSales,
	a.TotalOverallUnits_1Mnth = b.TotalUnits,
	a.TotalOverallParts_1Mnth = b.TotalParts
from Staging.TempCourse_Downstream_SOUP a join	
	(select SUM(b.totalsales) TotalSales, 
		sum(b.TotalQuantity) TotalUnits,
		SUM(b.TotalParts) TotalParts,
		a.ReleaseDate
	FROM #TempReleaseDate a join
		Marketing.DMPurchaseOrderItems b on b.DateOrdered between a.ReleaseDate and DATEADD(DAY,30,a.ReleaseDate) join
		Marketing.DMPurchaseOrders c on b.OrderID = c.OrderID
	group by  a.ReleaseDate)b  on a.releasedate = b.releasedate

update a
set a.TotalOverallSales_2Mnth = b.TotalSales,
	a.TotalOverallUnits_2Mnth = b.TotalUnits,
	a.TotalOverallParts_2Mnth = b.TotalParts
from Staging.TempCourse_Downstream_SOUP a join	
	(select SUM(b.totalsales) TotalSales, 
		sum(b.TotalQuantity) TotalUnits,
		SUM(b.TotalParts) TotalParts,
		a.ReleaseDate
	FROM #TempReleaseDate a join
		Marketing.DMPurchaseOrderItems b on b.DateOrdered between a.ReleaseDate and DATEADD(DAY,60,a.ReleaseDate) join
		Marketing.DMPurchaseOrders c on b.OrderID = c.OrderID 
	group by  a.ReleaseDate)b  on a.releasedate = b.releasedate

update a
set a.TotalOverallSales_3Mnth = b.TotalSales,
	a.TotalOverallUnits_3Mnth = b.TotalUnits,
	a.TotalOverallParts_3Mnth = b.TotalParts
from Staging.TempCourse_Downstream_SOUP a join	
	(select SUM(b.totalsales) TotalSales, 
		sum(b.TotalQuantity) TotalUnits,
		SUM(b.TotalParts) TotalParts,
		a.ReleaseDate
	FROM #TempReleaseDate a join
		Marketing.DMPurchaseOrderItems b on b.DateOrdered between a.ReleaseDate and DATEADD(DAY,90,a.ReleaseDate) join
		Marketing.DMPurchaseOrders c on b.OrderID = c.OrderID 
	group by  a.ReleaseDate)b  on a.releasedate = b.releasedate
	
update a
set a.TotalOverallSales_6Mnth = b.TotalSales,
	a.TotalOverallUnits_6Mnth = b.TotalUnits,
	a.TotalOverallParts_6Mnth = b.TotalParts
from Staging.TempCourse_Downstream_SOUP a join	
	(select SUM(b.totalsales) TotalSales, 
		sum(b.TotalQuantity) TotalUnits,
		SUM(b.TotalParts) TotalParts,
		a.ReleaseDate
	FROM #TempReleaseDate a join
		Marketing.DMPurchaseOrderItems b on b.DateOrdered between a.ReleaseDate and DATEADD(DAY,180,a.ReleaseDate) join
		Marketing.DMPurchaseOrders c on b.OrderID = c.OrderID 
	group by  a.ReleaseDate)b  on a.releasedate = b.releasedate

update a
set a.TotalOverallSales_12Mnth = b.TotalSales,
	a.TotalOverallUnits_12Mnth = b.TotalUnits,
	a.TotalOverallParts_12Mnth = b.TotalParts
from Staging.TempCourse_Downstream_SOUP a join	
	(select SUM(b.totalsales) TotalSales, 
		sum(b.TotalQuantity) TotalUnits,
		SUM(b.TotalParts) TotalParts,
		a.ReleaseDate
	FROM #TempReleaseDate a join
		Marketing.DMPurchaseOrderItems b on b.DateOrdered between a.ReleaseDate and DATEADD(DAY,360,a.ReleaseDate) join
		Marketing.DMPurchaseOrders c on b.OrderID = c.OrderID
	group by  a.ReleaseDate)b 	 on a.releasedate = b.releasedate
	

truncate table Marketing.Course_Downstream_SOUP

insert into Marketing.Course_Downstream_SOUP
select * from Staging.TempCourse_Downstream_SOUP

drop table Staging.TempCourse_Downstream_SOUP
	
end
GO
