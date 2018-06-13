SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE View [Archive].[Vw_TGCPlus_CourseCategory]
as

select course_id as CourseID,  genre as TGCPlus_SubjCat, convert(money,sum(runtime)/3600) CourseHours
from Archive.TGCPlus_Film
where course_id is not null
group by course_id, genre














GO
