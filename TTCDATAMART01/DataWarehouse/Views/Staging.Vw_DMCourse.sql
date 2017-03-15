SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE view [Staging].[Vw_DMCourse]
AS
    
select a.CourseID
	,a.CourseName
	,a.AbbrvCourseName
	,a.CourseParts
	,a.CourseHours
	,a.ReleaseDate
	,a.SubjectCategory
	,a.SubjectCategory2
	,a.SubjectCategoryID
	,a.PCASubjectCategory
	,a.BundleFlag
	,a.PreReleaseCoursePref
	,a.FlagActive
	,a.TerminationDate
	,a.PreReleaseSubjectMultiplier
	,a.PrefPoint
	,a.Topic
	,a.SubTopic
	,a.FlagAudioVideo
	,a.FlagAudioDL
	,a.FlagVideoDL
	,a.VideoDL_ReleaseDate
	,a.FlagCD
	,a.FlagDVD
	,a.FlagAudioDLOnly
	,a.FlagBuffetSet
	,a.HowToFlag
	,a.NonCoreFlag
	,a.PrimaryWebCategory
	,a.PrimaryWebSubcategory
	,a.CoBrandPartnerID
	,c.PartnerName
	,c.AbbrvPartnerName
	,case when plus.course_id is null then 0 else 1 end as FlagTGCPlusCourse
	,plus.genre as TGCPlusSubjectCategory
from Mapping.DMCourse a
	--left join Mapping.DMCourseNewSubject b on a.CourseID = b.CourseID 
	left join Mapping.TGCPartners c on a.CobrandPartnerID = c.PartnerID
	left join (select distinct course_id
					,genre
				from Archive.TGCPlus_Film)plus on a.CourseID = plus.course_id



GO
