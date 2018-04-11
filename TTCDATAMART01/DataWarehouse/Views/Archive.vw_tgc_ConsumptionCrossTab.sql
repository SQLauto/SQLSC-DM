SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[vw_tgc_ConsumptionCrossTab]
AS
SELECT        ActionDate AS date, Action, CASE WHEN transactiontype = 'Purchased' THEN 'Purchased' ELSE 'Promotional' END AS TransactionType, 
                         CASE WHEN Platform = 'Android' THEN 'Android' WHEN Platform = 'IOS' THEN 'iOS' WHEN Platform = 'ROKU' THEN 'Roku' ELSE 'Web' END AS PlatformGroup, Platform, a.courseid, 
                         DMC.CourseName, DMC.PrimaryWebCategory, DMC.TGCPlusSubjectCategory AS PlusGenre, DMC.FlagActive, DMC.ReleaseDate, a.CustomerID, 
                         sum(MediaTimePlayed) StreamedMinutes, sum(TotalActions) Plays, 'TGC' AS Property
FROM            archive.Vw_TGC_DigitalConsumption(nolock) a LEFT JOIN
                             (SELECT        *
                               FROM            staging.Vw_DMCourse(nolock)
                               WHERE        BundleFlag = 0) DMC ON a.CourseID = DMC.CourseID
WHERE        action = 'Stream'
GROUP BY ActionDate, Action, TransactionType, Platform, a.courseid, DMC.CourseName, DMC.PrimaryWebCategory, DMC.TGCPlusSubjectCategory, DMC.FlagActive, 
                         DMC.ReleaseDate, a.CustomerID
UNION ALL
SELECT        tstamp AS date, 'Stream' AS Action, CASE WHEN FilmType = 'Episode' THEN 'Purchased' ELSE 'Promotional' END AS TransactionType, 
                         CASE WHEN Platform = 'Android' THEN 'Android' WHEN Platform = 'Alexa' THEN 'Android' WHEN Platform = 'Apple TV' THEN 'iOS' WHEN Platform = 'Fire Tablet' THEN
                          'Android' WHEN Platform = 'FireTV' THEN 'Android' WHEN Platform = 'Google Home' THEN 'Android' WHEN Platform = 'iOS' THEN 'iOS' WHEN Platform = 'MobileWeb'
                          THEN 'Web' WHEN Platform = 'ROKU' THEN 'Roku' WHEN Platform = 'WebSite' THEN 'Web' END AS PlatformGroup, Platform, a.courseid, DMC.CourseName, 
                         DMC.PrimaryWebCategory, DMC.TGCPlusSubjectCategory AS PlusGenre, DMC.FlagActive, DMC.ReleaseDate, ID AS CustomerID, sum(StreamedMins) 
                         StreamedMinutes, sum(Plays) Plays, 'Plus' AS Property
FROM            marketing.TGCplus_VideoEvents_Smry(nolock) a LEFT JOIN
                             (SELECT        *
                               FROM            staging.Vw_DMCourse(nolock)
                               WHERE        BundleFlag = 0) DMC ON a.CourseID = DMC.CourseID
WHERE        year(tstamp) >= 2017 
GROUP BY tstamp, filmtype, Platform, a.courseid, DMC.CourseName, DMC.PrimaryWebCategory, DMC.TGCPlusSubjectCategory, dmc.FlagActive, DMC.ReleaseDate, a.ID
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
', 'SCHEMA', N'Archive', 'VIEW', N'vw_tgc_ConsumptionCrossTab', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'Archive', 'VIEW', N'vw_tgc_ConsumptionCrossTab', NULL, NULL
GO
