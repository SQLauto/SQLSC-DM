SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create View [Marketing].[Vw_TGCPlus_LTD_LectureCompletion_IB]
as
select fnl.*, 
case  
    when (ISNULL(fnl.Total_StreamedMins, 0))  = 0 then 'No RunTime'
  when (ISNULL(fnl.RuntimeMins, 0)) = 0 then 'No RunTime' 
  when (ISNULL(fnl.RuntimeMins, 0)) < 0 then 'No RunTime' 
  when (ISNULL(fnl.Total_StreamedMins, 0)) < 0 then 'No RunTime' 
  when (fnl.PrcntComplete) >=90 then 'Greater than 90%'
  when (fnl.PrcntComplete) >= 0 and (fnl.PrcntComplete) <= 10 then 'Between 0-10%'
  when (fnl.PrcntComplete) > 10 and (fnl.PrcntComplete) <= 20 then 'Between 11-20%'
  when (fnl.PrcntComplete) > 20 and (fnl.PrcntComplete) <= 30 then 'Between 21-30%'
  when (fnl.PrcntComplete) > 30 and (fnl.PrcntComplete) <= 40 then 'Between 31-40%'
  when (fnl.PrcntComplete) > 40 and (fnl.PrcntComplete) <= 50 then 'Between 41-50%'
  when (fnl.PrcntComplete) > 50 and (fnl.PrcntComplete) <= 60 then 'Between 51-60%'
  when (fnl.PrcntComplete) > 60 and (fnl.PrcntComplete) <= 70 then 'Between 61-70%'
  when (fnl.PrcntComplete) > 70 and (fnl.PrcntComplete) <= 80 then 'Between 71-80%'
  when (fnl.PrcntComplete) > 80 and (PrcntComplete) <= 90 then 'Between 81-90%'
  else 'Other' 
end as DepthRatioBins
from (select U.customerid Id
  ,U.emailaddress Email
  ,U.uuid
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
  from DataWarehouse.Marketing.TGCPlus_CustomerSignature U
  left join Marketing.TGCplus_Consumption_Smry V
  on U.uuid = V.uuid
  left join DataWarehouse.Archive.TGCPlus_Film F
  on F.uuid=V.Vid
  --left join DataWarehouse.Archive.TGCPlus_Series S
  --On s.id = F.show_id
  group by u.CustomerID,U.EmailAddress, u.uuid,runtime,F.title,F.film_type,f.seriestitle,F.Episode_Number,f.Course_id)fnl
GO
