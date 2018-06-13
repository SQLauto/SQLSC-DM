SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE view [Staging].[Vw_TGCPlusCoursesTemp]
AS
    

select distinct a.Course_id as CourseID, 'PLUS: ' + a.seriestitle as CourseName,
	substring('Plus' + datawarehouse.dbo.RemoveNonAlphaCharacters(a.seriestitle),1,50) as AbbrvCourseName,
	--Convert(varchar,null) as AbbrvCourseName,
	Convert(money,1) as CourseParts,
	Convert(money,c.CourseHours) as CourseHours,
	Convert(datetime,null) as ReleaseDate,
	Convert(varchar,null) as SubjectCategory,
	Convert(varchar,null) as SubjectCategory2,
	Convert(int,null) as SubjectCategoryID,
	Convert(varchar,null) as PCASubjectCategory,
	Convert(tinyint,0) as BundleFlag,
	Convert(float,null) as PreReleaseCoursePref,
	Convert(float,null) as PostReleaseCourseSat,
	Convert(datetime,null) as CSATAsOfDate,
	Convert(tinyint,null) as FlagActive,
	Convert(smalldatetime,null) as TerminationDate,
	Convert(float,null) as PreReleaseSubjectMultiplier,
	Convert(float,null) as PrefPoint,
	Convert(varchar,null) as PDSubjectCategory,
	Convert(int,null) as TotalPaidImages,
	Convert(money,null) as CostPaidImages,
	Convert(int,null) as TotalFreeImages,
	Convert(varchar,null) as Topic,
	Convert(varchar,null) as SubTopic,
	Convert(varchar,null) as FlagAudioVideo,
	Convert(tinyint,null) as FlagAudioDL,
	Convert(tinyint,null) as FlagVideoDL,
	Convert(datetime,null) as VideoDL_ReleaseDate,
	Convert(tinyint,null) as FlagCD,
	Convert(tinyint,null) as FlagDVD,
	Convert(tinyint,null) as FlagAudioDLOnly,
	Convert(bit,null) as FlagBuffetSet,
	Convert(tinyint,null) as FlagCLRCourse,
	Convert(date,null) as DateCLRCourseAdded,
	Convert(date,null) as DateCLRCourseRemoved,
	Convert(tinyint,null) as HowToFlag,
	Convert(tinyint,null) as NonCoreFlag,
	Convert(smallint,null) as CoBrandPartnerID,
	Convert(varchar,null) as PrimaryWebCategory,
	Convert(varchar,null) as PrimaryWebSubcategory,
	Convert(money,null) as CourseCost
	--null CourseHours, null ReleaseDate, null SubjectCategory, null SubjectCategory2, null as SubjectCategoryID, 
	--null as PCASubjectCategory, null as BundleFlag, null as PreReleaseCoursePref, null as PostReleaseCourseSat, 
	--null as CSATAsOfDate, null as FlagActive, null as TerminationDate, null as PreReleaseSubjectMultiplier, 
	--null as PrefPoint, null as PDSubjectCategory, null as TotalPaidImages, null as CostPaidImages, 
	--null as TotalFreeImages, null as Topic, null as SubTopic, null as FlagAudioVideo, null as FlagAudioDL, 
	--null as FlagVideoDL, null as VideoDL_ReleaseDate, null as FlagCD, null as FlagDVD, null as FlagAudioDLOnly, 
	--null as FlagBuffetSet, null as FlagCLRCourse, null as DateCLRCourseAdded, null as DateCLRCourseRemoved, 
	--null as HowToFlag, null as NonCoreFlag, null as CoBrandPartnerID, null as PrimaryWebCategory, 
	--null as PrimaryWebSubcategory, null as CourseCost
from Archive.TGCPlus_Film a 
left join Mapping.dmcourse b on a.course_id = b.CourseID
left join Archive.Vw_TGCPlus_CourseCategory c on a.course_id = c.CourseID
where b.CourseID is null
and a.course_id is not null




GO
