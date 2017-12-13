SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE View [Archive].[Vw_TGCPlus_TableauConsumptionData]
as

		select 
			a.id, a.email, 
			a.joined, 
			a.entitled_dt, a.offer_name, 
			a.subscribed_via_platform,
			a.registered_via_platform,
			b.tstamp, b.flag_padded, 
			b.platform,
			b.useragent,
			datawarehouse.Staging.RemoveDigits(b.useragent) as Browser, 
			b.courseid, 
			c.title as course_title,
			b.episodeNumber, b.LectureRunTime, 
			CourseLkp.CourseName, CourseLkp.ReleaseDate, CourseLkp.Topic, CourseLkp.SubTopic, CourseLkp.PrimaryWebCategory, CourseLkp.PrimaryWebSubcategory, 
			c.Title as LectureTitle, 
			c.genre, 
			b.FilmType,
			 b.city, b.state, 
			Case	
				when Country.Country is null then d.Country else Country.Country end as Country, 
			b.plays,
			b.pings,
			b.StreamedMins, 
			case
			   when b.Plays > 0 and b.StreamedMins = 0 then 'Extreme2' 
			   when cast(b.tstamp as date) < d.IntlSubDate then 'Extreme3' 
			   when b.StreamedMins > (b.lectureRunTime/60) * 1.5 then 'Extreme1'
			else 'Regular' end as ExtremeIndicator,
			b.MinTstamp as FirstStreamDate,
			d.TGCCustomerID, d.IntlCampaignName, d.IntlMD_Audience, d.IntlMD_Channel, 
			d.IntlMD_PromotionType, d.IntlMD_Year, d.IntlSubDate, d.IntlSubWeek, d.IntlSubMonth, d.IntlSubYear, 
			d.IntlSubPlanName, d.IntlSubType, d.IntlSubPaymentHandler, d.SubDate, d.SubWeek, d.SubMonth, d.SubYear, d.SubPlanID, d.SubPlanName, d.SubType, d.SubPaymentHandler,
			d.TransactionType, d.CustStatusFlag, d.PaidFlag, d.LTDPaidAmt, d.LastPaidDate, d.LastPaidWeek, d.LastPaidMonth, d.LastPaidYear, d.LastPaidAmt,
			d.DSDayCancelled, d.DSMonthCancelled, d.DSDayDeferred, d.TGCCustFlag, d.TGCCustSegmentFcst, d.TGCCustSegmentFnl, d.Gender, d.Age, d.AgeBin, d.HouseHoldIncomeBin, d.EducationBin
		from Datawarehouse.Archive.TGCPlus_User (nolock) a
			JOIN Datawarehouse.Marketing.TGCPlus_CustomerSignature (nolock) d on a.uuid = d.uuid 
			LEFT JOIN Datawarehouse.Mapping.Country (nolock) Country on d.country = Country.Alpha2Code
			LEFT JOIN VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.id = b.id 
			LEFT JOIN Datawarehouse.Archive.TGCPlus_Film (nolock) c on b.vid = c.uuid 
			LEFT JOIN Datawarehouse.Staging.vw_DMCourse (nolock) CourseLkp on c.course_id = CourseLkp.CourseID
		where a.email not like '%+%'and a.email not like '%plustest%' and a.email not like '%viewlift%' and a.email not like '%snagfilms%' and a.email not like '%incedoinc.com%' and 
		a.subscription_plan_id in (select id from datawarehouse.mapping.Vw_TGCPlus_ValidSubscriptionPlan) and
		isnull(b.uip,'') NOT IN ('207.239.38.226', '10.11.244.209')
		and year(b.tstamp) >= 2016





GO
