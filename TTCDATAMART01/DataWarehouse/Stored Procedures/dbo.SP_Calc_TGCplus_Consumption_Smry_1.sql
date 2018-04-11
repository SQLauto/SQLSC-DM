SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Proc [dbo].[SP_Calc_TGCplus_Consumption_Smry_1] @FromDate date = null, @ToDate date = null
as
Begin

If @FromDate is null 
	Begin 
		Select @FromDate = cast(max(TSTAMP) as date) 
		from Datawarehouse.Marketing.TGCplus_Consumption_Smry_1
		--set @FromDate = DATEADD(d,1,@FromDate)
		select @FromDate as 'MaxDate'
	End

If @Todate is null
	select @ToDate = cast(dateadd(day,1,getdate()) as date)

	
	select @FromDate as '@FromDate',@ToDate as '@ToDate'
	--select @ToDate as '@ToDate'

	select * into #TGCPlus_VideoEvents 
	from [Archive].TGCPlus_VideoEvents_2016 a
	where cast(tstamp as date) between @FromDate and @ToDate

	/*Clean up data*/
	Delete from #TGCPlus_VideoEvents
	where Pa = 'Ping' and Vpos = 0


	/*Delete data greater than @FromDate to force recalculation*/
	Delete from Datawarehouse.Marketing.TGCplus_Consumption_Smry_1
	where cast(tstamp as date) between @FromDate and @ToDate


		/*get Customer IntlPaidDate */

	/*select customerid,IntlPaidDate into #paidCustomers
	from DataWarehouse.Marketing.TGCPlus_CustomerSignature */


	select user_id as id, min(ub.completed_at)  mincompleted_at
	 into #paidtime
	 from DataWarehouse.Archive.TGCPlus_UserBilling ub
	 where ub.pre_tax_amount > 0
	 group by user_id

Print'Inserting into summary table'
Insert into Datawarehouse.Marketing.TGCplus_Consumption_Smry_1
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
				 when v.dp1  like '%Android%' or v.dp2  like '%Android%' or v.dp3  like '%Android%'   or v.dp4  like '%Android%' 
				 or v.dp5  like '%Android%' then 'Android OS'
				  when v.dp1  like '%Fire%' or v.dp2  like '%Fire%' or v.dp3  like '%Fire%'   or v.dp4  like '%Fire%' 
				 or v.dp5  like '%Fire%' then 'Fire OS'
				 when v.dp1  like '%Alexa%' or v.dp2  like '%Alexa%' or v.dp3  like '%Alexa%'   or v.dp4  like '%Alexa%' 
				 or v.dp5  like '%Alexa%' then 'Alexa'
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
				 or v.dp5  like '%0.0%' then '0.0'
				 when  v.dp1  like '%0.5%' or v.dp2  like '%0.5%' or v.dp3  like '%0.5%'   or v.dp4  like '%0.5%' 
				 or v.dp5  like '%0.5%' then '0.5'
				 when  v.dp1  like '%0.75%' or v.dp2  like '%0.75%' or v.dp3  like '%0.75%'   or v.dp4  like '%0.75%' 
				 or v.dp5  like '%0.75%' then '0.75'
				 when  v.dp1  like '%1.0%' or v.dp2  like '%1.0%' or v.dp3  like '%1.0%'   or v.dp4  like '%1.0%' 
				 or v.dp5  like '%1.0%' then '1.0'
				 when  v.dp1  like '%1.25%' or v.dp2  like '%1.25%' or v.dp3  like '%1.25%'   or v.dp4  like '%1.25%' 
				 or v.dp5  like '%1.25%' then '1.25'
				 when  v.dp1  like '%1.5%' or v.dp2  like '%1.5%' or v.dp3  like '%1.5%'   or v.dp4  like '%1.5%' 
				 or v.dp5  like '%1.5%' then '1.5'
				 when  v.dp1  like '%2.0%' or v.dp2  like '%2.0%' or v.dp3  like '%2.0%'   or v.dp4  like '%2.0%' 
				 or v.dp5  like '%2.0%' then '2.0'
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
			Min(v.tstamp) MinTstamp,
				--1 as SeqNum
				0 as SeqNum,
			null as Paid_SeqNum,
			case when v.tstamp >= paid.mincompleted_at  then 1
			else 0
			end as PaidFlag,
			getdate() as DMLastUpdated
			
		from DataWarehouse.Archive.TGCPlus_User U
			left join #paidtime paid on
		paid.id=u.id
		--join DataWarehouse.Archive.TGCPlus_VideoEvents V
		join #TGCPlus_VideoEvents V
		on U.uuid = V.Uid 
		left join DataWarehouse.Archive.TGCPlus_Film F
		on F.uuid=V.Vid
		where u.email not like '%+%'
		and u.email not like '%plustest%' 
		--and cast(V.tstamp as date) >= @FromDate	--'8/1/2015'
	Group by 	u.UUID,
			U.ID,
			cast(V.TSTAMP as date),
			datepart(Month,V.TSTAMP),
			datepart(Year,V.TSTAMP),
			datepart(Week,V.TSTAMP),
			 case when v.pfm = 'WEBSITE' and v.useragent like '%mobile%' then 'MobileWeb'			
						when v.pfm = 'WEBSITE' and v.useragent not like '%mobile%' then 'WebSite'
						--	when v.dp1 ='Fire OS' then 'Fire OS'
						--	when v.dp1='Standard Android OS' then 'Standard Android OS'
						else v.pfm
			end,
			case when v.dp1  like '%Chromecast%' or v.dp2  like '%Chromecast%' or v.dp3  like '%Chromecast%'   or v.dp4  like '%Chromecast%' 
				 or v.dp5  like '%Chromecast%' then 'Chromecast'
				 when v.dp1  like '%Android%' or v.dp2  like '%Android%' or v.dp3  like '%Android%'   or v.dp4  like '%Android%' 
				 or v.dp5  like '%Android%' then 'Android OS'
				  when v.dp1  like '%Fire%' or v.dp2  like '%Fire%' or v.dp3  like '%Fire%'   or v.dp4  like '%Fire%' 
				 or v.dp5  like '%Fire%' then 'Fire OS'
				 when v.dp1  like '%Alexa%' or v.dp2  like '%Alexa%' or v.dp3  like '%Alexa%'   or v.dp4  like '%Alexa%' 
				 or v.dp5  like '%Alexa%' then 'Alexa'
			end,
			case when v.dp1  like '%audio%' or v.dp2  like '%audio%' or v.dp3  like '%audio%'   or v.dp4  like '%audio%' 
				 or v.dp5  like '%audio%'  then 1
				 else  0
			end,
			case when  v.dp1  like '%offline%' or v.dp2  like '%offline%' or v.dp3  like '%offline%'   or v.dp4  like '%offline%' 
				 or v.dp5  like '%offline%' then 1
				else  0
			end,
			case when  v.dp1  like '%0.0%' or v.dp2  like '%0.0%' or v.dp3  like '%0.0%'   or v.dp4  like '%0.0%' 
				 or v.dp5  like '%0.0%' then '0.0'
				 when  v.dp1  like '%0.5%' or v.dp2  like '%0.5%' or v.dp3  like '%0.5%'   or v.dp4  like '%0.5%' 
				 or v.dp5  like '%0.5%' then '0.5'
				 when  v.dp1  like '%0.75%' or v.dp2  like '%0.75%' or v.dp3  like '%0.75%'   or v.dp4  like '%0.75%' 
				 or v.dp5  like '%0.75%' then '0.75'
				 when  v.dp1  like '%1.0%' or v.dp2  like '%1.0%' or v.dp3  like '%1.0%'   or v.dp4  like '%1.0%' 
				 or v.dp5  like '%1.0%' then '1.0'
				 when  v.dp1  like '%1.25%' or v.dp2  like '%1.25%' or v.dp3  like '%1.25%'   or v.dp4  like '%1.25%' 
				 or v.dp5  like '%1.25%' then '1.25'
				 when  v.dp1  like '%1.5%' or v.dp2  like '%1.5%' or v.dp3  like '%1.5%'   or v.dp4  like '%1.5%' 
				 or v.dp5  like '%1.5%' then '1.5'
				 when  v.dp1  like '%2.0%' or v.dp2  like '%2.0%' or v.dp3  like '%2.0%'   or v.dp4  like '%2.0%' 
				 or v.dp5  like '%2.0%' then '2.0'
			end,
			v.useragent,
			V.Vid,
			f.Course_id,
			F.Episode_Number,
			F.Film_Type,
			F.RunTime,
			V.Countryisocode,
			V.cityname,
			V.subdivision1,
			timezone,
			uip,
			case when v.tstamp >= paid.mincompleted_at  then 1
			else 0
			end 


	
	
update t
		set t.SeqNum = s.RNK
		from Datawarehouse.Marketing.TGCplus_Consumption_Smry_1  t
			 join ( select uuid,id,MinTstamp,
					Row_number ()over (partition by uuid,id order by  MinTstamp )as RNK
					--,isnull( lead(SeqNum) over (partition by uuid,id order by  MinTstamp ) + Row_number ()over (partition by uuid,id order by  MinTstamp)
					--		,Lag(SeqNum) over (partition by uuid,id order by  MinTstamp ) + Row_number ()over (partition by uuid,id order by  MinTstamp)
					--		)as SeqNum
						from Datawarehouse.Marketing.TGCplus_Consumption_Smry_1
						where id in (select id 
									from Datawarehouse.Marketing.TGCplus_Consumption_Smry_1 
									where SeqNum = 0
									group by id) 

			) s
		on s.uuid= t.uuid and s.id = t.id and s.MinTstamp=t.MinTstamp 
		where t.SeqNum = 0

/* First Paid Date from UserBilling table */
	 select user_id as id, min(ub.completed_at)  mincompleted_at
	 into #Userbilling
	 from DataWarehouse.Archive.TGCPlus_UserBilling ub
	 where ub.pre_tax_amount > 0
	 group by user_id 

--alter table Datawarehouse.Marketing.TGCplus_Consumption_Smry_1 add Paid_SeqNum int
	update t
	set Paid_SeqNum = 0 
	from Datawarehouse.Marketing.TGCplus_Consumption_Smry_1 t
	join #Userbilling ub
	on t.id = ub.id and t.MinTstamp >= ub.mincompleted_at
	where t.Paid_SeqNum is null

	update t
	set t.Paid_SeqNum = s.RNK
	from Datawarehouse.Marketing.TGCplus_Consumption_Smry_1  t
			join ( select uuid,id,MinTstamp,
				Row_number ()over (partition by uuid,id order by  MinTstamp )as RNK
					from Datawarehouse.Marketing.TGCplus_Consumption_Smry_1
					where Paid_SeqNum >=0
					and id in (select id 
								from Datawarehouse.Marketing.TGCplus_Consumption_Smry_1 
								where Paid_SeqNum = 0
								group by id) 
		) s
	on s.uuid= t.uuid and s.id = t.id and s.MinTstamp=t.MinTstamp 
	where t.Paid_SeqNum = 0

	/* get Customer IntlPaidDate 

	select customerid,IntlPaidDate into #paidCustomers
	from DataWarehouse.Marketing.TGCPlus_CustomerSignature

	
	update t
	set PaidFlag = 0
	from Datawarehouse.Marketing.TGCplus_Consumption_Smry_1 t
	join #paidCustomers paid on
	paid.CustomerID=t.id
	where t.tstamp > paid.IntlPaidDate

	*/

End

 








GO
