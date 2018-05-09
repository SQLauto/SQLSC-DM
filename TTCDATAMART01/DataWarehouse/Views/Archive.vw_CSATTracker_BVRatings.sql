SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[vw_CSATTracker_BVRatings] as
SELECT        CourseID, CourseName, Category, CategoryID, TopLevelCategory, TopLevelCategoryID, CategoryHierarchy, BrandName, 
                                                                                    TotalSubmittedReviews, PctApproved, PctRejected, PctPending, AverageOverallRating, CourseContent, ProfessorPresentation, 
                                                                                    CourseValue, PctRecommendtoaFriend, AverageEstimatedReviewWordCount, Pct5Star, Pct4Star, Pct3Star, Pct2Star, Pct1Star, 
                                                                                    TotalHelpfulnessVotes, PctYes, PctNo, NumberofUploadedPhotos, NumberofUploadedVideos, InsertedDate
                                                          FROM            Archive.BV_Ratings WITH (nolock)
                                                          WHERE        (CAST(InsertedDate AS date) = 
                                                                                        (SELECT        MAX(CAST(InsertedDate AS date)) AS Expr1
                                                                                          FROM            Archive.BV_Ratings AS BV_Ratings_1));
GO
