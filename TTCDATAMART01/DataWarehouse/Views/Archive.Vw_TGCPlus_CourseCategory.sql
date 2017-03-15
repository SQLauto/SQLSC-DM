SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE View [Archive].[Vw_TGCPlus_CourseCategory]
as

select distinct course_id as CourseID,  genre as TGCPlus_SubjCat
from Archive.TGCPlus_Film
where course_id is not null












GO
