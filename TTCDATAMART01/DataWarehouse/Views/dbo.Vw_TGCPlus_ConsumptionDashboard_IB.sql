SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[Vw_TGCPlus_ConsumptionDashboard_IB]
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
                                                    Datawarehouse.Marketing.TGCplus_Consumption_Smry(nolock) b ON a.id = b.id LEFT JOIN
                                                    Datawarehouse.Archive.TGCPlus_Film(nolock) c ON b.vid = c.uuid LEFT JOIN
                                                    Datawarehouse.Mapping.DMCourse(nolock) CourseLkp ON c.course_id = CourseLkp.CourseID
                          WHERE        a.email NOT LIKE '%+%' AND a.email NOT LIKE '%plustest%' AND a.email NOT LIKE '%viewlift%' AND a.subscription_plan_id IN
                                                        (SELECT        id
                                                          FROM            datawarehouse.mapping.Vw_TGCPlus_ValidSubscriptionPlan) AND year(tstamp) >= 2016) AS Main LEFT JOIN
                             (SELECT        id, courseid, min(tstamp) mintstamp, DENSE_RANK() OVER (partition BY id
                               ORDER BY min(SeqNum) ASC) AS SeqNum_XCourseID
FROM            Marketing.TGCplus_Consumption_Smry
WHERE        year(tstamp) >= 2016
GROUP BY id, courseid) CourseAgg ON Main.ID = CourseAgg.id AND Main.courseid = CourseAgg.courseid LEFT JOIN
    (SELECT        Summary.id, FilmLkp.Genre, min(tstamp) mintstamp, DENSE_RANK() OVER (partition BY Summary.id
      ORDER BY min(SeqNum) ASC) AS SeqNum_XGenre
FROM            Marketing.TGCplus_Consumption_Smry(nolock) Summary LEFT JOIN
                         Archive.TGCPlus_Film(nolock) FilmLkp ON Summary.vid = FilmLkp.uuid
WHERE        year(tstamp) >= 2016
GROUP BY Summary.id, FilmLkp.genre) GenreAgg ON Main.ID = GenreAgg.ID AND Main.genre = GenreAgg.genre) Final
ORDER BY ID, SeqNum_XTime
GO
