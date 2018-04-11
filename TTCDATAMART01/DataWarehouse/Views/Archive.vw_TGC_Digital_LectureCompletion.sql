SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[vw_TGC_Digital_LectureCompletion] as
select 
a.*,
b.CourseName,
c.LectureName from Marketing.Omni_TGC_LTDLectureConsumption (nolock) a
	left join  (SELECT        CourseID, CourseName, PrimaryWebCategory, SubjectCategory2, TGCPlusSubjectCategory AS PlusGenre
                               FROM            staging.vw_dmcourse(nolock)
                               WHERE        BundleFlag = 0 AND Courseid > 0) b ON a.CourseID = b.CourseID
	LEFT JOIN
                             (SELECT DISTINCT CourseID, LectureNum AS LectureNumber, Title AS LectureName
                               FROM            mapping.MagentoCourseLectureExport(nolock)
                               WHERE        CourseID > 0) c ON a.CourseID = c.CourseID AND a.LectureNumber = c.LectureNumber; 
GO
