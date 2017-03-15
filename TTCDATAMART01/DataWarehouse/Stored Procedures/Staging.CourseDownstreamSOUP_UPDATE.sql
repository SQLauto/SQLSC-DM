SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[CourseDownstreamSOUP_UPDATE] 
	@CourseID Int = 0
AS
-- Preethi Ramanujam    1/7/2016  Get Course Downstream SOUP
	
begin

-- Get list of courses to be updated
if object_id('Staging.TempCourse_LISTfor_SOUP_Updt') is not null drop table Staging.TempCourse_LISTfor_SOUP_Updt

select a.*, b.TGCPlus_SubjCat, 
		c.ProfessorID, c.Prof_FistName, c.Prof_LastName, c.ProfQual
into Staging.TempCourse_LISTfor_SOUP_Updt
from Mapping.DMCourse a 
	left join Archive.Vw_TGCPlus_CourseCategory b on a.CourseID = b.CourseID
	left join Staging.Vw_DMCourse_unqProf c on a.CourseID = c.courseid
where a.BundleFlag = 0	
and a.CourseID > 50	
--and a.courseid in (2521,1350,9275)
--and year(a.ReleaseDate) =1900
and a.ReleaseDate between DATEADD(month,-25,getdate()) and DATEADD(DAY,-10,getdate())
--and a.ReleaseDate between '1/1/2014' and '5/31/2014'
order by a.releasedate desc

if object_id('Staging.TempCourse_Downstream_SOUP_Updt') is not null drop table Staging.TempCourse_Downstream_SOUP_Updt

select GETDATE() as ReportDate,
	a.ordersource, 
	case when a.SequenceNum = 1 then '1'
		else '2+'
	end as SequenceNum,
	convert(int,null) as MD_CountryID,
	convert(varchar(50),null) as MD_Country,
	convert(int,null) as MD_AudienceID,
	convert(varchar(50),null) as MD_Audience,
	convert(int,null) as MD_ChannelID,
	convert(varchar(50),null) as MD_Channel,
	convert(int,null) as MD_PromotionTypeID,
	convert(varchar(50),null) as MD_PromotionType,
	convert(int,null) as MD_CampaignID,
	convert(varchar(50),null) as MD_Campaign,
	convert(int,null) as MD_Year,
	convert(int,null) as MD_PriceTypeID,
	convert(varchar(50),null) as MD_PriceType,	
	d.PromotionType,
	b.CourseID,		
	c.AbbrvCourseName, c.CourseParts, c.CourseHours, c.SubjectCategory2,
	c.Topic, c.SubTopic, 
	c.PreReleaseCoursePref, c.PreReleaseSubjectMultiplier, c.PrefPoint,
	c.TGCPlus_SubjCat,
	c.FlagAudioVideo, c.FlagCD, c.FlagDVD, 
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
	c.ProfessorID, c.Prof_FistName, c.Prof_LastName, c.ProfQual,
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
	CONVERT(money,0) TotalOverallParts_3Mnth,	
	-- 15 month DS		
	sum(case when b.dateordered between c.ReleaseDate and DATEADD(DAY,450,c.ReleaseDate)	
		then b.TotalSales
		else 0
	end) TotalSales_15Mnth,	
	sum(case when b.dateordered between c.ReleaseDate and DATEADD(DAY,450,c.ReleaseDate)	
		then b.TotalQuantity
		else 0
	end) TotalUnits_15Mnth,	
	sum(case when b.dateordered between c.ReleaseDate and DATEADD(DAY,450,c.ReleaseDate)	
		then b.TotalParts
		else 0
	end) TotalParts_15Mnth,	
	CONVERT(money,0) TotalOverallSales_15Mnth,
	CONVERT(int,0) TotalOverallUnits_15Mnth,
	CONVERT(money,0) TotalOverallParts_15Mnth,	
	-- 18 month DS		
	sum(case when b.dateordered between c.ReleaseDate and DATEADD(DAY,540,c.ReleaseDate)	
		then b.TotalSales
		else 0
	end) TotalSales_18Mnth,	
	sum(case when b.dateordered between c.ReleaseDate and DATEADD(DAY,540,c.ReleaseDate)	
		then b.TotalQuantity
		else 0
	end) TotalUnits_18Mnth,	
	sum(case when b.dateordered between c.ReleaseDate and DATEADD(DAY,540,c.ReleaseDate)	
		then b.TotalParts
		else 0
	end) TotalParts_18Mnth,	
	CONVERT(money,0) TotalOverallSales_18Mnth,
	CONVERT(int,0) TotalOverallUnits_18Mnth,
	CONVERT(money,0) TotalOverallParts_18Mnth,	
	-- 21 month DS		
	sum(case when b.dateordered between c.ReleaseDate and DATEADD(DAY,630,c.ReleaseDate)	
		then b.TotalSales
		else 0
	end) TotalSales_21Mnth,	
	sum(case when b.dateordered between c.ReleaseDate and DATEADD(DAY,630,c.ReleaseDate)	
		then b.TotalQuantity
		else 0
	end) TotalUnits_21Mnth,	
	sum(case when b.dateordered between c.ReleaseDate and DATEADD(DAY,630,c.ReleaseDate)	
		then b.TotalParts
		else 0
	end) TotalParts_21Mnth,	
	CONVERT(money,0) TotalOverallSales_21Mnth,
	CONVERT(int,0) TotalOverallUnits_21Mnth,
	CONVERT(money,0) TotalOverallParts_21Mnth,	
	-- 24 month DS		
	sum(case when b.dateordered between c.ReleaseDate and DATEADD(DAY,720,c.ReleaseDate)	
		then b.TotalSales
		else 0
	end) TotalSales_24Mnth,	
	sum(case when b.dateordered between c.ReleaseDate and DATEADD(DAY,720,c.ReleaseDate)	
		then b.TotalQuantity
		else 0
	end) TotalUnits_24Mnth,	
	sum(case when b.dateordered between c.ReleaseDate and DATEADD(DAY,720,c.ReleaseDate)	
		then b.TotalParts
		else 0
	end) TotalParts_24Mnth,	
	CONVERT(money,0) TotalOverallSales_24Mnth,
	CONVERT(int,0) TotalOverallUnits_24Mnth,
	CONVERT(money,0) TotalOverallParts_24Mnth,	
	-- 30 month DS		
	CONVERT(money,0) TotalSales_30Mnth,	
	CONVERT(int,0) TotalUnits_30Mnth,	
	CONVERT(money,0) TotalParts_30Mnth,	
	CONVERT(money,0) TotalOverallSales_30Mnth,
	CONVERT(int,0) TotalOverallUnits_30Mnth,
	CONVERT(money,0) TotalOverallParts_30Mnth,	
	-- 36 month DS		
	CONVERT(money,0) TotalSales_36Mnth,	
	CONVERT(int,0) TotalUnits_36Mnth,	
	CONVERT(money,0) TotalParts_36Mnth,	
	CONVERT(money,0) TotalOverallSales_36Mnth,
	CONVERT(int,0) TotalOverallUnits_36Mnth,
	CONVERT(money,0) TotalOverallParts_36Mnth,	
	-- 48 month DS		
	CONVERT(money,0) TotalSales_48Mnth,	
	CONVERT(int,0) TotalUnits_48Mnth,	
	CONVERT(money,0) TotalParts_48Mnth,	
	CONVERT(money,0) TotalOverallSales_48Mnth,
	CONVERT(int,0) TotalOverallUnits_48Mnth,
	CONVERT(money,0) TotalOverallParts_48Mnth,	
	-- 60 month DS		
	CONVERT(money,0) TotalSales_60Mnth,	
	CONVERT(int,0) TotalUnits_60Mnth,	
	CONVERT(money,0) TotalParts_60Mnth,	
	CONVERT(money,0) TotalOverallSales_60Mnth,
	CONVERT(int,0) TotalOverallUnits_60Mnth,
	CONVERT(money,0) TotalOverallParts_60Mnth,
	-- 72 month DS		
	CONVERT(money,0) TotalSales_72Mnth,	
	CONVERT(int,0) TotalUnits_72Mnth,	
	CONVERT(money,0) TotalParts_72Mnth,	
	CONVERT(money,0) TotalOverallSales_72Mnth,
	CONVERT(int,0) TotalOverallUnits_72Mnth,
	CONVERT(money,0) TotalOverallParts_72Mnth,	
	-- 84 month DS		
	CONVERT(money,0) TotalSales_84Mnth,	
	CONVERT(int,0) TotalUnits_84Mnth,	
	CONVERT(money,0) TotalParts_84Mnth,	
	CONVERT(money,0) TotalOverallSales_84Mnth,
	CONVERT(int,0) TotalOverallUnits_84Mnth,
	CONVERT(money,0) TotalOverallParts_84Mnth,	
	-- 96 month DS		
	CONVERT(money,0) TotalSales_96Mnth,	
	CONVERT(int,0) TotalUnits_96Mnth,	
	CONVERT(money,0) TotalParts_96Mnth,	
	CONVERT(money,0) TotalOverallSales_96Mnth,
	CONVERT(int,0) TotalOverallUnits_96Mnth,
	CONVERT(money,0) TotalOverallParts_96Mnth,	
	-- 108 month DS		
	CONVERT(money,0) TotalSales_108Mnth,	
	CONVERT(int,0) TotalUnits_108Mnth,	
	CONVERT(money,0) TotalParts_108Mnth,	
	CONVERT(money,0) TotalOverallSales_108Mnth,
	CONVERT(int,0) TotalOverallUnits_108Mnth,
	CONVERT(money,0) TotalOverallParts_108Mnth,	
	-- 120 month DS		
	CONVERT(money,0) TotalSales_120Mnth,	
	CONVERT(int,0) TotalUnits_120Mnth,	
	CONVERT(money,0) TotalParts_120Mnth,	
	CONVERT(money,0) TotalOverallSales_120Mnth,
	CONVERT(int,0) TotalOverallUnits_120Mnth,
	CONVERT(money,0) TotalOverallParts_120Mnth,
	0 as FlagCmplt15days,
	0 as FlagCmplt1Mnth,
	0 as FlagCmplt2Mnth,
	0 as FlagCmplt3Mnth,
	0 as FlagCmplt6Mnth,
	0 as FlagCmplt12Mnth,
	0 as FlagCmplt15Mnth,
	0 as FlagCmplt18Mnth,
	0 as FlagCmplt21Mnth,
	0 as FlagCmplt24Mnth,
	0 as FlagCmplt30Mnth,
	0 as FlagCmplt36Mnth,
	0 as FlagCmplt48Mnth,
	0 as FlagCmplt60Mnth,
	0 as FlagCmplt72Mnth,
	0 as FlagCmplt84Mnth,
	0 as FlagCmplt96Mnth,
	0 as FlagCmplt108Mnth,
	0 as FlagCmplt120Mnth,
	getdate() UpdateDate
into Staging.TempCourse_Downstream_SOUP_Updt		
from Marketing.DMPurchaseOrders a join		
	Marketing.DMPurchaseOrderItems b on a.OrderID = b.OrderID join	
	Staging.TempCourse_LISTfor_SOUP_Updt c on b.CourseID = c.CourseID	and b.DateOrdered>= c.ReleaseDate left join
	MarketingCubes..DimPromotionType d on a.PromotionType = d.PromotionTypeID
group by a.ordersource, 
	case when a.SequenceNum = 1 then '1'
		else '2+'
	end,
	d.PromotionType,
	b.CourseID,		
	c.AbbrvCourseName, c.CourseParts, c.CourseHours, c.SubjectCategory2,
	c.Topic, c.SubTopic, 
	c.PreReleaseCoursePref, c.PreReleaseSubjectMultiplier, c.PrefPoint,
	c.TGCPlus_SubjCat,
	c.FlagAudioVideo, c.FlagCD, c.FlagDVD, 
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
	c.ProfessorID, c.Prof_FistName, c.Prof_LastName, c.ProfQual,
	DATEDIFF(Day,c.ReleaseDate,getdate()),
	DATEDIFF(Day,c.ReleaseDate,getdate())/30,
	DATEDIFF(Day,c.ReleaseDate,getdate())/365
	
select distinct ReleaseDate 
into #TempReleaseDate
from Staging.TempCourse_Downstream_SOUP_Updt

update a
set a.TotalOverallSales_15Days = b.TotalSales,
	a.TotalOverallUnits_15Days = b.TotalUnits,
	a.TotalOverallParts_15Days = b.TotalParts
from Staging.TempCourse_Downstream_SOUP_Updt a join	
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
from Staging.TempCourse_Downstream_SOUP_Updt a join	
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
from Staging.TempCourse_Downstream_SOUP_Updt a join	
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
from Staging.TempCourse_Downstream_SOUP_Updt a join	
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
from Staging.TempCourse_Downstream_SOUP_Updt a join	
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
from Staging.TempCourse_Downstream_SOUP_Updt a join	
	(select SUM(b.totalsales) TotalSales, 
		sum(b.TotalQuantity) TotalUnits,
		SUM(b.TotalParts) TotalParts,
		a.ReleaseDate
	FROM #TempReleaseDate a join
		Marketing.DMPurchaseOrderItems b on b.DateOrdered between a.ReleaseDate and DATEADD(DAY,360,a.ReleaseDate) join
		Marketing.DMPurchaseOrders c on b.OrderID = c.OrderID
	group by  a.ReleaseDate)b 	 on a.releasedate = b.releasedate
	

update a
set a.TotalOverallSales_15Mnth = b.TotalSales,
	a.TotalOverallUnits_15Mnth = b.TotalUnits,
	a.TotalOverallParts_15Mnth = b.TotalParts
from Staging.TempCourse_Downstream_SOUP_Updt a join	
	(select SUM(b.totalsales) TotalSales, 
		sum(b.TotalQuantity) TotalUnits,
		SUM(b.TotalParts) TotalParts,
		a.ReleaseDate
	FROM #TempReleaseDate a join
		Marketing.DMPurchaseOrderItems b on b.DateOrdered between a.ReleaseDate and DATEADD(DAY,450,a.ReleaseDate) join
		Marketing.DMPurchaseOrders c on b.OrderID = c.OrderID
	group by  a.ReleaseDate)b 	 on a.releasedate = b.releasedate
	
update a
set a.TotalOverallSales_18Mnth = b.TotalSales,
	a.TotalOverallUnits_18Mnth = b.TotalUnits,
	a.TotalOverallParts_18Mnth = b.TotalParts
from Staging.TempCourse_Downstream_SOUP_Updt a join	
	(select SUM(b.totalsales) TotalSales, 
		sum(b.TotalQuantity) TotalUnits,
		SUM(b.TotalParts) TotalParts,
		a.ReleaseDate
	FROM #TempReleaseDate a join
		Marketing.DMPurchaseOrderItems b on b.DateOrdered between a.ReleaseDate and DATEADD(DAY,540,a.ReleaseDate) join
		Marketing.DMPurchaseOrders c on b.OrderID = c.OrderID
	group by  a.ReleaseDate)b 	 on a.releasedate = b.releasedate
	
update a
set a.TotalOverallSales_21Mnth = b.TotalSales,
	a.TotalOverallUnits_21Mnth = b.TotalUnits,
	a.TotalOverallParts_21Mnth = b.TotalParts
from Staging.TempCourse_Downstream_SOUP_Updt a join	
	(select SUM(b.totalsales) TotalSales, 
		sum(b.TotalQuantity) TotalUnits,
		SUM(b.TotalParts) TotalParts,
		a.ReleaseDate
	FROM #TempReleaseDate a join
		Marketing.DMPurchaseOrderItems b on b.DateOrdered between a.ReleaseDate and DATEADD(DAY,630,a.ReleaseDate) join
		Marketing.DMPurchaseOrders c on b.OrderID = c.OrderID
	group by  a.ReleaseDate)b 	 on a.releasedate = b.releasedate
	
update a
set a.TotalOverallSales_24Mnth = b.TotalSales,
	a.TotalOverallUnits_24Mnth = b.TotalUnits,
	a.TotalOverallParts_24Mnth = b.TotalParts
from Staging.TempCourse_Downstream_SOUP_Updt a join	
	(select SUM(b.totalsales) TotalSales, 
		sum(b.TotalQuantity) TotalUnits,
		SUM(b.TotalParts) TotalParts,
		a.ReleaseDate
	FROM #TempReleaseDate a join
		Marketing.DMPurchaseOrderItems b on b.DateOrdered between a.ReleaseDate and DATEADD(DAY,720,a.ReleaseDate) join
		Marketing.DMPurchaseOrders c on b.OrderID = c.OrderID
	group by  a.ReleaseDate)b 	 on a.releasedate = b.releasedate

-- Update Complete Month flags
update Staging.TempCourse_Downstream_SOUP_Updt
set FlagCmplt15Days = case when DaysSinceRelease > 15 then 1 else 0 end,
	FlagCmplt1Mnth = case when MonthsSinceRelease > 1 then 1 else 0 end,
	FlagCmplt2Mnth = case when MonthsSinceRelease > 2 then 1 else 0 end,
	FlagCmplt3Mnth = case when MonthsSinceRelease > 3 then 1 else 0 end,
	FlagCmplt6Mnth = case when MonthsSinceRelease > 6 then 1 else 0 end,
	FlagCmplt12Mnth = case when MonthsSinceRelease > 12 then 1 else 0 end,
	FlagCmplt15Mnth = case when MonthsSinceRelease > 15 then 1 else 0 end,
	FlagCmplt18Mnth = case when MonthsSinceRelease > 18 then 1 else 0 end,
	FlagCmplt21Mnth = case when MonthsSinceRelease > 21 then 1 else 0 end,
	FlagCmplt24Mnth = case when MonthsSinceRelease > 24 then 1 else 0 end										
	
-- delete the courses that were updated 
delete a
-- select a.*
from Marketing.Course_Downstream_SOUP a join
	(select distinct courseid 
	from Staging.TempCourse_Downstream_SOUP_Updt)b on a.courseid = b.courseid

insert into Marketing.Course_Downstream_SOUP
select * from Staging.TempCourse_Downstream_SOUP_Updt

update  Marketing.Course_Downstream_SOUP
set ReportDate = GETDATE()

drop table Staging.TempCourse_Downstream_SOUP_Updt
	
end
GO
