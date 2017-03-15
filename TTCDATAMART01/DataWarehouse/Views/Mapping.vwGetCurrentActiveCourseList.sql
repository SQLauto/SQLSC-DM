SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [Mapping].[vwGetCurrentActiveCourseList]
AS
    
    SELECT a.CourseID, a.CourseName, a.AbbrvCourseName, a.CourseParts, 
		a.CourseHours, a.ReleaseDate, a.SubjectCategory, 
		a.SubjectCategory2, a.FlagVideoDL, a.FlagCD, 
		a.FlagDVD, a.FlagAudioDL, a.FlagAudioDLOnly,
		FlagAudioVideo,
		a.PreReleaseCoursePref,
		a.PreReleaseSubjectMultiplier,
		a.PrefPoint,
		a.HowToFlag, a.NonCoreFlag, a.Topic, a.SubTopic,
		GETDATE() ReportDate
    FROM Mapping.DMCourse a (nolock) JOIN
          (SELECT DISTINCT CourseID
          FROM Staging.Invitem (nolock)
          WHERE forsaleonweb=1 
			AND forsaletoconsumer=1 
			AND InvStatusID in ('Active','Disc')
			AND itemcategoryid in ('course','bundle'))B ON A.CourseID = B.courseID
    WHERE A.BundleFlag = 0
    and ReleaseDate <= GETDATE()





GO
