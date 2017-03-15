SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE View [Archive].[Vw_TGCPlus_CourseInfo]
as
select convert(int,course_id) as CourseID,  
      seriestitle as Coursename,  
      convert(int,episode_number) as LectureNumber,  
      title as LectureTitle,  
      case when film_type IS null and course_id > 0 then 'Episode'   
            when film_type IS null and isnull(course_id,'0') = 0 then 'Trailer'  
            else film_type  
      end as FilmType, 
      genre as SubjectCategory,
      runtime as LectureSeconds,
      (runtime/60.0) as LectureMinutes
from Archive.TGCPlus_Film



GO
