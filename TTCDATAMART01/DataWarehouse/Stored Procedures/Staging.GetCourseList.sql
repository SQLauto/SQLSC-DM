SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[GetCourseList]
AS
BEGIN
    -- Preethi Ramanujam    6/3/2009  To get list of all valid Courses

	set nocount on

    SELECT a.CourseID, a.AbbrvCourseName, a.CourseParts, 
		a.CourseHours, a.ReleaseDate, a.SubjectCategory, 
		a.SubjectCategory2, a.FlagVideoDL, a.FlagCD, 
		a.FlagDVD, a.FlagAudioDL, a.FlagAudioDLOnly,
		a.FlagAudioVideo
    FROM Mapping.DMCourse a (nolock) JOIN
          (SELECT DISTINCT CourseID 
          FROM Staging.Invitem (nolock)
          WHERE forsaleonweb=1 
			AND forsaletoconsumer=1 
			AND InvStatusID in ('Active','Disc')
			AND itemcategoryid in ('course','bundle'))B ON A.CourseID = B.courseID
    WHERE A.BundleFlag = 0
    and ReleaseDate <= GETDATE()
    ORDER BY 1	

    SELECT a.*
    FROM Mapping.DMCourse a (nolock) JOIN
          (SELECT DISTINCT CourseID 
          FROM Staging.Invitem (nolock)
          WHERE forsaleonweb=1 
			AND forsaletoconsumer=1 
			AND InvStatusID in ('Active','Disc')
			AND itemcategoryid in ('course','bundle'))B ON A.CourseID = B.courseID
    WHERE A.BundleFlag = 0
    and ReleaseDate <= GETDATE()
    ORDER BY 1

    SELECT a.*, c.ProfessorID, c.Prof_FistName, c.Prof_LastName, c.ProfQual,
          c.TeachInst
    FROM Mapping.DMCourse a (nolock) JOIN
          (SELECT DISTINCT CourseID 
          FROM Staging.Invitem (nolock)
          WHERE forsaleonweb=1 
          AND forsaletoconsumer=1 
          AND InvStatusID in ('Active','Disc')
          AND itemcategoryid in ('course'))B ON A.CourseID = B.courseID join
          (select a.*, b.FirstName as Prof_FistName, b.LastName as Prof_LastName, 
                b.ProfQual, b.TeachInst
          FROM Mapping.MktCourseProfessor a (nolock) join  
                Mapping.MktProfessor b (nolock) on a.ProfessorID = b.ProfessorID)c on a.courseid = c.courseid
    WHERE a.BundleFlag = 0
    Order by 1


    SELECT a.*, c.ProfessorID, c.Prof_FistName, c.Prof_LastName, c.ProfQual
    FROM Mapping.DMCourse a (nolock) JOIN
          (SELECT DISTINCT CourseID 
          FROM Staging.Invitem (nolock)
          WHERE itemcategoryid in ('course','bundle'))B ON A.CourseID = B.courseID join
          (select a.*, b.FirstName as Prof_FistName, b.LastName as Prof_LastName, 
                b.ProfQual
          FROM Mapping.MktCourseProfessor a (nolock) join  
                Mapping.MktProfessor b (nolock) on a.ProfessorID = b.ProfessorID)c on a.courseid = c.courseid
    Order by 1


    SELECT a.*,B.MediaTypeID
    FROM Mapping.DMCourse a (nolock) JOIN
          (SELECT DISTINCT CourseID, MediaTypeID
          FROM Staging.Invitem (nolock)
          WHERE forsaleonweb=1 
          AND forsaletoconsumer=1 
          AND itemcategoryid in ('course','bundle'))B ON A.CourseID = B.courseID
    WHERE A.BundleFlag = 0
    ORDER BY 1

END
GO
