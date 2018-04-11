SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[vw_TGC_Digital_CourseCompletion] as
select 
a.*,
b.CourseName, b.PrimaryWebCategory, b.SubjectCategory2, b.PlusGenre, b.FlagActive
from Marketing.Omni_TGC_LTDCourseConsumption (nolock) a
	left join  (SELECT        CourseID, CourseName, PrimaryWebCategory, SubjectCategory2, TGCPlusSubjectCategory AS PlusGenre, FlagActive
                               FROM            staging.vw_dmcourse(nolock)
                               WHERE        BundleFlag = 0 AND Courseid > 0) b ON a.CourseID = b.CourseID;
GO
