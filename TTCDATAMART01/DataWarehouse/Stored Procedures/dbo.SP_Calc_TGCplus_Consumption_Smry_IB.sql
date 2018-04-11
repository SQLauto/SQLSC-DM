SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[SP_Calc_TGCplus_Consumption_Smry_IB] @FromDate date = null, @ToDate date = null
as
Begin

If @FromDate is null 
	Begin 
		Select @FromDate = cast(max(TSTAMP) as date) 
		from Datawarehouse.Marketing.TGCplus_Consumption_IB_Smry
		--set @FromDate = DATEADD(d,1,@FromDate)
		select @FromDate as 'MaxDate'
	End

If @Todate is null
	select @ToDate = cast(dateadd(day,1,getdate()) as date)

	
	select @FromDate as '@FromDate'
	select @ToDate as '@ToDate'

	select * into #TGCPlus_VideoEvents 
	from [Archive].TGCPlus_VideoEvents_2017 a
	where cast(tstamp as date) between @FromDate and @ToDate

	/*Clean up data*/
	Delete from #TGCPlus_VideoEvents
	where Pa = 'Ping' and Vpos = 0


	/*Delete data greater than @FromDate to force recalculation*/
	Delete from Datawarehouse.Marketing.TGCplus_Consumption_IB_Smry
	where cast(tstamp as date) between @FromDate and @ToDate

Insert into Datawarehouse.Marketing.TGCplus_Consumption_IB_Smry
		SELECT 
			u.UUID,
			U.ID,
			cast(V.TSTAMP as date) TSTAMP,
			datepart(Month,V.TSTAMP) as Month,
			datepart(Year,V.TSTAMP) as Year,
			datepart(Week,V.TSTAMP) as Week,
			 case when v.pfm = 'WEBSITE' and v.useragent like '%mobile%' then 'MobileWeb'			
						when v.pfm = 'WEBSITE' and v.useragent not like '%mobile%' then 'WebSite'
						--	when v.dp1 ='Fire OS' then 'Fire OS'
						--	when v.dp1='Standard Android OS' then 'Standard Android OS'
						else v.pfm
			end as Platform,
			case when v.dp1  like '%Chromecast%' or v.dp2  like '%Chromecast%' or v.dp3  like '%Chromecast%'   or v.dp4  like '%Chromecast%' 
				 or v.dp5  like '%Chromecast%' then 'Chromecast'
			end as Player,
			case when v.dp1  like '%audio%' or v.dp2  like '%audio%' or v.dp3  like '%audio%'   or v.dp4  like '%audio%' 
				 or v.dp5  like '%audio%'  then 1
				 else  0
			end as FlagAudio,
			case when  v.dp1  like '%offline%' or v.dp2  like '%offline%' or v.dp3  like '%offline%'   or v.dp4  like '%offline%' 
				 or v.dp5  like '%offline%' then 1
				else  0
			end as FlagOffline,
			case when  v.dp1  like '%0.0%' or v.dp2  like '%0.0%' or v.dp3  like '%0.0%'   or v.dp4  like '%0.0%' 
				 or v.dp5  like '%0.0%' then 0.0
				 when  v.dp1  like '%0.5%' or v.dp2  like '%0.5%' or v.dp3  like '%0.5%'   or v.dp4  like '%0.5%' 
				 or v.dp5  like '%0.5%' then 0.5
				 when  v.dp1  like '%0.75%' or v.dp2  like '%0.75%' or v.dp3  like '%0.75%'   or v.dp4  like '%0.75%' 
				 or v.dp5  like '%0.75%' then 0.75
				 when  v.dp1  like '%1.0%' or v.dp2  like '%1.0%' or v.dp3  like '%1.0%'   or v.dp4  like '%1.0%' 
				 or v.dp5  like '%1.0%' then 1.0
				 when  v.dp1  like '%1.25%' or v.dp2  like '%1.25%' or v.dp3  like '%1.25%'   or v.dp4  like '%1.25%' 
				 or v.dp5  like '%1.25%' then 1.25
				 when  v.dp1  like '%1.5%' or v.dp2  like '%1.5%' or v.dp3  like '%1.5%'   or v.dp4  like '%1.5%' 
				 or v.dp5  like '%1.5%' then 1.5
				 when  v.dp1  like '%2.0%' or v.dp2  like '%2.0%' or v.dp3  like '%2.0%'   or v.dp4  like '%2.0%' 
				 or v.dp5  like '%2.0%' then 2.0
			end as Speed,
			v.useragent,
			V.Vid,
			f.Course_id as courseid,
			F.Episode_Number as episodeNumber,
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
			convert(float,(sum(case when pa = 'PING' then 1 else 0 end)  * 30.0)/60) as StreamedMins,
			Min(v.tstamp) MinTstamp
		from DataWarehouse.Archive.TGCPlus_User U
		--join DataWarehouse.Archive.TGCPlus_VideoEvents V
		join #TGCPlus_VideoEvents V
		on U.uuid = V.Uid 
		left join DataWarehouse.Archive.TGCPlus_Film F
		on F.uuid=V.Vid
		where u.email not like '%+%'
		--and u.email not like '%plustest%' 
		--where cast(V.tstamp as date) >= @FromDate	--'8/1/2015'
	Group by u.UUID, U.ID,cast(V.TSTAMP as date),datepart(Month,V.TSTAMP),datepart(Year,V.TSTAMP),datepart(Week,V.TSTAMP), 
	v.pfm,v.useragent,V.Vid,f.Course_id,F.Episode_Number,F.Film_Type,F.RunTime,V.Countryisocode,V.cityname,V.subdivision1,V.subdivision1,timezone,uip,
	v.dp1,v.dp2,v.dp3,v.dp4,v.dp5
	End
 


GO
