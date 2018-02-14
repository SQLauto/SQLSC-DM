SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [VOC].[vw_ConsolidatedReviewText]
AS 
-- FB Top level comments
SELECT 'Facebook' AS Platform, comment_id, comment_text, post_id, post_text, cast(post_date AS date) post_date, cast(comment_date AS date) 
                         comment_date, 1 as top_level_comment
FROM            Imports.VOC.FB_TopLevelComments(nolock)

UNION ALL
-- FB replies
SELECT        'Facebook' AS Platform, a.reply_id AS comment_id, a.reply_text AS comment_text, b.post_id, b.post_text, cast(b.post_date AS date) post_date, 
                         cast(a.reply_date AS date) comment_date, 0 as top_level_comment
FROM            Imports.VOC.FB_CommentReplies(nolock) a LEFT JOIN
                         Imports.VOC.FB_TopLevelComments(nolock) b ON a.original_comment_id = b.comment_id

UNION ALL
/* You Tube*/
SELECT 'YouTube' AS Platform, a.comment_id, a.textOriginal AS comment_text, a.videoid AS post_id, b.videoTitle AS post_text, b.publishedAt AS post_date, 
                         a.publishedAt AS comment_date, case when a.parent_id = 'NA' then 1 else 0 end as top_level_comment
FROM            Imports.VOC.TGCPlus_YouTube_Comments(nolock) a LEFT JOIN
                         Imports.VOC.TGCPlus_YouTube_videoDetails(nolock) b ON a.videoId = b.videoId

UNION ALL
/* TGC Plus App Store*/ 
SELECT 'PlusAppStore' AS Platform, review_id AS comment_id, isnull(title,'') + ' ' + isnull(content,'') AS comment_text, 
								app_ext_id AS post_id, app_store AS post_text, cast(date AS date) 
								post_date, cast(date AS date) comment_date, 1 as top_level_comment
FROM            Imports.VOC.TGCPlus_AppFollow_Reviews(nolock)

UNION ALL
-- TGC App Store
SELECT        'TGCAppStore' AS Platform, review_id AS comment_id, isnull(title,'') + ' ' + isnull(content,'') AS comment_text, app_ext_id AS post_id, 
						app_store AS post_text, cast(date AS date) post_date, 
                         cast(date AS date) comment_date, 1 as top_level_comment
FROM            Imports.VOC.TGC_AppFollow_Reviews(nolock)

UNION All
/* Website Reviews */ 
SELECT distinct'TGCWeb' as Platform, cast(a.reviewid as varchar(50)) comment_id, isnull(a.ReviewTitle, '') + ' ' + isnull(a.ReviewText,'') as comment_text, 
						cast(a.productid as varchar(50)) post_id,
						b.coursename as post_text, cast(b.releasedate as Date) post_date,
						cast(a.InitialPublishDate as date) comment_date, 1 as top_level_comment

from datawarehouse.[Archive].[BV_Ratings_ReviewTxt] (nolock) a left join
       datawarehouse.Staging.Vw_DMCourse (nolock) b on a.productID = b.CourseID
	   where a.ModerationStatus = 'APPROVED'
	   and (a.ReviewTitle is not null or a.ReviewText is not null)



GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', N'VOC', 'VIEW', N'vw_ConsolidatedReviewText', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'VOC', 'VIEW', N'vw_ConsolidatedReviewText', NULL, NULL
GO
