SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE View [Archive].[vw_CourseROIDashboard_BVRatings] as
select 
convert(int, CourseID) CourseID, TotalSubmittedReviews, PctApproved, AverageOverallRating, CourseContent, ProfessorPresentation, CourseValue
from archive.BV_Ratings (nolock) 
where InsertedDate in (Select max(InsertedDate) from archive.BV_Ratings (nolock)); 





GO
