SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[VW_CourseNetworkDiagram_IB]
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
                                                                              Datawarehouse.Marketing.TGCplus_Consumption_Smry(nolock) b ON a.id = b.id LEFT JOIN
                                                                              Datawarehouse.Archive.TGCPlus_Film(nolock) c ON b.vid = c.uuid LEFT JOIN
                                                                              Datawarehouse.Mapping.DMCourse(nolock) CourseLkp ON c.course_id = CourseLkp.CourseID
                                                    WHERE        a.email NOT LIKE '%+%' AND a.email NOT LIKE '%plustest%' AND a.email NOT LIKE '%viewlift%' AND a.subscription_plan_id IN
                                                                                  (SELECT        id
                                                                                    FROM            datawarehouse.mapping.Vw_TGCPlus_ValidSubscriptionPlan) AND year(tstamp) = 2016) AS Main LEFT JOIN
                                                        (SELECT        id, courseid, min(tstamp) mintstamp, DENSE_RANK() OVER (partition BY id
                                                          ORDER BY min(SeqNum) ASC) AS SeqNum_XCourseID
                          FROM            Marketing.TGCplus_Consumption_Smry
                          WHERE        year(tstamp) = 2016
                          GROUP BY id, courseid) CourseAgg ON Main.ID = CourseAgg.id AND Main.courseid = CourseAgg.courseid LEFT JOIN
                             (SELECT        Summary.id, FilmLkp.Genre, min(tstamp) mintstamp, DENSE_RANK() OVER (partition BY Summary.id
                               ORDER BY min(SeqNum) ASC) AS SeqNum_XGenre
FROM            Marketing.TGCplus_Consumption_Smry(nolock) Summary LEFT JOIN
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
                                                          Datawarehouse.Marketing.TGCplus_Consumption_Smry(nolock) b ON a.id = b.id LEFT JOIN
                                                          Datawarehouse.Archive.TGCPlus_Film(nolock) c ON b.vid = c.uuid LEFT JOIN
                                                          Datawarehouse.Mapping.DMCourse(nolock) CourseLkp ON c.course_id = CourseLkp.CourseID
                                WHERE        a.email NOT LIKE '%+%' AND a.email NOT LIKE '%plustest%' AND a.email NOT LIKE '%viewlift%' AND a.subscription_plan_id IN
                                                              (SELECT        id
                                                                FROM            datawarehouse.mapping.Vw_TGCPlus_ValidSubscriptionPlan) AND year(tstamp) = 2016) AS Main LEFT JOIN
                                    (SELECT        id, courseid, min(tstamp) mintstamp, DENSE_RANK() OVER (partition BY id
                                      ORDER BY min(SeqNum) ASC) AS SeqNum_XCourseID
      FROM            Marketing.TGCplus_Consumption_Smry
      WHERE        year(tstamp) = 2016
      GROUP BY id, courseid) CourseAgg ON Main.ID = CourseAgg.id AND Main.courseid = CourseAgg.courseid LEFT JOIN
    (SELECT        Summary.id, FilmLkp.Genre, min(tstamp) mintstamp, DENSE_RANK() OVER (partition BY Summary.id
      ORDER BY min(SeqNum) ASC) AS SeqNum_XGenre
FROM            Marketing.TGCplus_Consumption_Smry(nolock) Summary LEFT JOIN
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
