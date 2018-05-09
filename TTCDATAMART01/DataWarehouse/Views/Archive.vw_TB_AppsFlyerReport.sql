SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[vw_TB_AppsFlyerReport]
AS
SELECT DISTINCT 
                         CS.uuid, CS.CustomerID, CS.IntlSubDate, CS.IntlSubPaymentHandler, CS.IntlSubType, CS.CustStatusFlag, CS.DSMonthCancelled_New, CS.DS, CS.BillingRank, 
                         AF.Platform, CASE WHEN AF.AttributedTouchType = 'click' THEN 'Paid' WHEN AF.AttributedTouchType = 'impression' THEN 'Paid' ELSE 'Organic' END AS TouchType, 
                         AF.MediaSource, AF.Channel, AF.Keywords, AF.CampaignID, AF.Campaign, AF.AdsetID, AF.Adset, AF.AdID, AF.Ad, AF.Region, AF.CountryCode, AF.State, AF.City, 
                         AF.PostalCode, Lkp.AdCode, Lkp.Cost, CASE WHEN isnull(CT.DateDiffCol, 0) = 0 THEN 0 ELSE 1 END AS VLDataIssueIndicator, DMC.Country
FROM            (SELECT        uuid, CustomerID, IntlSubDate, IntlSubPaymentHandler, IntlSubType, CustStatusFlag, DSMonthCancelled_New, DS, BillingRank
                          FROM            Archive.Vw_TGCPlus_CustomerSignature WITH (nolock)
                          WHERE        (IntlSubDate >= '2017-08-24') AND (IntlSubDate <=
                                                        (SELECT        MAX(CAST(EventTime AS date)) AS EventDate
                                                          FROM            Marketing.TGCPLus_AppsFlyer_AppEvents WITH (nolock))) AND (IntlSubPaymentHandler IN ('iOS', 'Android'))) AS CS LEFT OUTER JOIN
                             (SELECT        EventTime, EventName, AttributedTouchType, MediaSource, Channel, Keywords, Campaign, CampaignID, Adset, AdsetID, Ad, AdID, Region, 
                                                         CountryCode, State, City, PostalCode, CustomerUserID, Platform, CAST(EventTime AS date) AS EventDate
                               FROM            Marketing.TGCPLus_AppsFlyer_AppEvents AS TGCPLus_AppsFlyer_AppEvents_1 WITH (nolock)
                               WHERE        (CustomerUserID NOT IN (''))) AS AF ON CS.uuid = AF.CustomerUserID LEFT OUTER JOIN
                             (SELECT        Platform, MediaSource, Campaign, AdCode, Cost, CampaignStartYearMonth, CampaignEndYearMonth
                               FROM            Staging.Appsflyer_ssis_master WITH (nolock)) AS Lkp ON AF.Platform = Lkp.Platform AND AF.Campaign = Lkp.Campaign AND 
                         AF.MediaSource = Lkp.MediaSource LEFT OUTER JOIN
                             (SELECT        DATEDIFF(m, MinDSDate, MaxDSDate) AS DateDiffCol, LTDPaymentRank, CustomerID
                               FROM            Archive.TGCplus_DS WITH (nolock)
                               WHERE        (DATEDIFF(m, MinDSDate, MaxDSDate) + 1 < LTDPaymentRank) AND (CurrentDS = 1)) AS CT ON CS.CustomerID = CT.CustomerID LEFT OUTER JOIN
                         Mapping.Country AS DMC WITH (nolock) ON AF.CountryCode = DMC.Alpha2Code
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
         Begin Table = "CS"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 135
               Right = 258
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "AF"
            Begin Extent = 
               Top = 6
               Left = 296
               Bottom = 135
               Right = 499
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Lkp"
            Begin Extent = 
               Top = 6
               Left = 537
               Bottom = 135
               Right = 764
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CT"
            Begin Extent = 
               Top = 6
               Left = 802
               Bottom = 118
               Right = 985
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "DMC"
            Begin Extent = 
               Top = 6
               Left = 1023
               Bottom = 135
               Right = 1204
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
End', 'SCHEMA', N'Archive', 'VIEW', N'vw_TB_AppsFlyerReport', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_DiagramPane2', N'
', 'SCHEMA', N'Archive', 'VIEW', N'vw_TB_AppsFlyerReport', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=2
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'Archive', 'VIEW', N'vw_TB_AppsFlyerReport', NULL, NULL
GO
