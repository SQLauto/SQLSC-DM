SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[vw_SMR_Audible]
AS

SELECT
  PartnerName AS Platform,
  CAST(D.Date AS date) AS ReportDate,
  s.CourseID,
  CAST(ReleaseDate AS date) ReleaseDate,
  CAST(x.TGCReleaseDate AS date)
  TGCReleaseDate,
  EOMonth(ReportDate) Endofmonth,
  x.CourseName,
  x.PrimaryWebCategory,
  --(Units) * 1. / Days AS [Units],
  --SUM(Revenue) / Days AS [Revenue],
  (Units) * 1. / Case when EOMOnth(CAST(D.Date AS date))  <>  EOMOnth(CAST(ReleaseDate AS date))  
                                    then Days 
                                    --When DateDiff(D,CAST(ReleaseDate AS date),EOMOnth(D.Date))<0 then Days
                                    else DateDiff(D,CAST(ReleaseDate AS date),EOMOnth(D.Date)) + 1
                                    End
  AS [Units],
  SUM(Revenue) / Case when EOMOnth(CAST(D.Date AS date))  <>  EOMOnth(CAST(ReleaseDate AS date))  
                                    then Days 
                                    else DateDiff(D,CAST(ReleaseDate AS date),EOMOnth(D.Date)) + 1
                                    End
AS [Revenue]
FROM DataWarehouse.Mapping.DATE(nolock) D
JOIN (SELECT
  Year,
  Month,
  COUNT(Date) AS Days
FROM DataWarehouse.Mapping.DATE(nolock)
GROUP BY Year,
         Month) D1
  ON D1.Month = D.Month
  AND D1.Year = D.Year
JOIN archive.Vw_Tb_Audible_sales(nolock) s
  ON D.Year = YEAR(S.ReportDate)
  AND D.Month = MONTH(S.ReportDate)
  And D.Date>= S.ReleaseDate
LEFT JOIN (SELECT DISTINCT
  courseid,
  coursename,
  PrimaryWebCategory,
  ReleaseDate AS TGCReleaseDate
FROM staging.Vw_DMCourse(nolock)
WHERE BundleFlag = 0
AND CourseID > 0) x
  ON s.CourseID = x.CourseID
/* where s.CourseID = 174  and EOMonth(ReportDate) = '2013-11-30'*/ GROUP BY PartnerName,
                                                                             CAST(D.Date AS date),
                                                                             s.CourseID,
                                                                             CAST(ReleaseDate AS date),
                                                                             Days,
                                                                             units,
                                                                             EOMonth(ReportDate),
                                                                             x.CourseName,
                                                                             x.PrimaryWebCategory,
                                                                             x.TGCReleaseDate,
																			 EOMOnth(D.Date)

																		 
																			
UNION ALL 


/* Weekly File*/ SELECT
  'Audible' AS Platform,
  CAST(D.Date AS date) ReportDate,
  s.CourseID,
  CAST(ReleaseDate AS date) ReleaseDate,
  CAST(x.TGCReleaseDate AS date)
  TGCReleaseDate,
  EOMonth(WeekEnding) Endofmonth,
  x.CourseName,
  x.PrimaryWebCategory,
  --SUM(TotalNetUnits) / Days Units,
  --SUM(TotalNetPayments) / Days AS Revenue,
  SUM(TotalNetUnits) * 1. / Case when EOMOnth(CAST(D.Date AS date))  <>  EOMOnth(CAST(ReleaseDate AS date))  
                                    then Days 
                                    --When DateDiff(D,CAST(ReleaseDate AS date),EOMOnth(D.Date))<0 then Days
                                    else DateDiff(D,CAST(ReleaseDate AS date),EOMOnth(D.Date)) + 1
                                    End
  AS [Units],
  SUM(TotalNetPayments) / Case when EOMOnth(CAST(D.Date AS date))  <>  EOMOnth(CAST(ReleaseDate AS date))  
                                    then Days 
                                    else DateDiff(D,CAST(ReleaseDate AS date),EOMOnth(D.Date)) + 1
                                    End
AS [Revenue]
FROM DataWarehouse.Mapping.DATE(nolock) D
JOIN (SELECT
  Year,
  Month,
  COUNT(Date) AS Days
FROM DataWarehouse.Mapping.DATE(nolock)
GROUP BY Year,
         Month) D1
  ON D1.Month = D.Month
  AND D1.Year = D.Year
JOIN archive.Audible_Weekly_Sales(nolock) s
  ON D.Year = YEAR(S.WeekEnding)
  AND D.Month = MONTH(S.WeekEnding)
  And D.Date>= S.ReleaseDate
LEFT JOIN (SELECT DISTINCT
  courseid,
  coursename,
  PrimaryWebCategory,
  ReleaseDate AS TGCReleaseDate
FROM staging.Vw_DMCourse(nolock)
WHERE BundleFlag = 0
AND CourseID > 0) x
  ON s.CourseID = x.CourseID
/* where s.CourseID = 174  */ GROUP BY CAST(D.Date AS date),
                                       s.CourseID,
                                       CAST(ReleaseDate AS date),
                                       Days,
                                       EOMonth(WeekEnding),
                                       x.CourseName,
                                       x.PrimaryWebCategory,
                                       CAST(x.TGCReleaseDate AS date),
									   EOMOnth(D.Date)


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
', 'SCHEMA', N'Archive', 'VIEW', N'vw_SMR_Audible', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'Archive', 'VIEW', N'vw_SMR_Audible', NULL, NULL
GO
