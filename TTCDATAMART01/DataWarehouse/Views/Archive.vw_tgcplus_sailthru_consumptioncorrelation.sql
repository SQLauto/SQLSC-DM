SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[vw_tgcplus_sailthru_consumptioncorrelation]
AS
SELECT        a.send_Date, a.Campaignname, a.Label, a.blast_id, a.EmailOpened, a.Customerid, b.IntlSubDate, b.CustStatusFlag, b.PaidFlag, b.IntlSubType, 
                         b.IntlSubPaymentHandler, a.SendTime_IntlSubType, a.SendTime_SubType, a.SendTime_CustStatusFlag, a.SendTime_PaidFlag, 
                         SUM(ISNULL(a.Prior3DayStreamedMins, 0) + ISNULL(a.Prior2DayStreamedMins, 0) + ISNULL(a.Prior1DayStreamedMins, 0)) AS Prior_SM, 
                         SUM(ISNULL(a.Post2DayStreamedMins, 0) + ISNULL(a.Post1DayStreamedMins, 0) + ISNULL(a.CurrentDayStreamedMins, 0)) AS Post_SM, 
                         SUM(ISNULL(a.Prior3DayCoursesStreamed, 0) + ISNULL(a.Prior2DayCoursesStreamed, 0) + ISNULL(a.Prior1DayCoursesStreamed, 0)) AS Prior_Courses, 
                         SUM(ISNULL(a.Post2DayCoursesStreamed, 0) + ISNULL(a.Post1DayCoursesStreamed, 0) + ISNULL(a.CurrentDayCoursesStreamed, 0)) AS Post_Courses, 
                         SUM(ISNULL(a.Prior3DayLecturesStreamed, 0) + ISNULL(a.Prior2DayLecturesStreamed, 0) + ISNULL(a.Prior1DayLecturesStreamed, 0)) AS Prior_Lectures, 
                         SUM(ISNULL(a.Post2DayLecturesStreamed, 0) + ISNULL(a.Post1DayLecturesStreamed, 0) + ISNULL(a.CurrentDayLecturesStreamed, 0)) AS Post_Lectures, 
                         SUM(ISNULL(c.LTDStreamedMinutes, 0)) AS LTDStreamedMinutes
FROM            Archive.VW_Tgcplus_sailthru_blast_streaming AS a WITH (nolock) INNER JOIN
                         Archive.Vw_TGCPlus_CustomerSignature AS b WITH (nolock) ON a.Customerid = b.CustomerID LEFT OUTER JOIN
                             (SELECT        ID AS CustomerID, SUM(StreamedMins) AS LTDStreamedMinutes
                               FROM            Marketing.TGCplus_VideoEvents_Smry WITH (nolock)
                               GROUP BY ID) AS c ON a.Customerid = c.CustomerID
WHERE        (a.Label NOT IN ('Abandon'))
GROUP BY a.send_Date, a.Campaignname, a.Label, a.blast_id, a.EmailOpened, a.Customerid, b.IntlSubDate, b.CustStatusFlag, b.PaidFlag, b.IntlSubType, 
                         b.IntlSubPaymentHandler, a.SendTime_IntlSubType, a.SendTime_SubType, a.SendTime_CustStatusFlag, a.SendTime_PaidFlag
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
         Begin Table = "a"
            Begin Extent = 
               Top = 31
               Left = 729
               Bottom = 160
               Right = 988
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "b"
            Begin Extent = 
               Top = 198
               Left = 361
               Bottom = 327
               Right = 601
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "c"
            Begin Extent = 
               Top = 6
               Left = 335
               Bottom = 101
               Right = 554
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
', 'SCHEMA', N'Archive', 'VIEW', N'vw_tgcplus_sailthru_consumptioncorrelation', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'Archive', 'VIEW', N'vw_tgcplus_sailthru_consumptioncorrelation', NULL, NULL
GO
