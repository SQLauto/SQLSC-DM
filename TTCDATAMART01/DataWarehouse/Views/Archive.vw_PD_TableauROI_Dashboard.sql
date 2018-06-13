SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[vw_PD_TableauROI_Dashboard] as
SELECT 
a.*,
isnull(b.TotalSubmittedReviews,0) TotalSubmittedReviews, 
isnull(b.PctApproved,0) PctApproved, 
isnull(b.AverageOverallRating,0) AverageOverallRating, 
isnull(b.CourseContent,0) CourseContent, 
isnull(b.ProfessorPresentation,0) ProfessorPresentation, 
isnull(b.CourseValue,0) CourseValue,
c.ReleaseDate as TGCReleaseDate, c.SubjectCategory, c.SubjectCategory2, c.PrimaryWebCategory, c.PrimaryWebSubcategory, c.Topic, c.SubTopic, c.TGCPlusSubjectCategory as PlusGenre, c.FlagTGCPlusCourse
  FROM [Imports].[CourseROI].[RawData] (nolock) a
	left join DataWarehouse.Archive.vw_CourseROIDashboard_BVRatings (nolock) b on a.CourseID = b.CourseID
	left join DataWarehouse.staging.vw_dmcourse (nolock) c on a.CourseID = c.CourseID; 
GO
