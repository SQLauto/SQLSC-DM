SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [dbo].[SP_Calc_TGCplus_VideoEvents_Smry_TestAccts] @FromDate date = null, @ToDate date = null
as
Begin

If @FromDate is null 
	Begin 
		Select @FromDate = dateadd(day,-7,cast(max(TSTAMP) as date))
		from Datawarehouse.Marketing.TGCplus_VideoEvents_Smry_TestAccts
		--set @FromDate = DATEADD(d,1,@FromDate)
		select @FromDate as 'MaxDate'
	End

If @Todate is null
	select @ToDate = cast(dateadd(day,1,getdate()) as date)

	
	select @FromDate as '@FromDate'
	select @ToDate as '@ToDate'

	select a.* into #TGCPlus_VideoEvents 
	from Archive.TGCPlus_VideoEvents a join
		DataWarehouse.Archive.TGCPlus_User U on U.uuid = a.Uid 
	where cast(tstamp as date) between @FromDate and @ToDate
	and (u.email like '%+%'
	or u.email like '%plustest%'
	or u.email like '%plus+%')


	/*Clean up data*/
	Delete from #TGCPlus_VideoEvents
	where Pa = 'Ping' and Vpos = 0


	/*Delete data greater than @FromDate to force recalculation*/
	Delete from Datawarehouse.Marketing.TGCplus_VideoEvents_Smry_TestAccts
	where cast(tstamp as date) between @FromDate and @ToDate


	Insert into Datawarehouse.Marketing.TGCplus_VideoEvents_Smry_TestAccts
		SELECT 
			u.UUID,
			U.ID,
			cast(V.TSTAMP as date) TSTAMP,
			datepart(Month,V.TSTAMP) as Month,
			datepart(Year,V.TSTAMP) as Year,
			datepart(Week,V.TSTAMP) as Week,
			 case when v.pfm = 'WEBSITE' and v.useragent like '%mobile%' then 'MobileWeb'			
						when v.pfm = 'WEBSITE' and v.useragent not like '%mobile%' then 'WebSite'
						else v.pfm
					end as Platform,
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
			Min(v.tstamp) MinTstamp,
			1 as SeqNum
		from DataWarehouse.Archive.TGCPlus_User U
		--join DataWarehouse.Archive.TGCPlus_VideoEvents V
		join #TGCPlus_VideoEvents V
		on U.uuid = V.Uid 
		left join DataWarehouse.Archive.TGCPlus_Film F
		on F.uuid=V.Vid
		where u.email like '%+%'
		or u.email like '%plustest%'
		or u.email like '%plus+%'
		--where cast(V.tstamp as date) >= @FromDate	--'8/1/2015'
	Group by u.UUID, U.ID,cast(V.TSTAMP as date),datepart(Month,V.TSTAMP),datepart(Year,V.TSTAMP),datepart(Week,V.TSTAMP), 
	v.pfm,v.useragent,V.Vid,f.Course_id,F.Episode_Number,F.Film_Type,F.RunTime,V.Countryisocode,V.cityname,V.subdivision1,V.subdivision1,timezone,uip


	/*Update Sequence Number */

	 --update t
	 --set t.SeqNum = s.SeqNum
	 --from Datawarehouse.Marketing.TGCplus_VideoEvents_Smry_TestAccts_1  t
	 --	 join ( select uuid,id,MinTstamp,Vid,[platform],useragent,uip,
		--			rank ()over (partition by uuid,id order by  MinTstamp,Vid,[platform],useragent,uip )as RNK
		--			,isnull( lead(SeqNum) over (partition by uuid,id order by  MinTstamp,Vid,[platform],useragent,uip ) + rank ()over (partition by uuid,id order by  MinTstamp,Vid,[platform],useragent,uip )-1
		--					,Lag(SeqNum) over (partition by uuid,id order by  MinTstamp,Vid,[platform],useragent,uip ) + rank ()over (partition by uuid,id order by  MinTstamp,Vid,[platform],useragent,uip )-1
		--					)as SeqNum
		--				from Datawarehouse.Marketing.TGCplus_VideoEvents_Smry_TestAccts_1  
		--		) s
	 --on s.uuid= t.uuid and s.id = t.id and s.MinTstamp=t.MinTstamp and s.Vid= t.Vid 
	 --and s.[platform] = t.[platform] and s.useragent= t.useragent and s.uip=t.uip

		update t
		set t.SeqNum = s.SeqNum
		from Datawarehouse.Marketing.TGCplus_VideoEvents_Smry_TestAccts  t
			 join ( select uuid,id,MinTstamp,Vid,[platform],useragent,uip,
					rank ()over (partition by uuid,id order by  MinTstamp,Vid,[platform],useragent,uip )as RNK
					,isnull( lead(SeqNum) over (partition by uuid,id order by  MinTstamp,Vid,[platform],useragent,uip ) + rank ()over (partition by uuid,id order by  MinTstamp,Vid,[platform],useragent,uip )-1
							,Lag(SeqNum) over (partition by uuid,id order by  MinTstamp,Vid,[platform],useragent,uip ) + rank ()over (partition by uuid,id order by  MinTstamp,Vid,[platform],useragent,uip )-1
							)as SeqNum
						from Datawarehouse.Marketing.TGCplus_VideoEvents_Smry_TestAccts  
						--where cast(tstamp as date) >= @FromDate
				) s
		on s.uuid= t.uuid and s.id = t.id and s.MinTstamp=t.MinTstamp and s.Vid= t.Vid 
		and s.[platform] = t.[platform] and s.useragent= t.useragent and s.uip=t.uip
		where cast(t.tstamp as date) >= @FromDate


	 
End
GO
