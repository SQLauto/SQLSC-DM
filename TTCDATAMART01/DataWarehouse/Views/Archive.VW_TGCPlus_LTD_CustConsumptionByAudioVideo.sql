SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE View [Archive].[VW_TGCPlus_LTD_CustConsumptionByAudioVideo] 
as

select a.ID as CustomerID
	,case when a.FlagAudio = 0 then 'Video'
		when a.FlagAudio = 1 then 'Audio'
		end as FlagAudioVideo
	,sum(a.StreamedMins) TotalStreamedMins
	,count(distinct a.vid) TotalLectures
	,count(distinct a.courseid) TotalCourses
	,ROW_NUMBER() over(Partition by a.id order by sum(a.StreamedMins) desc	,count(distinct a.vid) desc	,count(distinct a.courseid) desc) Rank
from DataWarehouse.Marketing.TGCplus_VideoEvents_Smry a 
where a.FilmType = 'episode'
and a.StreamedMins > 0
group by a.ID
	,case when a.FlagAudio = 0 then 'Video'
		when a.FlagAudio = 1 then 'Audio'
		end 



GO
