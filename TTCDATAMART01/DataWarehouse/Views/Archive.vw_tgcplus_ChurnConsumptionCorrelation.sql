SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[vw_tgcplus_ChurnConsumptionCorrelation] as
Select 
DMC.*,
Consumption.tstamp, Consumption.Platform, Consumption.FlagAudio, Consumption.FlagOffline, Consumption.Speed, Consumption.useragent, Consumption.courseid,
Consumption.episodeNumber, Consumption.FilmType, Consumption.SeqNum, Consumption.CourseName, Consumption.LectureName, Consumption.genre, 
isnull(Consumption.Plays,0) Plays, isnull(Consumption.StreamedMins,0) StreamedMins
from
(
Select  
a.CustomerID, a.Uuid, a.EmailAddress, case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerType, 
a.IntlSubDate, a.IntlSubType, a.IntlSubPlanName, a.IntlSubPlanID, a.IntlSubPaymentHandler, a.IntlMD_Channel, a.IntlCampaignID, a.IntlCampaignName,
a.SubDate, a.SubType, a.SubPlanName, a.SubPlanID, a.SubPaymentHandler,
a.CustStatusFlag, a.PaidFlag, a.DSMonthCancelled_new, a.DSDayCancelled, a.LTDPaidAmt, a.IntlPaidAmt,
a.Reactivated, a.FreeTrialDays, a.country, a.ContinentName
from archive.Vw_TGCPlus_CustomerSignature (nolock) a
where Year(a.IntlSubDate) >= 2017
) DMC
	left join
		(
		select  
		b.id, 
		b.tstamp, b.Platform, b.FlagAudio, b.FlagOffline, b.Speed, b.useragent, b.courseid, b.episodeNumber, b.filmtype, b.SeqNum, Course.CourseName, Course.LectureName, Course.genre, 
sum(PLays) Plays, sum(StreamedMins) StreamedMins
from marketing.TGCplus_VideoEvents_Smry (nolock) b 
			left join (select distinct course_id, episode_number, seriestitle as CourseName, title as LectureName, genre from archive.tgcplus_film (nolock) where course_id is not null) Course on b.courseid = Course.course_id and b.episodeNumber = Course.episode_number
group by b.id, b.tstamp, b.platform, b.FlagAudio, b.FlagOffline, b.Speed, b.courseid, b.episodeNumber, b.FilmType, b.useragent, Course.CourseName, Course.LectureName, b.SeqNum, Course.genre
		) Consumption on DMC.CustomerID = Consumption.ID; 
GO
