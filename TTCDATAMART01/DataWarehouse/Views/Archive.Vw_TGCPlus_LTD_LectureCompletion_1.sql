SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE View [Archive].[Vw_TGCPlus_LTD_LectureCompletion_1]
as
select U.Id,U.Email
,isnull(S.title,F.title ) as CourseTitle
,F.title as LectureTitle
,F.Film_Type
,F.Episode_Number
,Count(PA) Total_Actions
,max(VPOS) Max_VPOS
,Runtime
,case when (isnull(max(VPOS),0)*1./nullif(runtime,0)) >.95  and (Count(PA)*1.*30/nullif(runtime,0) )>.95  
then 1 else 0 end LectureCompleted
,MAX(V.tstamp) as LastLectureActivity
from DataWarehouse.Archive.TGCPlus_User_1 U
left join DataWarehouse.Archive.TGCPlus_VideoEvents_1 V
on U.uuid = V.Uid 
left join DataWarehouse.Archive.TGCPlus_Film_1 F
on F.uuid=V.Vid
left join DataWarehouse.Archive.TGCPlus_Series_1 S
On s.id = F.show_id
where PA = 'PING' --and U.email = 'bondugulav@teachco.com'
group by u.id,U.Email ,runtime,F.title,F.film_type,S.title,F.episode_number

GO
