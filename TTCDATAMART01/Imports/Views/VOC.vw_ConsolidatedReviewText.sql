SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [VOC].[vw_ConsolidatedReviewText]
AS

-- Facebook Code
select 
'Facebook' as Platform,
comment_id, 
comment_text,
post_id,
post_text,
cast(post_date as date) post_date, 
cast(comment_date as date) comment_date
from Imports.VOC.FB_TopLevelComments (nolock)
union all
select 
'Facebook' as Platform,
b.comment_id as comment_id,
a.reply_text as comment_text,
b.post_id,
b.post_text,
cast(b.post_date as date) post_date, 
cast(a.reply_date as date) comment_date
from Imports.VOC.FB_CommentReplies (nolock) a left join Imports.VOC.FB_TopLevelComments (nolock) b on a.original_comment_id = b.comment_id
union all
-- You Tube
select 
'YouTube' as Platform,
a.comment_id, 
a.textOriginal as comment_text,
a.videoid as post_id,
b.videoTitle as post_text,
b.publishedAt as post_date, 
a.publishedAt as comment_date
from Imports.VOC.TGCPlus_YouTube_Comments (nolock) a left join  Imports.VOC.TGCPlus_YouTube_videoDetails (nolock) b on a.videoId = b.videoId
union all
-- TGC Plus App Store
Select 
'PlusAppStore' as Platform,
review_id as comment_id,
content as comment_text,
app_ext_id as post_id,
title as post_text,
cast(date as date) post_date,
cast(created as date) comment_date 
from Imports.VOC.TGCPlus_AppFollow_Reviews (nolock) 
union all
Select 
'TGCAppStore' as Platform,
review_id as comment_id,
content as comment_text,
app_ext_id as post_id,
title as post_text,
cast(date as date) post_date,
cast(created as date) comment_date 
from Imports.VOC.TGC_AppFollow_Reviews (nolock) 
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
