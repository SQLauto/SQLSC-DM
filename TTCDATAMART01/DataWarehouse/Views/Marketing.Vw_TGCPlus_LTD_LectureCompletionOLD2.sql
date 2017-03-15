SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE View [Marketing].[Vw_TGCPlus_LTD_LectureCompletionOLD2]
as
select U.Id,U.Email
,f.Course_id
,F.seriestitle as CourseTitle
,F.Episode_Number
,F.title as LectureTitle
,F.Film_Type
,sum(V.plays) Total_Plays
,sum(V.pings) Total_Actions
,max(v.MaxVPOS) Max_VPOS
,convert(numeric(12,1),(max(v.MaxVPOS)*1.)/60) Max_VPOSMins
,sum(V.StreamedMins) Total_StreamedMins
,Runtime
,convert(numeric(12,1),(Runtime*1.)/60) RuntimeMins
,case when (isnull(max(MaxVPOS),0)*1./nullif(runtime,0)) >.95  and (sum(Pings)*1.*30/nullif(runtime,0) )>.95  
then 1 else 0 end LectureCompleted
--,isnull(max(MaxVPOS),0)*1./nullif(runtime,0) PrcntCompleteVPOS
--,sum(Pings)*1.*30/nullif(runtime,0) PrcntCompletedMins
,case when (isnull(max(MaxVPOS),0)*1.) > (sum(Pings)*1.*30)
	 then  convert(numeric(12,1),(sum(Pings)*1.*30/nullif(runtime,0) ) * 100)
	 else convert(numeric(12,1),(isnull(max(MaxVPOS),0)*1./nullif(runtime,0)) * 100) end PrcntComplete
,MAX(V.tstamp) as LastLectureActivity
from DataWarehouse.Archive.TGCPlus_User U
left join Marketing.TGCplus_VideoEvents_Smry V
on U.uuid = V.uuid
left join DataWarehouse.Archive.TGCPlus_Film F
on F.uuid=V.Vid
--left join DataWarehouse.Archive.TGCPlus_Series S
--On s.id = F.show_id
group by u.id,U.Email ,runtime,F.title,F.film_type,f.seriestitle,F.Episode_Number,f.Course_id




GO
