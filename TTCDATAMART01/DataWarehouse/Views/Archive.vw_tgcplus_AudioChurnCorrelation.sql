SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE View [Archive].[vw_tgcplus_AudioChurnCorrelation] as
Select
FinalAgg.*,
AudioC.Platform, AudioC.TSTAMP, AudioC.SM
from
(
select 
CustomerID, IntlMD_Channel, IntlSubPaymentHandler, IntlSubDate, CustStatusFlag, LTDPaidAmt, DSMonthCancelled_New, DSDayCancelled 
from archive.Vw_TGCPlus_CustomerSignature 
where 
IntlSubType = 'MONTH' and IntlSubPlanName in ('Monthly Subscription','Monthly Subscription Original','Monthly Plan','Montlhy Subscription')
and IntlSubDate >= '2017-12-01' and IntlSubDate <= '2017-12-31'
) as FinalAgg 
left join
(
Select CustomerID, Platform, TSTAMP, 
sum(StreamedMins) SM
from
(
SELECT 		
	u.UUID,			
	U.CustomerID,		U.IntlSubPaymentHandler, U.IntlSubType,	
	u.EmailAddress,			
	V.TSTAMP,			
	 case when v.pfm = 'WEBSITE' and v.useragent like '%mobile%' then 'MobileWeb'			
				when v.pfm = 'WEBSITE' and v.useragent not like '%mobile%' then 'WebSite'
				else v.pfm
			end as Platform,	
	v.useragent,			
	V.Vid,			
	v.dp1,			
	v.dp2,			
	v.dp3,			
	v.dp4,			
	f.Course_id as courseid,			
	f.seriestitle as coursename,			
	F.Episode_Number as episodeNumber,			
	f.title as LectureName,		f.genre, 	
	convert(float,(sum(case when pa = 'PING' then 1 else 0 end)  * 30.0)/60) as StreamedMins,			
	F.Film_Type as FilmType,			
	F.RunTime as lectureRunTime,			
	V.Countryisocode as CountryCode,			
	V.cityname as city,			
	V.subdivision1 as State,			
	timezone,			
	sum(case when PA = 'Play' then 1 else 0 end) plays,			
	sum(case when PA = 'Ping' then 1 else 0 end) pings,			
	max(vpos) MaxVPOS,			
	uip,			
	Min(v.tstamp) MinTstamp,			
	--1 as SeqNum			
	0 as SeqNum,			
	null as Paid_SeqNum		

from marketing.TGCPlus_CustomerSignature (nolock) U				
join (select * from Archive.TGCPlus_VideoEvents (nolock) where tstamp >= '12/01/2017' and tstamp <= '01/31/2018' and pfm in ('ios')) V				
on U.uuid = V.Uid 				
left join DataWarehouse.Archive.TGCPlus_Film F				
on F.uuid=V.Vid				
where u.EmailAddress not like '%+%'				
and u.EmailAddress not like ('%plustest%')	
and v.pfm in ('iOS')
-- and v.dp3 like '%audio%'		
Group by u.UUID, U.CustomerID, U.IntlSubPaymentHandler, U.IntlSubType, u.EmailAddress,V.TSTAMP,				
v.pfm,v.useragent,V.Vid,v.dp1,v.dp2,v.dp3,v.dp4,f.Course_id,f.seriestitle,F.Episode_Number, f.title,F.Film_Type,f.genre, F.RunTime,V.Countryisocode,V.cityname,V.subdivision1,V.subdivision1,timezone,uip


union all

SELECT 		
	u.UUID,			
	U.CustomerID,	U.IntlSubPaymentHandler, U.IntlSubType, 		
	u.EmailAddress,			
	V.TSTAMP,			
	 case when v.pfm = 'WEBSITE' and v.useragent like '%mobile%' then 'MobileWeb'			
				when v.pfm = 'WEBSITE' and v.useragent not like '%mobile%' then 'WebSite'
				else v.pfm
			end as Platform,	
	v.useragent,			
	V.Vid,			
	v.dp1,			
	v.dp2,			
	v.dp3,			
	v.dp4,			
	f.Course_id as courseid,			
	f.seriestitle as coursename,			
	F.Episode_Number as episodeNumber,			
	f.title as LectureName,		f.genre, 	
	convert(float,(sum(case when pa = 'PING' then 1 else 0 end)  * 30.0)/60) as StreamedMins,			
	F.Film_Type as FilmType,			
	F.RunTime as lectureRunTime,			
	V.Countryisocode as CountryCode,			
	V.cityname as city,			
	V.subdivision1 as State,			
	timezone,			
	sum(case when PA = 'Play' then 1 else 0 end) plays,			
	sum(case when PA = 'Ping' then 1 else 0 end) pings,			
	max(vpos) MaxVPOS,			
	uip,			
	Min(v.tstamp) MinTstamp,			
	--1 as SeqNum			
	0 as SeqNum,			
	null as Paid_SeqNum		

from marketing.TGCPlus_CustomerSignature (nolock) U				
join (select * from Archive.TGCPlus_VideoEvents (nolock) where tstamp >= '12/01/2017' and tstamp <= '01/31/2018' and pfm in ('Android')) V				
on U.uuid = V.Uid 				
left join DataWarehouse.Archive.TGCPlus_Film F				
on F.uuid=V.Vid				
where u.EmailAddress not like '%+%'				
and u.EmailAddress not like ('%plustest%')	
and v.pfm in ('Android')
-- and v.dp3 like '%audio%'		
Group by u.UUID, U.CustomerID, U.IntlSubPaymentHandler, U.IntlSubType, u.EmailAddress,V.TSTAMP,				
v.pfm,v.useragent,V.Vid,v.dp1,v.dp2,v.dp3,v.dp4,f.Course_id,f.seriestitle,F.Episode_Number, f.title,F.Film_Type,f.genre, F.RunTime,V.Countryisocode,V.cityname,V.subdivision1,V.subdivision1,timezone,uip
) as agg
group by
CustomerID, Platform, TSTAMP
) as AudioC on FinalAgg.CustomerID = AudioC.CustomerID; 
GO
