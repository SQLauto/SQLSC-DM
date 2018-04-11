SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE View [Archive].[VW_TGCPlus_LTD_CustConsumptionByPlayer] 
as

select a.ID as CustomerID
	,case when a.Player is null then isnull(Platform,'')
		else isnull(Platform,'') + '_' + isnull(a.Player, '') 
	end as Player
	,sum(a.StreamedMins) TotalStreamedMins
	,count(distinct a.vid) TotalLectures
	,count(distinct a.courseid) TotalCourses
	,ROW_NUMBER() over(Partition by a.id order by sum(a.StreamedMins) desc	,count(distinct a.vid) desc	,count(distinct a.courseid) desc) Rank
from DataWarehouse.Marketing.TGCplus_VideoEvents_Smry a 
where a.FilmType = 'episode'
and a.StreamedMins > 0
group by a.ID
	,case when a.Player is null then isnull(Platform,'')
		else isnull(Platform,'') + '_' + isnull(a.Player, '') 
	end 



GO
