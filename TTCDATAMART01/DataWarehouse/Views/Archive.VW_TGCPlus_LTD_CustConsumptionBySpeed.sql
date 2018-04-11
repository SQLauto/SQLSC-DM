SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE View [Archive].[VW_TGCPlus_LTD_CustConsumptionBySpeed] 
as

select a.ID as CustomerID
	,isnull(a.Speed, '1.0') as PlayerSpeed
	,sum(a.StreamedMins) TotalStreamedMins
	,count(distinct a.vid) TotalLectures
	,count(distinct a.courseid) TotalCourses
	,ROW_NUMBER() over(Partition by a.id order by sum(a.StreamedMins) desc	,count(distinct a.vid) desc	,count(distinct a.courseid) desc) Rank
from DataWarehouse.Marketing.TGCplus_VideoEvents_Smry a 
where a.FilmType = 'episode'
and a.StreamedMins > 0
group by a.ID
	,isnull(a.Speed, '1.0')



GO
