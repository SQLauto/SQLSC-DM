SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[VW_TB_SVOD_StreamingWeight]
AS
SELECT        courseid, CourseName, PrimaryWebCategory, SVOD_Flag, EOMonth(TSTAMP) AS TSTAMP, SUM(SM) AS SM, GETDATE() AS DMLastupdated
FROM            (SELECT        a.courseid, b.CourseName, b.PrimaryWebCategory, CASE WHEN SVOD.CourseID IS NULL THEN 0 ELSE 1 END AS SVOD_Flag, a.TSTAMP, 
                                                    SUM(a.StreamedMins) AS SM
                          FROM            Marketing.TGCplus_VideoEvents_Smry AS a WITH (nolock) INNER JOIN
                                                    Staging.Vw_DMCourse AS b WITH (nolock) ON a.courseid = b.CourseID LEFT OUTER JOIN
                                                        (SELECT        CourseID, MIN(AvailableDate) AS availableDate
                                                          FROM            Archive.Amazon_streaming WITH (nolock)
                                                          GROUP BY CourseID) AS SVOD ON a.courseid = SVOD.CourseID AND a.TSTAMP >= SVOD.availableDate
                          WHERE        (a.CountryCode IN ('GB', 'US')) AND (a.FlagAudio = 0) AND (a.courseid > 0) AND (a.courseid IN
                                                        (SELECT DISTINCT CourseID
                                                          FROM            Staging.Vw_DMCourse WITH (nolock)
                                                          WHERE        (BundleFlag = 0) AND (FlagActive = 1) AND (ReleaseDate IS NOT NULL)))
                          GROUP BY a.courseid, a.TSTAMP, SVOD.CourseID, b.CourseName, b.PrimaryWebCategory) AS agg
GROUP BY courseid, CourseName, PrimaryWebCategory, SVOD_Flag, EOMonth(TSTAMP)
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
         Begin Table = "agg"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 135
               Right = 256
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
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
', 'SCHEMA', N'Archive', 'VIEW', N'VW_TB_SVOD_StreamingWeight', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'Archive', 'VIEW', N'VW_TB_SVOD_StreamingWeight', NULL, NULL
GO
