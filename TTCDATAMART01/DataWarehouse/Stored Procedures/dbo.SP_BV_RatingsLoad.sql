SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE Proc [dbo].[SP_BV_RatingsLoad]  @Date date = null
as  
Begin  

if @Date is null
begin
set @Date = cast(GETDATE() as DATE)
End 
  
--Clean Staging table (issues with alpha characters in Product id)  
delete from Staging.ssis_bv_ratings where patindex('%[a-z]%', ProductId) >0  
  
  
insert into DataWarehouse.Archive.BV_Ratings   
select RA.ProductID as CourseID,RA.ProductName as CourseName,RA.Category,RA.CategoryID, RA.TopLevelCategory,RA.TopLevelCategoryID,RA.CategoryHierarchy,RA.BrandName,RA.TotalSubmittedReviews  
,RA.PctApproved, RA.PctRejected, RA.PctPending,RA.AverageOverallRating,RA.CourseContent,RA.ProfessorPresentation, RA.CourseValue, RA.PctRecommendtoaFriend,RA.AverageEstimatedReviewWordCount  
,RA.Pct5Star, RA.Pct4Star, RA.Pct3Star, RA.Pct2Star, RA.Pct1Star, RA.TotalHelpfulnessVotes, RA.PctYes, RA.PctNo, RA.NumberofUploadedPhotos, RA.NumberofUploadedVideos  
,@Date as InsertedDate   
from Staging.ssis_bv_ratings Ra  
inner join Datawarehouse.Mapping.DMCourse DM  
on DM.Courseid = Ra.ProductID  
where AverageOverallRating is not NULL  
and DM.BundleFlag = 0  
  
End
GO
