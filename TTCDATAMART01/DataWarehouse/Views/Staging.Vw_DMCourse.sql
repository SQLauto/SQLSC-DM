SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [Staging].[Vw_DMCourse]
AS
    
select a.CourseID
	,a.CourseName
	,a.AbbrvCourseName
	,convert(money,a.CourseParts) CourseParts
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
	,a.CourseCost
	,case when plus.course_id is null then 0 else 1 end as FlagTGCPlusCourse
	,plus.genre as TGCPlusSubjectCategory
	,bv.BVRating
	,bv.BVTotalSubmittedReviews
	,prd.ReleaseDate as TGCPlus_ReleaseDate
	,aiv.ReleaseDate as AIV_ReleaseDate
	,adbl.ReleaseDate as Audible_ReleaseDate
from Mapping.DMCourse a
	--left join Mapping.DMCourseNewSubject b on a.CourseID = b.CourseID 
	left join Mapping.TGCPartners c on a.CobrandPartnerID = c.PartnerID
	left join (select distinct course_id
					,genre
				from Archive.TGCPlus_Film
				where status = 'open'
				and course_id is not null)plus on a.CourseID = plus.course_id
	left join (select bva.CourseID, AverageOverallRating as BVRating
					,bva.TotalSubmittedReviews BVTotalSubmittedReviews
				  --,cast(bva.InsertedDate as date) as BVDateLoaded
				from Archive.BV_Ratings bva join
					(select Courseid, max(InsertedDate) MaxDate
					from Archive.BV_Ratings
					group by CourseID)bvb on bva.CourseID = bvb.CourseID
										and bva.InsertedDate = bvb.MaxDate)bv on a.CourseID = bv.CourseID
	left join (select *
			   from mapping.TGC_CourseReleasesDates
			   where bu = 'TGCPlus')prd on a.CourseID = prd.courseid
	left join (select *
			   from mapping.TGC_CourseReleasesDates
			   where bu = 'AIV')aiv on a.CourseID = aiv.courseid
	left join (select *
			   from mapping.TGC_CourseReleasesDates
			   where bu = 'Audible')adbl on a.CourseID = adbl.courseid

union

select convert(int,a.CourseID) CourseID
	,a.CourseName
	,a.AbbrvCourseName
	,convert(money,a.CourseParts) CourseParts
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
	,a.CourseCost
	,case when plus.course_id is null then 0 else 1 end as FlagTGCPlusCourse
	,plus.genre as TGCPlusSubjectCategory
	,bv.BVRating
	,bv.BVTotalSubmittedReviews
	,prd.ReleaseDate as TGCPlus_ReleaseDate
	,aiv.ReleaseDate as AIV_ReleaseDate
	,adbl.ReleaseDate as Audible_ReleaseDate
from Staging.Vw_TGCPlusCoursesTemp a
	--left join Mapping.DMCourseNewSubject b on a.CourseID = b.CourseID 
	left join Mapping.TGCPartners c on a.CobrandPartnerID = c.PartnerID
	left join (select distinct course_id
					,genre
				from Archive.TGCPlus_Film
				where status = 'open'
				and course_id is not null)plus on a.CourseID = plus.course_id
	left join (select bva.CourseID, AverageOverallRating as BVRating
					,bva.TotalSubmittedReviews BVTotalSubmittedReviews
				  --,cast(bva.InsertedDate as date) as BVDateLoaded
				from Archive.BV_Ratings bva join
					(select Courseid, max(InsertedDate) MaxDate
					from Archive.BV_Ratings
					group by CourseID)bvb on bva.CourseID = bvb.CourseID
										and bva.InsertedDate = bvb.MaxDate)bv on a.CourseID = bv.CourseID
	left join (select *
			   from mapping.TGC_CourseReleasesDates
			   where bu = 'TGCPlus')prd on a.CourseID = prd.courseid
	left join (select *
			   from mapping.TGC_CourseReleasesDates
			   where bu = 'AIV')aiv on a.CourseID = aiv.courseid
	left join (select *
			   from mapping.TGC_CourseReleasesDates
			   where bu = 'Audible')adbl on a.CourseID = adbl.courseid


			   

GO
