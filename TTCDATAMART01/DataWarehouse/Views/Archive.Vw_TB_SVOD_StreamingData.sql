SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[Vw_TB_SVOD_StreamingData] as
SELECT 
a.*,
b.Topic,
b.ReleaseDate as TGCReleaseDate,
b.CourseName,
GenreLkp.genre
  FROM [Archive].[Amazon_streaming] (nolock) a 
		left join mapping.dmcourse (nolock) b on a.CourseID = b.CourseID
		left join
		(
		select distinct b.courseid, c.genre from Marketing.TGCPlus_VideoEvents_Smry (nolock) b LEFT JOIN Datawarehouse.Archive.TGCPlus_Film (nolock) c on b.vid = c.uuid
		) as GenreLkp on a.CourseID = GenreLkp.courseid; 
GO
