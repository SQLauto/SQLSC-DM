SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE View [Archive].[Vw_TGCPlus_LTD_LectureCompletionOLD]
as
select U.Id,U.Email
,f.Course_id
,F.seriestitle as CourseTitle
,F.Episode_Number
,F.title as LectureTitle
,F.Film_Type
,Count(PA) Total_Actions
,max(VPOS) Max_VPOS
,Runtime
,case when (isnull(max(VPOS),0)*1./nullif(runtime,0)) >.95  and (Count(PA)*1.*30/nullif(runtime,0) )>.95  
then 1 else 0 end LectureCompleted
,MAX(V.tstamp) as LastLectureActivity
from DataWarehouse.Archive.TGCPlus_User U
left join DataWarehouse.Archive.TGCPlus_VideoEvents V
on U.uuid = V.Uid 
left join DataWarehouse.Archive.TGCPlus_Film F
on F.uuid=V.Vid
--left join DataWarehouse.Archive.TGCPlus_Series S
--On s.id = F.show_id
where PA = 'PING' and U.email = 'ramanujamp@teachco.com'
group by u.id,U.Email ,runtime,F.title,F.film_type,f.seriestitle,F.Episode_Number,f.Course_id




GO
