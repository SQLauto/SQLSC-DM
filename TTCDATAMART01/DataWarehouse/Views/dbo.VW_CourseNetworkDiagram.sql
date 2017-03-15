SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[VW_CourseNetworkDiagram]
AS
Select
GenreFirst, GenreSecond, TopicFirst, TopicSecond,
CourseidFirst, CourseNameFirst, CourseidSecond, CourseNameSecond,
count(distinct id) as Users, 
sum(SM_First) as SM_First, sum(SM_Second) as SM_Second,
sum(Plays_First) as Plays_First, sum(Plays_Second) as Plays_Second
from
(
SELECT        TOP 100 PERCENT Initial.id, Initial.TGCCustFlag, Initial.GenreFirst, Second.GenreSecond, Initial.TopicFirst, Second.TopicSecond, Initial.CourseidFirst, 
                         Second.CourseidSecond, Initial.CourseNameFirst, Second.CourseNameSecond, Initial.SM_First, Second.SM_Second, Initial.Plays_First, Second.Plays_Second, 
                         Row_Number() OVER (ORDER BY Initial.id) AS c_number, sum(1) OVER (partition BY initial.id) AS c_max_number
FROM            (SELECT        Main.id, Main.genre AS GenreFirst, Main.courseid AS CourseidFirst, sum(streamedMins) AS SM_First, CourseName AS CourseNameFirst, 
                                                    Topic AS TopicFirst, sum(plays) AS Plays_First, TGCCustFlag, SeqNum_XCourseID AS CourseFirst
                          FROM            (SELECT        a.id, a.email, b.SeqNum, a.joined, a.entitled_dt, a.offer_name, a.subscribed_via_platform, a.registered_via_platform, b.tstamp, b.platform, 
                                                                              b.useragent, b.courseid, c.title AS course_title, b.episodeNumber, CourseLkp.CourseName, CourseLkp.ReleaseDate, CourseLkp.Topic, 
                                                                              CourseLkp.SubTopic, c.Title AS LectureTitle, c.genre, b.FilmType, b.city, b.state, CASE WHEN Country.Country IS NULL 
                                                                              THEN d .Country ELSE Country.Country END AS Country, b.plays, b.pings, b.StreamedMins, b.MinTstamp AS FirstStreamDate, 
                                                                              d .TGCCustomerID, d .IntlCampaignName, d .IntlMD_Channel, d .IntlMD_PromotionType, d .IntlMD_Year, d .IntlSubDate, d .IntlSubWeek, 
                                                                              d .IntlSubMonth, d .IntlSubYear, d .IntlSubPlanName, d .IntlSubType, d .IntlSubPaymentHandler, d .SubDate, d .SubWeek, d .SubMonth, 
                                                                              d .SubYear, d .SubPlanID, d .SubPlanName, d .SubType, d .SubPaymentHandler, d .TransactionType, d .CustStatusFlag, d .PaidFlag, 
                                                                              d .DSDayCancelled, d .DSMonthCancelled, d .DSDayDeferred, d .TGCCustFlag, d .TGCCustSegmentFcst, d .TGCCustSegmentFnl, d .Gender, 
                                                                              d .Age, d .AgeBin, d .HouseHoldIncomeBin, d .EducationBin
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
GROUP BY Summary.id, FilmLkp.genre) GenreAgg ON Main.ID = GenreAgg.ID AND Main.genre = GenreAgg.genre
WHERE        Main.FilmType = 'Episode' AND CourseAgg.SeqNum_XCourseID = 1
GROUP BY Main.id, Main.genre, Main.courseid, CourseName, Topic, TGCCustFlag, SeqNum_XCourseID) AS Initial LEFT JOIN
    (SELECT        Main.id, Main.genre AS GenreSecond, Main.courseid AS CourseidSecond, sum(streamedMins) AS SM_Second, CourseName AS CourseNameSecond, 
                                Topic AS TopicSecond, sum(plays) AS Plays_Second, SeqNum_XCourseID AS CourseSecond
      FROM            (SELECT        a.id, a.email, b.SeqNum, a.joined, a.entitled_dt, a.offer_name, a.subscribed_via_platform, a.registered_via_platform, b.tstamp, b.platform, 
                                                          b.useragent, b.courseid, c.title AS course_title, b.episodeNumber, CourseLkp.CourseName, CourseLkp.ReleaseDate, CourseLkp.Topic, 
                                                          CourseLkp.SubTopic, c.Title AS LectureTitle, c.genre, b.FilmType, b.city, b.state, CASE WHEN Country.Country IS NULL 
                                                          THEN d .Country ELSE Country.Country END AS Country, b.plays, b.pings, b.StreamedMins, b.MinTstamp AS FirstStreamDate, d .TGCCustomerID, 
                                                          d .IntlCampaignName, d .IntlMD_Channel, d .IntlMD_PromotionType, d .IntlMD_Year, d .IntlSubDate, d .IntlSubWeek, d .IntlSubMonth, d .IntlSubYear, 
                                                          d .IntlSubPlanName, d .IntlSubType, d .IntlSubPaymentHandler, d .SubDate, d .SubWeek, d .SubMonth, d .SubYear, d .SubPlanID, d .SubPlanName, 
                                                          d .SubType, d .SubPaymentHandler, d .TransactionType, d .CustStatusFlag, d .PaidFlag, d .DSDayCancelled, d .DSMonthCancelled, d .DSDayDeferred,
                                                           d .TGCCustFlag, d .TGCCustSegmentFcst, d .TGCCustSegmentFnl, d .Gender, d .Age, d .AgeBin, d .HouseHoldIncomeBin, d .EducationBin
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
GROUP BY Summary.id, FilmLkp.genre) GenreAgg ON Main.ID = GenreAgg.ID AND Main.genre = GenreAgg.genre
WHERE        Main.FilmType = 'Episode' AND CourseAgg.SeqNum_XCourseID = 2
GROUP BY Main.id, Main.genre, Main.courseid, CourseName, Topic, TGCCustFlag, SeqNum_XCourseID) AS Second ON Initial.ID = Second.ID
) as FinalAgg
where TGCCustFlag in (0, 1)
group by 
GenreFirst, GenreSecond, TopicFirst, TopicSecond,
CourseidFirst, CourseNameFirst, CourseidSecond, CourseNameSecond
GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[15] 4[26] 2[42] 3) )"
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
', 'SCHEMA', N'dbo', 'VIEW', N'VW_CourseNetworkDiagram', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'VW_CourseNetworkDiagram', NULL, NULL
GO
