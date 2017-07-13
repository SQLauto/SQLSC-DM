SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[VW_PlusConsumption_PD] 
as
select 
a.id, 
b.courseid, 
c.title as course_title,
b.episodeNumber, b.LectureRunTime, 
CourseLkp.CourseName, CourseLkp.ReleaseDate, CourseLkp.Topic, CourseLkp.SubTopic, CourseLkp.PrimaryWebCategory, CourseLkp.PrimaryWebSubcategory, 
c.Title as LectureTitle, 
c.genre, 
b.FilmType,
d.TGCCustomerID, d.IntlSubType, d.IntlSubPaymentHandler, 
d.CustStatusFlag, d.PaidFlag, 
d.DSDayCancelled, d.DSMonthCancelled, d.Gender, d.Age, d.AgeBin, d.HouseHoldIncomeBin, d.EducationBin,
sum(b.plays) as plays,
sum(b.StreamedMins) as StreamedMins
from Datawarehouse.Archive.TGCPlus_User (nolock) a
	JOIN Datawarehouse.Marketing.TGCPlus_CustomerSignature (nolock) d on a.uuid = d.uuid 
	LEFT JOIN Datawarehouse.Mapping.Country (nolock) Country on d.country = Country.Alpha2Code
	LEFT JOIN VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.id = b.id 
	LEFT JOIN Datawarehouse.Archive.TGCPlus_Film (nolock) c on b.vid = c.uuid 
	LEFT JOIN Datawarehouse.Staging.vw_DMCourse (nolock) CourseLkp on c.course_id = CourseLkp.CourseID
where a.email not like '%+%'and a.email not like '%plustest%' and a.email not like '%viewlift%' and a.email not like '%snagfilms%' and a.email not like '%incedoinc.com%' and 
a.subscription_plan_id in (select id from datawarehouse.mapping.Vw_TGCPlus_ValidSubscriptionPlan) and
isnull(b.uip,'') NOT IN ('207.239.38.226', '10.11.244.209')
and year(b.tstamp) >= year(GetDate())
group by
a.id, 
b.courseid, 
c.title,
b.episodeNumber, b.LectureRunTime, 
CourseLkp.CourseName, CourseLkp.ReleaseDate, CourseLkp.Topic, CourseLkp.SubTopic, CourseLkp.PrimaryWebCategory, CourseLkp.PrimaryWebSubcategory, 
c.Title, 
c.genre, 
b.FilmType,
d.TGCCustomerID, d.IntlSubType, d.IntlSubPaymentHandler, 
d.CustStatusFlag, d.PaidFlag, 
d.DSDayCancelled, d.DSMonthCancelled, d.Gender, d.Age, d.AgeBin, d.HouseHoldIncomeBin, d.EducationBin
GO
