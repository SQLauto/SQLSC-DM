SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE View [Archive].[Vw_TGCplus_VideoEvents_Smry]  
as  
select v.* ,d.CourseName, c.title AS course_title, c.title AS LectureTitle, c.genre,d.PrimaryWebCategory  
from Marketing.TGCplus_VideoEvents_Smry v  
LEFT OUTER JOIN Archive.TGCPlus_Film AS c WITH (nolock) ON v.Vid = c.uuid   
LEFT OUTER JOIN Staging.vw_dmcourse (nolock) d on v.courseid = d.CourseID  
where (ISNULL(v.uip, '') NOT IN ('207.239.38.226', '10.11.244.209')) AND (YEAR(v.TSTAMP) >= 2016)  

GO
