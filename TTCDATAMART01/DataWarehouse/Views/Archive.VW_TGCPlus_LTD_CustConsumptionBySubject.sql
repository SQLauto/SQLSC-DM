SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE View [Archive].[VW_TGCPlus_LTD_CustConsumptionBySubject] 
as

select a.ID as CustomerID
	,b.genre
	,sum(a.StreamedMins) TotalStreamedMins
	,count(distinct a.vid) TotalLectures
	,count(distinct a.courseid) TotalCourses
	,ROW_NUMBER() over(Partition by a.id order by sum(a.StreamedMins) desc
	,count(distinct a.vid) desc
	,count(distinct a.courseid) desc) Rank
from DataWarehouse.Marketing.TGCplus_VideoEvents_Smry a 
join DataWarehouse.Archive.TGCPlus_Film b on a.Vid = b.uuid
where a.FilmType = 'episode'
and a.StreamedMins > 0
group by a.ID,
	b.genre



GO
