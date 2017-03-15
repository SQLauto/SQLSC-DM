SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [dbo].[SP_Calc_TGCplus_VideoEvents_Smry] @FromDate date = null, @ToDate date = null
as
Begin

If @FromDate is null 
	Begin 
		Select @FromDate = cast(max(TSTAMP) as date) 
		from Datawarehouse.Marketing.TGCplus_VideoEvents_Smry
		--set @FromDate = DATEADD(d,1,@FromDate)
		select @FromDate as 'MaxDate'
	End

If @Todate is null
	select @ToDate = cast(dateadd(day,1,getdate()) as date)

	
	select @FromDate as '@FromDate'
	select @ToDate as '@ToDate'

	select * into #TGCPlus_VideoEvents 
	from Archive.TGCPlus_VideoEvents a
	where cast(tstamp as date) between @FromDate and @ToDate

	/*Clean up data*/
	Delete from #TGCPlus_VideoEvents
	where Pa = 'Ping' and Vpos = 0


	/*Delete data greater than @FromDate to force recalculation*/
	Delete from Datawarehouse.Marketing.TGCplus_VideoEvents_Smry
	where cast(tstamp as date) between @FromDate and @ToDate


	Insert into Datawarehouse.Marketing.TGCplus_VideoEvents_Smry
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
			--1 as SeqNum
			0 as SeqNum,
			null as Paid_SeqNum
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
	v.pfm,v.useragent,V.Vid,f.Course_id,F.Episode_Number,F.Film_Type,F.RunTime,V.Countryisocode,V.cityname,V.subdivision1,V.subdivision1,timezone,uip


	/*Update Sequence Number */

	 --update t
	 --set t.SeqNum = s.SeqNum
	 --from Datawarehouse.Marketing.TGCplus_VideoEvents_Smry_1  t
	 --	 join ( select uuid,id,MinTstamp,Vid,[platform],useragent,uip,
		--			rank ()over (partition by uuid,id order by  MinTstamp,Vid,[platform],useragent,uip )as RNK
		--			,isnull( lead(SeqNum) over (partition by uuid,id order by  MinTstamp,Vid,[platform],useragent,uip ) + rank ()over (partition by uuid,id order by  MinTstamp,Vid,[platform],useragent,uip )-1
		--					,Lag(SeqNum) over (partition by uuid,id order by  MinTstamp,Vid,[platform],useragent,uip ) + rank ()over (partition by uuid,id order by  MinTstamp,Vid,[platform],useragent,uip )-1
		--					)as SeqNum
		--				from Datawarehouse.Marketing.TGCplus_VideoEvents_Smry_1  
		--		) s
	 --on s.uuid= t.uuid and s.id = t.id and s.MinTstamp=t.MinTstamp and s.Vid= t.Vid 
	 --and s.[platform] = t.[platform] and s.useragent= t.useragent and s.uip=t.uip

		--update t
		--set t.SeqNum = s.SeqNum
		--from Datawarehouse.Marketing.TGCplus_VideoEvents_Smry  t
		--	 join ( select uuid,id,MinTstamp,Vid,[platform],useragent,uip,
		--			rank ()over (partition by uuid,id order by  MinTstamp,Vid,[platform],useragent,uip )as RNK
		--			,isnull( lead(SeqNum) over (partition by uuid,id order by  MinTstamp,Vid,[platform],useragent,uip ) + rank ()over (partition by uuid,id order by  MinTstamp,Vid,[platform],useragent,uip )-1
		--					,Lag(SeqNum) over (partition by uuid,id order by MinTstamp,Vid,[platform],useragent,uip ) + rank ()over (partition by uuid,id order by  MinTstamp,Vid,[platform],useragent,uip )-1
		--					)as SeqNum
		--				from Datawarehouse.Marketing.TGCplus_VideoEvents_Smry  
		--				--where cast(tstamp as date) >= @FromDate
		--		) s
		--on s.uuid= t.uuid and s.id = t.id and s.MinTstamp=t.MinTstamp and s.Vid= t.Vid 
		--and s.[platform] = t.[platform] and s.useragent= t.useragent and s.uip=t.uip
		--where cast(t.tstamp as date) >= @FromDate

		--update t
		--set t.SeqNum = s.SeqNum
		--from Datawarehouse.Marketing.TGCplus_VideoEvents_Smry  t
		--	 join ( select uuid,id,MinTstamp,
		--			rank ()over (partition by uuid,id order by  MinTstamp )as RNK
		--			,isnull( lead(SeqNum) over (partition by uuid,id order by  MinTstamp ) + rank ()over (partition by uuid,id order by  MinTstamp)
		--					,Lag(SeqNum) over (partition by uuid,id order by  MinTstamp ) + rank ()over (partition by uuid,id order by  MinTstamp)
		--					)as SeqNum
		--				from Datawarehouse.Marketing.TGCplus_VideoEvents_Smry 
		--	) s
		--on s.uuid= t.uuid and s.id = t.id and s.MinTstamp=t.MinTstamp 
		--where t.SeqNum = 0
/*********************************************************SeqNum and Paid_SeqNum Calc*********************************************************************/
/*Code change to calc Seq Num*/

		update t
		set t.SeqNum = s.RNK
		from Datawarehouse.Marketing.TGCplus_VideoEvents_Smry  t
			 join ( select uuid,id,MinTstamp,
					Row_number ()over (partition by uuid,id order by  MinTstamp )as RNK
					--,isnull( lead(SeqNum) over (partition by uuid,id order by  MinTstamp ) + Row_number ()over (partition by uuid,id order by  MinTstamp)
					--		,Lag(SeqNum) over (partition by uuid,id order by  MinTstamp ) + Row_number ()over (partition by uuid,id order by  MinTstamp)
					--		)as SeqNum
						from Datawarehouse.Marketing.TGCplus_VideoEvents_Smry
						where id in (select id 
									from Datawarehouse.Marketing.TGCplus_VideoEvents_Smry 
									where SeqNum = 0
									group by id) 

			) s
		on s.uuid= t.uuid and s.id = t.id and s.MinTstamp=t.MinTstamp 
		where t.SeqNum = 0

/* First Paid Date from UserBilling table*/
	 select user_id as id,min(ub.completed_at) mincompleted_at
	 into #Userbilling
	 from DataWarehouse.Archive.TGCPlus_UserBilling ub
	 where ub.pre_tax_amount > 0
	 group by user_id

--alter table Datawarehouse.Marketing.TGCplus_VideoEvents_Smry add Paid_SeqNum int
	update t
	set Paid_SeqNum = 0 
	from Datawarehouse.Marketing.TGCplus_VideoEvents_Smry t
	join #Userbilling ub
	on t.id = ub.id and t.MinTstamp>= ub.mincompleted_at
	where t.Paid_SeqNum is null

	update t
	set t.Paid_SeqNum = s.RNK
	from Datawarehouse.Marketing.TGCplus_VideoEvents_Smry  t
			join ( select uuid,id,MinTstamp,
				Row_number ()over (partition by uuid,id order by  MinTstamp )as RNK
					from Datawarehouse.Marketing.TGCplus_VideoEvents_Smry
					where Paid_SeqNum >=0
					and id in (select id 
								from Datawarehouse.Marketing.TGCplus_VideoEvents_Smry 
								where Paid_SeqNum = 0
								group by id) 
		) s
	on s.uuid= t.uuid and s.id = t.id and s.MinTstamp=t.MinTstamp 
	where t.Paid_SeqNum = 0

End

 
GO
