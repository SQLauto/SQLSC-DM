SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [Staging].[Vw_DMCourse_unqProf]
AS
    

    SELECT a.*, 
		c.ProfessorID, 
		c.Prof_FistName, 
		c.Prof_LastName, 
		c.ProfQual
    FROM Mapping.DMCourse a (nolock) JOIN
          (SELECT DISTINCT CourseID 
          FROM Staging.Invitem (nolock)
          WHERE itemcategoryid in ('course'))B ON A.CourseID = B.courseID 
          join (select a.*, b.FirstName as Prof_FistName, b.LastName as Prof_LastName, 
					b.ProfQual
			  FROM Mapping.MktCourseProfessor a (nolock) join  
					Mapping.MktProfessor b (nolock) on a.ProfessorID = b.ProfessorID)c on a.courseid = c.courseid 
		  join (select courseid
				from Mapping.MktCourseProfessor 
				group by CourseID
				having COUNT(ProfessorID) = 1)sp on c.CourseID = sp.courseid	
	union
    SELECT a.*, 
		1000 as ProfessorID, 
		'MultipleProfessors' as Prof_FistName, 
		convert(varchar,sp.NumProf) + 'Profs' as Prof_LastName , 
		null ProfQual
    FROM Mapping.DMCourse a (nolock) JOIN
          (SELECT DISTINCT CourseID 
          FROM Staging.Invitem (nolock)
          WHERE itemcategoryid in ('course'))B ON A.CourseID = B.courseID 
		  join (select courseid, COUNT(professorid) NumProf
				from Mapping.MktCourseProfessor 
				group by CourseID
				having COUNT(ProfessorID) > 1)sp on a.CourseID = sp.courseid			


GO
