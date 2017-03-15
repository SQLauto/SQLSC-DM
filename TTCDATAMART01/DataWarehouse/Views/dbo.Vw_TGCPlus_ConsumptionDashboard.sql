SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[Vw_TGCPlus_ConsumptionDashboard]
AS
SELECT        TOP 100 PERCENT
Final.*, 
CASE WHEN lag(episodenumber, 1, NULL) OVER (PARTITION BY ID
ORDER BY SeqNum_XTime) IS NULL THEN 0 WHEN episodeNumber = lag(episodeNumber, 1, NULL) OVER (PARTITION BY ID
ORDER BY SeqNum_XTime) THEN 0 WHEN lag(courseid, 1, NULL) OVER (partition BY ID, SeqNum_XCourseID
ORDER BY SeqNum_XTime) IS NULL THEN 0 WHEN lag(episodeNumber, 1, NULL) OVER (PARTITION BY ID
ORDER BY SeqNum_XTime) = episodeNumber - 1 AND courseid = lag(courseid, 1, NULL) OVER (PARTITION BY ID
ORDER BY SeqNum_XTime) THEN 0 ELSE 1 END AS Hop
FROM            (/* This query calculates the data on the course id. If a Course is viewed again, the rank is used again. It is not a true linear path*/ SELECT Main.id, email, joined, 
                                                    entitled_dt, seqnum, tstamp, Main.genre, Main.courseid, episodenumber, streamedMins, offer_name, subscribed_via_platform, registered_via_platform, 
                                                    platform, useragent, CourseName, ReleaseDate, Topic, SubTopic, LectureTitle, FilmType, city, state, Country, plays, pings, FirstStreamDate, 
                                                    TGCCustomerID, IntlCampaignName, IntlMD_Channel, IntlMD_PromotionType, IntlMD_Year, IntlSubDate, IntlSubWeek, IntlSubMonth, IntlSubYear, 
                                                    IntlSubPlanName, IntlSubType, IntlSubPaymentHandler, SubDate, SubWeek, SubMonth, SubYear, SubPlanID, SubPlanName, SubType, 
                                                    SubPaymentHandler, TransactionType, CustStatusFlag, PaidFlag, DSDayCancelled, DSMonthCancelled, DSDayDeferred, TGCCustFlag, 
                                                    TGCCustSegmentFcst, TGCCustSegmentFnl, Gender, Age, AgeBin, HouseHoldIncomeBin, EducationBin, Main.LectureRunTime, 
													ROW_NUMBER() OVER (PARTITION BY Main.ID ORDER BY SeqNum ASC) AS SeqNum_XTime, SeqNum_XCourseID, SeqNum_XGenre
FROM            (SELECT        a.id, a.email, b.SeqNum, a.joined, a.entitled_dt, a.offer_name, a.subscribed_via_platform, a.registered_via_platform, b.tstamp, b.platform, b.useragent, 
                                                    b.courseid, c.title AS course_title, b.episodeNumber, CourseLkp.CourseName, CourseLkp.ReleaseDate, CourseLkp.Topic, CourseLkp.SubTopic, 
                                                    c.Title AS LectureTitle, c.genre, b.FilmType, b.city, b.state, CASE WHEN Country.Country IS NULL THEN d .Country ELSE Country.Country END AS Country,
                                                     b.plays, b.pings, b.StreamedMins, b.MinTstamp AS FirstStreamDate, d .TGCCustomerID, d .IntlCampaignName, d .IntlMD_Channel, 
                                                    d .IntlMD_PromotionType, d .IntlMD_Year, d .IntlSubDate, d .IntlSubWeek, d .IntlSubMonth, d .IntlSubYear, d .IntlSubPlanName, d .IntlSubType, 
                                                    d .IntlSubPaymentHandler, d .SubDate, d .SubWeek, d .SubMonth, d .SubYear, d .SubPlanID, d .SubPlanName, d .SubType, d .SubPaymentHandler, 
                                                    d .TransactionType, d .CustStatusFlag, d .PaidFlag, d .DSDayCancelled, d .DSMonthCancelled, d .DSDayDeferred, d .TGCCustFlag, 
                                                    d .TGCCustSegmentFcst, d .TGCCustSegmentFnl, d .Gender, d .Age, d .AgeBin, d .HouseHoldIncomeBin, d .EducationBin, b.LectureRunTime
                          FROM            Datawarehouse.Archive.TGCPlus_User(nolock) a JOIN
                                                    Datawarehouse.Marketing.TGCPlus_CustomerSignature(nolock) d ON a.uuid = d .uuid LEFT JOIN
                                                    Datawarehouse.Mapping.Country(nolock) Country ON d .country = Country.Alpha2Code LEFT JOIN
                                                    Datawarehouse.Marketing.TGCplus_VideoEvents_Smry(nolock) b ON a.id = b.id LEFT JOIN
                                                    Datawarehouse.Archive.TGCPlus_Film(nolock) c ON b.vid = c.uuid LEFT JOIN
                                                    Datawarehouse.Mapping.DMCourse(nolock) CourseLkp ON c.course_id = CourseLkp.CourseID
                          WHERE        a.email NOT LIKE '%+%' AND a.email NOT LIKE '%plustest%' AND a.email NOT LIKE '%viewlift%' AND a.subscription_plan_id IN
                                                        (SELECT        id
                                                          FROM            datawarehouse.mapping.Vw_TGCPlus_ValidSubscriptionPlan) AND year(tstamp) = 2016) AS Main LEFT JOIN
                             (SELECT        id, courseid, min(tstamp) mintstamp, DENSE_RANK() OVER (partition BY id
                               ORDER BY min(SeqNum) ASC) AS SeqNum_XCourseID
FROM            Marketing.TGCplus_VideoEvents_Smry
WHERE        year(tstamp) = 2016
GROUP BY id, courseid) CourseAgg ON Main.ID = CourseAgg.id AND Main.courseid = CourseAgg.courseid LEFT JOIN
    (SELECT        Summary.id, FilmLkp.Genre, min(tstamp) mintstamp, DENSE_RANK() OVER (partition BY Summary.id
      ORDER BY min(SeqNum) ASC) AS SeqNum_XGenre
FROM            Marketing.TGCplus_VideoEvents_Smry(nolock) Summary LEFT JOIN
                         Archive.TGCPlus_Film(nolock) FilmLkp ON Summary.vid = FilmLkp.uuid
WHERE        year(tstamp) = 2016
GROUP BY Summary.id, FilmLkp.genre) GenreAgg ON Main.ID = GenreAgg.ID AND Main.genre = GenreAgg.genre) Final
ORDER BY ID, SeqNum_XTime
GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[13] 4[30] 2[38] 3) )"
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
         Top = -480
         Left = -1152
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
', 'SCHEMA', N'dbo', 'VIEW', N'Vw_TGCPlus_ConsumptionDashboard', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'Vw_TGCPlus_ConsumptionDashboard', NULL, NULL
GO
