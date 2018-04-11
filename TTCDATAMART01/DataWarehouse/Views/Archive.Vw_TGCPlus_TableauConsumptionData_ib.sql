SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[Vw_TGCPlus_TableauConsumptionData_ib]
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
                         dbo.VW_TGCplus_videoEvents_Smry_Tableau_IB AS b WITH (nolock) ON a.id = b.ID LEFT OUTER JOIN
                         Archive.TGCPlus_Film AS c WITH (nolock) ON b.Vid = c.uuid LEFT OUTER JOIN
                         Staging.Vw_DMCourse AS CourseLkp WITH (nolock) ON c.course_id = CourseLkp.CourseID
WHERE        (a.email NOT LIKE '%+%') AND (a.email NOT LIKE '%plustest%') AND (a.email NOT LIKE '%viewlift%') AND (a.email NOT LIKE '%snagfilms%') AND 
                         (a.email NOT LIKE '%incedoinc.com%') AND (a.subscription_plan_id IN
                             (SELECT        id
                               FROM            Mapping.Vw_TGCPlus_ValidSubscriptionPlan)) AND (ISNULL(b.uip, '') NOT IN ('207.239.38.226', '10.11.244.209')) AND (YEAR(b.TSTAMP) >= 2016)

GO
