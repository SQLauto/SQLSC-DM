SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[Vw_TGC_DigitalConsumption]
AS
SELECT        S.Actiondate, S.CustomerID, S.MagentoUserID, S.MarketingCloudVisitorID, S.MobileDeviceType, S.MobileDevice, S.MediaName, S.CourseID, S.LectureNumber, 
                         S.Action, S.TotalActions, S.FlagOnline, S.StreamedOrDownloadedFormatType, S.MediaTimePlayed, S.Watched25pct, S.Watched50pct, S.Watched75pct, 
                         S.Watched95pct, S.MediaCompletes, S.Lecture_duration, S.GeoSegmentationCountries, S.BrowserOrAppVersion, S.Platform, S.FormatPurchased, S.orderid, 
                         S.StockItemID, S.BillingCountryCode, S.DateOrdered, S.TransactionType, b.CourseName, C.LectureName, b.PrimaryWebCategory, b.SubjectCategory2, b.PlusGenre, 
                         CASE WHEN S.CourseID IS NOT NULL AND b.PlusGenre IS NOT NULL THEN 1 ELSE 0 END CourseAvailableOnPlus, S.DMLastUpdated, AdCode.AdCode, 
                         AdCode.MD_Channel, AdCode.MD_PromotionType, b.FlagActive
FROM            Archive.Omni_TGC_Streaming S LEFT JOIN
                             (SELECT        CourseID, CourseName, PrimaryWebCategory, SubjectCategory2, TGCPlusSubjectCategory AS PlusGenre, FlagActive
                               FROM            staging.vw_dmcourse(nolock)
                               WHERE        BundleFlag = 0 AND Courseid > 0) b ON S.CourseID = b.CourseID LEFT JOIN
                             (SELECT DISTINCT CourseID, LectureNum AS LectureNumber, Title AS LectureName
                               FROM            mapping.MagentoCourseLectureExport(nolock)
                               WHERE        CourseID > 0) c ON S.CourseID = c.CourseID AND S.LectureNumber = c.LectureNumber LEFT JOIN
                             (SELECT        CustomerID, IntlPurchaseAdCode AS AdCode, MD_Channel, MD_PromotionType
                               FROM            marketing.DMCustomerStaticNew(nolock) LEFT JOIN
                                                         mapping.vwAdcodesAll(nolock) ON marketing.dmcustomerstaticnew.IntlPurchaseAdCode = mapping.vwAdcodesAll.AdCode) AdCode ON 
                         S.CustomerID = AdCode.CustomerID
UNION ALL
SELECT        D .Actiondate, D .CustomerID, D .MagentoUserID, D .MarketingCloudVisitorID, D .MobileDeviceType, D .MobileDevice, D .MediaName, D .CourseID, 
                         D .LectureNumber, D .Action, D .TotalActions, D .FlagOnline, D .StreamedOrDownloadedFormatType, NULL AS MediaTimePlayed, NULL AS Watched25pct, NULL 
                         AS Watched50pct, NULL AS Watched75pct, NULL AS Watched95pct, NULL AS MediaCompletes, D .Lecture_duration, D .GeoSegmentationCountries, 
                         D .BrowserOrAppVersion, D .Platform, D .FormatPurchased, D .orderid, D .StockItemID, D .BillingCountryCode, D .DateOrdered, D .TransactionType, b.CourseName, 
                         C.LectureName, b.PrimaryWebCategory, b.SubjectCategory2, b.PlusGenre, CASE WHEN D .CourseID IS NOT NULL AND b.PlusGenre IS NOT NULL 
                         THEN 1 ELSE 0 END CourseAvailableOnPlus, D .DMLastUpdated, AdCode.AdCode, AdCode.MD_Channel, AdCode.MD_PromotionType, b.FlagActive
FROM            Archive.Omni_TGC_Downloads D LEFT JOIN
                             (SELECT        CourseID, CourseName, PrimaryWebCategory, SubjectCategory2, TGCPlusSubjectCategory AS PlusGenre, FlagActive
                               FROM            staging.vw_dmcourse(nolock)
                               WHERE        BundleFlag = 0 AND Courseid > 0) b ON D .CourseID = b.CourseID LEFT JOIN
                             (SELECT DISTINCT CourseID, LectureNum AS LectureNumber, Title AS LectureName
                               FROM            mapping.MagentoCourseLectureExport(nolock)
                               WHERE        CourseID > 0) c ON D .CourseID = c.CourseID AND D .LectureNumber = c.LectureNumber LEFT JOIN
                             (SELECT        CustomerID, IntlPurchaseAdCode AS AdCode, MD_Channel, MD_PromotionType
                               FROM            marketing.DMCustomerStaticNew(nolock) LEFT JOIN
                                                         mapping.vwAdcodesAll(nolock) ON marketing.dmcustomerstaticnew.IntlPurchaseAdCode = mapping.vwAdcodesAll.AdCode) AdCode ON 
                         D .CustomerID = AdCode.CustomerID
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
', 'SCHEMA', N'Archive', 'VIEW', N'Vw_TGC_DigitalConsumption', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'Archive', 'VIEW', N'Vw_TGC_DigitalConsumption', NULL, NULL
GO
