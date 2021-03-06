CREATE TABLE [Staging].[SSIS_BV_Ratings]
(
[ProductName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProductID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Category] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CategoryID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TopLevelCategory] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TopLevelCategoryID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CategoryHierarchy] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BrandName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalSubmittedReviews] [float] NULL,
[TotalSubmittedRatingsOnlyReviews] [float] NULL,
[PctApproved] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PctRejected] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PctPending] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AverageOverallRating] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseContent] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProfessorPresentation] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseValue] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PctRecommendtoaFriend] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AverageEstimatedReviewWordCount] [float] NULL,
[Pct5Star] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Pct4Star] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Pct3Star] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Pct2Star] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Pct1Star] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalHelpfulnessVotes] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PctYes] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PctNo] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumberofUploadedPhotos] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumberofUploadedVideos] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
