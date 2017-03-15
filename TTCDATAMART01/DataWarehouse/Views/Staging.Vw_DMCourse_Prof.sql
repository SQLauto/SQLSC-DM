SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [Staging].[Vw_DMCourse_Prof]
AS
    

    SELECT a.*,
		f.genre as TGCPlus_SubjectCategory, isnull(f.FlagTGCPlusCourse,0) FlagTGCPlusCourse,
		c.ProfessorID, c.Prof_FistName, c.Prof_LastName, c.ProfQual,
          c.TeachInst, ROW_NUMBER() over (Partition by a.courseID order by c.ProfessorID) Prof_NumForCourse
    FROM Mapping.DMCourse a (nolock) 
		JOIN
          (SELECT DISTINCT CourseID 
          FROM Staging.Invitem (nolock)
          WHERE forsaleonweb=1 
          AND forsaletoconsumer=1 
          AND InvStatusID in ('Active','Disc')
          AND itemcategoryid in ('course'))B ON A.CourseID = B.courseID 
        left join
          (select a.*, b.FirstName as Prof_FistName, b.LastName as Prof_LastName, 
                b.ProfQual, b.TeachInst
          FROM Mapping.MktCourseProfessor a (nolock) join  
                Mapping.MktProfessor b (nolock) on a.ProfessorID = b.ProfessorID)c on a.courseid = c.courseid
        left join (select distinct course_id as CourseID, genre, 1 as FlagTGCPlusCourse
					from Archive.TGCPlus_Film
					where course_id is not null)f on a.CourseID = f.CourseID
					     
    WHERE a.BundleFlag = 0


GO
