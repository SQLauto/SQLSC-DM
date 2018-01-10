SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[Vw_TGCPlus_TableauConsumptionData]
AS
SELECT        a.id, a.email, a.joined, a.entitled_dt, a.offer_name, a.subscribed_via_platform, a.registered_via_platform, b.TSTAMP, b.flag_padded, b.Platform, b.useragent, 
                         Staging.RemoveDigits(b.useragent) AS Browser, b.courseid, c.title AS course_title, b.episodeNumber, b.lectureRunTime, CourseLkp.CourseName, 
                         CourseLkp.ReleaseDate, CourseLkp.Topic, CourseLkp.SubTopic, CourseLkp.PrimaryWebCategory, CourseLkp.PrimaryWebSubcategory, c.title AS LectureTitle, 
                         c.genre, b.FilmType, b.city, b.State, CASE WHEN Country.Country IS NULL THEN d .Country ELSE Country.Country END AS Country, b.plays, b.pings, 
                         b.StreamedMins, CASE WHEN b.Plays > 0 AND b.StreamedMins = 0 THEN 'Extreme2' WHEN CAST(b.tstamp AS date) 
                         < d .IntlSubDate THEN 'Extreme3' WHEN b.StreamedMins > (b.lectureRunTime / 60) * 1.5 THEN 'Extreme1' ELSE 'Regular' END AS ExtremeIndicator, 
                         b.MinTstamp AS FirstStreamDate, d.TGCCustomerID, d.IntlCampaignName, d.IntlMD_Audience, d.IntlMD_Channel, d.IntlMD_PromotionType, d.IntlMD_Year, 
                         d.IntlSubDate, d.IntlSubWeek, d.IntlSubMonth, d.IntlSubYear, d.IntlSubPlanName, d.IntlSubType, d.IntlSubPaymentHandler, d.SubDate, d.SubWeek, d.SubMonth, 
                         d.SubYear, d.SubPlanID, d.SubPlanName, d.SubType, d.SubPaymentHandler, d.TransactionType, d.CustStatusFlag, d.PaidFlag, d.LTDPaidAmt, d.LastPaidDate, 
                         d.LastPaidWeek, d.LastPaidMonth, d.LastPaidYear, d.LastPaidAmt, d.DSDayCancelled, d.DSMonthCancelled_New, d.DSDayDeferred, d.TGCCustFlag, 
                         d.TGCCustSegmentFcst, d.TGCCustSegmentFnl, d.Gender, d.Age, d.AgeBin, d.HouseHoldIncomeBin, d.EducationBin
FROM            Archive.TGCPlus_User AS a WITH (nolock) INNER JOIN
                         Archive.Vw_TGCPlus_CustomerSignature AS d WITH (nolock) ON a.uuid = d.uuid LEFT OUTER JOIN
                         Mapping.Country AS Country WITH (nolock) ON d.country = Country.Alpha2Code LEFT OUTER JOIN
                         dbo.VW_TGCplus_VideoEvents_Smry_Tableau AS b WITH (nolock) ON a.id = b.ID LEFT OUTER JOIN
                         Archive.TGCPlus_Film AS c WITH (nolock) ON b.Vid = c.uuid LEFT OUTER JOIN
                         Staging.Vw_DMCourse AS CourseLkp WITH (nolock) ON c.course_id = CourseLkp.CourseID
WHERE        (a.email NOT LIKE '%+%') AND (a.email NOT LIKE '%plustest%') AND (a.email NOT LIKE '%viewlift%') AND (a.email NOT LIKE '%snagfilms%') AND 
                         (a.email NOT LIKE '%incedoinc.com%') AND (a.subscription_plan_id IN
                             (SELECT        id
                               FROM            Mapping.Vw_TGCPlus_ValidSubscriptionPlan)) AND (ISNULL(b.uip, '') NOT IN ('207.239.38.226', '10.11.244.209')) AND (YEAR(b.TSTAMP) >= 2016)
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
               Top = 6
               Left = 38
               Bottom = 135
               Right = 275
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Country"
            Begin Extent = 
               Top = 270
               Left = 38
               Bottom = 399
               Right = 219
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "b"
            Begin Extent = 
               Top = 138
               Left = 300
               Bottom = 267
               Right = 474
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "c"
            Begin Extent = 
               Top = 402
               Left = 38
               Bottom = 531
               Right = 275
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CourseLkp"
            Begin Extent = 
               Top = 534
               Left = 38
               Bottom = 663
               Right = 273
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "d"
            Begin Extent = 
               Top = 6
               Left = 313
               Bottom = 135
               Right = 537
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
         Table =', 'SCHEMA', N'Archive', 'VIEW', N'Vw_TGCPlus_TableauConsumptionData', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_DiagramPane2', N' 1170
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
', 'SCHEMA', N'Archive', 'VIEW', N'Vw_TGCPlus_TableauConsumptionData', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=2
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'Archive', 'VIEW', N'Vw_TGCPlus_TableauConsumptionData', NULL, NULL
GO
