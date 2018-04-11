SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [dbo].[SP_Load_Omni_TGC_UpdateMissingCourse_Streaming]
as
Begin
select distinct MediaName 
into #web_Streaming
from DataWarehouse.Archive.Omni_TGC_web_Streaming
where courseid is null


select * from #web_Streaming
order by 1
 
select MediaName,cast(null as varchar(100))as MediaNameNew,
Replace(left(Replace(MediaName,'TGC_',''),4),'_','')CourseId,
Substring(MediaName,Patindex('%_Lect%',MediaName)+5,2)LectureNumber,
Cast(null as int) lecture_duration
Into #MediaName
from #web_Streaming
where MediaName like 'TGC_%'
order by 1

delete from #MediaName
where (isnumeric(isnull(courseid,0)) = 0 or isnumeric(isnull(LectureNumber,0)) = 0)

update a 
set a.lecture_duration = coalesce(l.video_duration,l.audio_duration),
a.MediaNameNew = l.akamai_download_id
from #MediaName a
join imports.magento.lectures l
on left(a.MediaName,16) = left(l.akamai_download_id,16)

 update S set 
 s.MediaName = m.MediaNameNew,
 S.CourseId = m.CourseId ,
 S.LectureNumber = m.LectureNumber ,
 S.lecture_duration = m.lecture_duration 
 from DataWarehouse.Archive.Omni_TGC_web_Streaming S
 join #MediaName m 
 on S.MediaName = m.medianame

--Apps
 
select distinct MediaName 
into #App_Streaming
from DataWarehouse.Archive.Omni_TGC_APPS_Streaming
where courseid is null

 
select MediaName,
Case when MediaName like 'ZA%' then Replace(Replace(left(Replace(MediaName,'ZA',''),4),'_',''),'-','')
       when MediaName like 'ZV%' then Replace(Replace(left(Replace(MediaName,'ZV',''),4),'_',''),'-','')
       else null end
       as CourseId,
Substring(MediaName,Patindex('%-L%',MediaName)+2,2) as LectureNumber,
Case when MediaName like 'ZA%' then 'Audio'
       when MediaName like 'ZV%' then 'Video'
       else 'NA'
       end as StreamedFormatType
,Cast(null as int) lecture_duration
 Into #MediaNameApps
from #App_Streaming
where MediaName like 'Z%'
and MediaName Not like '%Free%'  


delete from #MediaNameApps
where (isnumeric(isnull(courseid,0)) = 0 or isnumeric(isnull(LectureNumber,0)) = 0)

update a
set a.lecture_duration = l.video_duration
from #MediaNameApps a
join imports.magento.lectures l
on a.MediaName = l.video_brightcove_id

update a
set a.lecture_duration = l.Audio_duration
from #MediaNameApps a
join imports.magento.lectures l
on a.MediaName = l.audio_brightcove_id


 update S set 
 S.CourseId = m.CourseId ,
 S.LectureNumber = m.LectureNumber ,
 S.lecture_duration = m.lecture_duration 
 from DataWarehouse.Archive.Omni_TGC_apps_Streaming S
 join #MediaNameApps m 
 on S.MediaName = m.medianame

End
GO
