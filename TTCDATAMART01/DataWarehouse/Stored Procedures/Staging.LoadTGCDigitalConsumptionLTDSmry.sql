SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [Staging].[LoadTGCDigitalConsumptionLTDSmry]
	@AsOfDate date = null
AS
BEGIN
	set nocount on
    set @AsOfDate = isnull(@AsOfDate, dateadd(month,-1,getdate()))  
	
	select @AsOfDate  as AsOfDate
    
	if object_id('Staging.TGC_Consumption_BaseTEMPLTD') is not null drop table Staging.TGC_Consumption_BaseTEMPLTD

	if @AsOfDate >= '1/1/2017'
		begin
			select Customerid, StreamingDate as ActionDate
				,Courseid, LectureNumber
				,FormatPurchased, TransactionType
				,Action, TotalActions
				,(StreamSeconds/60) MediaTimePlayed
				,convert(varchar,CourseID) + convert(varchar,Lecturenumber) as CourseLecture
			into Staging.TGC_Consumption_BaseTEMPLTD
			from Archive.DigitalConsumptionHistory
			where StreamingDate < @AsOfDate
			and CustomerID is not null
				union all
			select CustomerID, Actiondate
				,CourseID, LectureNumber
				,FormatPurchased, TransactionType
				,Action, TotalActions
				,MediaTimePlayed
				,convert(varchar,CourseID) + convert(varchar,Lecturenumber) as CourseLecture
			FROM Archive.Vw_TGC_DigitalConsumption
			where Actiondate < @AsOfDate 
			and CustomerID is not null
		end
	else
		begin
			select Customerid, StreamingDate as ActionDate
			,Courseid, LectureNumber
			,FormatPurchased, TransactionType
			,Action, TotalActions
			,(StreamSeconds/60) MediaTimePlayed
			,convert(varchar,CourseID) + convert(varchar,Lecturenumber) as CourseLecture
			into Staging.TGC_Consumption_BaseTEMPLTD
			from Archive.DigitalConsumptionHistory
			where StreamingDate < @AsOfDate
			and CustomerID is not null
		end
	
	-- Need streaming information for three different combinations
	--1. Subsequent Month
	--2. LTD
	--3. Last 12 Month before the last order

	-- Metrics
	-- Flag Streamed, Total Streamed Mins, Total Actions, Number of Lectures and Number of Courses

	--drop table #conformatSmry
	
	select CustomerID
		,@AsOfDate as AsOfDate
		,sum(TotalPlays) TotalPlays
		,sum(StreamedMins) StreamedMins
		,sum(CoursesStreamed) CoursesStreamed
		,sum(LecturesStreamed) LecturesStreamed
		,1 as FlagStreamed
		/* For DVD */
		,sum(case when FormatPurchased = 'DVD' then TotalPlays else 0 end) TotalPlays_DVD
		,sum(case when FormatPurchased = 'DVD' then StreamedMins else 0 end) StreamedMins_DVD
		,sum(case when FormatPurchased = 'DVD' then Coursesstreamed else 0 end) CoursesStreamed_DVD
		,sum(case when FormatPurchased = 'DVD' then LecturesStreamed else 0 end) LecturesStreamed_DVD
		/* For CD */
		,sum(case when FormatPurchased = 'CD' then TotalPlays else 0 end) TotalPlays_CD
		,sum(case when FormatPurchased = 'CD' then StreamedMins else 0 end) StreamedMins_CD
		,sum(case when FormatPurchased = 'CD' then Coursesstreamed else 0 end) CoursesStreamed_CD
		,sum(case when FormatPurchased = 'CD' then LecturesStreamed else 0 end) LecturesStreamed_CD
		/* For DownloadV */
		,sum(case when FormatPurchased = 'DownloadV' then TotalPlays else 0 end) TotalPlays_DownloadV
		,sum(case when FormatPurchased = 'DownloadV' then StreamedMins else 0 end) StreamedMins_DownloadV
		,sum(case when FormatPurchased = 'DownloadV' then Coursesstreamed else 0 end) CoursesStreamed_DownloadV
		,sum(case when FormatPurchased = 'DownloadV' then LecturesStreamed else 0 end) LecturesStreamed_DownloadV
		/* For DownloadA */
		,sum(case when FormatPurchased = 'DownloadA' then TotalPlays else 0 end) TotalPlays_DownloadA
		,sum(case when FormatPurchased = 'DownloadA' then StreamedMins else 0 end) StreamedMins_DownloadA
		,sum(case when FormatPurchased = 'DownloadA' then Coursesstreamed else 0 end) CoursesStreamed_DownloadA
		,sum(case when FormatPurchased = 'DownloadA' then LecturesStreamed else 0 end) LecturesStreamed_DownloadA
	into #conformatSmry
	from (select CustomerID
				,replace(FormatPurchased,' ','') FormatPurchased
				,sum(TotalActions) TotalPlays
				,convert(numeric(18,2),sum(MediaTimePlayed)) StreamedMins
				,count(distinct CourseID) CoursesStreamed
				,count(distinct convert(varchar,CourseID) + convert(varchar,Lecturenumber)) LecturesStreamed
				,1 as FlagStreamed
			from Staging.TGC_Consumption_BaseTEMPLTD
			where MediaTimePlayed > 0
			and Action = 'Stream'
			and TransactionType = 'Purchased'
			group by CustomerID
				,replace(FormatPurchased,' ',''))Strm
	group by CustomerID
	--	,AsOfDate
	

	--drop table #Condlsmry
	select CustomerID
		,@AsOfDate as AsOfDate
		,sum(TotalDnlds) TotalDnlds
		,sum(CoursesDnld) CoursesDnld
		,sum(LecturesDnld) LecturesDnld
		,1 as FlagDnld
		/* For DownloadV */
		,sum(case when FormatPurchased = 'DownloadV' then TotalDnlds else 0 end) TotalDnlds_DownloadV
		,sum(case when FormatPurchased = 'DownloadV' then CoursesDnld else 0 end) CoursesDnld_DownloadV
		,sum(case when FormatPurchased = 'DownloadV' then LecturesDnld else 0 end) LecturesDnld_DownloadV
		/* For DownloadA */
		,sum(case when FormatPurchased = 'DownloadA' then TotalDnlds else 0 end) TotalDnlds_DownloadA
		,sum(case when FormatPurchased = 'DownloadA' then CoursesDnld else 0 end) CoursesDnld_DownloadA
		,sum(case when FormatPurchased = 'DownloadA' then LecturesDnld else 0 end) LecturesDnld_DownloadA
	into #Condlsmry
	from (
	select CustomerID
		,cast(DATEADD(month, DATEDIFF(month, 0, ActionDate), 0) as date) AsOfDate
		,replace(FormatPurchased,' ','') FormatPurchased
		--,convert(varchar,year(ActionDate)) + convert(varchar,month(ActionDate)) AsOfMnthYr
		,sum(TotalActions) TotalDnlds
		,count(distinct CourseID) CoursesDnld
		,count(distinct convert(varchar,CourseID) + convert(varchar,Lecturenumber)) LecturesDnld
		,1 as FlagDnld
	from Staging.TGC_Consumption_BaseTEMPLTD
	where action = 'Download'
	and TransactionType = 'Purchased'
	group by CustomerID
		,cast(DATEADD(month, DATEDIFF(month, 0, ActionDate), 0) as date)
		,replace(FormatPurchased,' ',''))Fnl
	group by CustomerID
	--,AsOfDate

 --   truncate table Staging.TGC_Consumption_LTDSmryTEMP
	if object_id('Staging.TGC_Consumption_LTDSmryTEMP') is not null drop table Staging.TGC_Consumption_LTDSmryTEMP

	-- Get information for subsequent month
	select isnull(a.CustomerID, b.customerid) CustomerID
		,isnull(a.AsOfDate, b.AsOfDate) AsOfDate
		,isnull(a.TotalPlays, 0) TotalPlays_LTD
		,isnull(a.StreamedMins, 0) StreamedMins_LTD
		,isnull(a.CoursesStreamed, 0) CoursesStreamed_LTD
		,isnull(a.LecturesStreamed, 0) LecturesStreamed_LTD
		,isnull(a.FlagStreamed, 0) FlagStreamed_LTD
		/* For DVD */
		,isnull(a.TotalPlays_DVD, 0) TotalPlays_DVD_LTD
		,isnull(a.StreamedMins_DVD, 0) StreamedMins_DVD_LTD
		,isnull(a.CoursesStreamed_DVD, 0) CoursesStreamed_DVD_LTD
		,isnull(a.LecturesStreamed_DVD, 0) LecturesStreamed_DVD_LTD
		,case when a.StreamedMins_DVD > 0 then 1 else 0 end as FlagStreamed_DVD_LTD
		/* For CD */
		,isnull(a.TotalPlays_CD, 0) TotalPlays_CD_LTD
		,isnull(a.StreamedMins_CD, 0) StreamedMins_CD_LTD
		,isnull(a.CoursesStreamed_CD, 0) CoursesStreamed_CD_LTD
		,isnull(a.LecturesStreamed_CD, 0) LecturesStreamed_CD_LTD
		,case when a.StreamedMins_CD > 0 then 1 else 0 end as FlagStreamed_CD_LTD
		/* For DownloadV */
		,isnull(a.TotalPlays_DownloadV, 0) TotalPlays_DownloadV_LTD
		,isnull(a.StreamedMins_DownloadV, 0) StreamedMins_DownloadV_LTD
		,isnull(a.CoursesStreamed_DownloadV, 0) CoursesStreamed_DownloadV_LTD
		,isnull(a.LecturesStreamed_DownloadV, 0) LecturesStreamed_DownloadV_LTD
		,case when a.StreamedMins_DownloadV > 0 then 1 else 0 end as FlagStreamed_DownloadV_LTD
		/* For DownloadA */
		,isnull(a.TotalPlays_DownloadA, 0) TotalPlays_DownloadA_LTD
		,isnull(a.StreamedMins_DownloadA, 0) StreamedMins_DownloadA_LTD
		,isnull(a.CoursesStreamed_DownloadA, 0) CoursesStreamed_DownloadA_LTD
		,isnull(a.LecturesStreamed_DownloadA, 0) LecturesStreamed_DownloadA_LTD
		,case when a.StreamedMins_DownloadA > 0 then 1 else 0 end as FlagStreamed_DownloadA_LTD
		/* For Downloads */
		,isnull(b.TotalDnlds,0) TotalDnlds_LTD
		,isnull(b.CoursesDnld,0) CoursesDnld_LTD
		,isnull(b.LecturesDnld,0) LecturesDnld_LTD
		,isnull(b.FlagDnld,0) FlagDnld_LTD
		/* For DownloadV */
		,isnull(b.TotalDnlds_DownloadV,0) TotalDnlds_DownloadV_LTD
		,isnull(b.CoursesDnld_DownloadV,0) CoursesDnld_DownloadV_LTD
		,isnull(b.LecturesDnld_DownloadV,0) LecturesDnld_DownloadV_LTD
		,case when b.CoursesDnld_DownloadV > 0 then 1 else 0 end as FlagDnld_DownloadV_LTD
		/* For DownloadA */
		,isnull(b.TotalDnlds_DownloadA,0) TotalDnlds_DownloadA_LTD
		,isnull(b.CoursesDnld_DownloadA,0) CoursesDnld_DownloadA_LTD
		,isnull(b.LecturesDnld_DownloadA,0) LecturesDnld_DownloadA_LTD
		,case when b.CoursesDnld_DownloadA > 0 then 1 else 0 end as FlagDnld_DownloadA_LTD,
		NULL AS LecturesStreamedBins,
		NULL AS CoursesStreamedBins,
		NULL AS TotalPlaysBins,
		NULL AS TotalMinBins
	into Staging.TGC_Consumption_LTDSmryTEMP
	from #conformatSmry a
	full outer join #Condlsmry b on a.CustomerID = b.CustomerID
							and a.asofdate = b.asofdate
							
update Staging.TGC_Consumption_LTDSmryTEMP set [CoursesStreamedBins] =  case when CoursesStreamed_LTD = 1 then '1. 1 Course' when CoursesStreamed_LTD = 2 then '2. 2 Courses' when CoursesStreamed_LTD >= 3 then '3. >= 3 Courses' else '4. None'end  -- where AsOfDate =	@AsOfDate
update Staging.TGC_Consumption_LTDSmryTEMP set [LecturesStreamedBins] =  case when LecturesStreamed_LTD = 1 then '1. 1 Lctr' when LecturesStreamed_LTD = 2 then '2. 2 Lctrs' when LecturesStreamed_LTD between 3 and 5 then '3. 3-5 Lctrs' when LecturesStreamed_LTD between 6 and 10 then '4. 6-10 Lctrs' when LecturesStreamed_LTD >= 11 then '5. >= 11 Lctrs' else '6. None' end  --where AsOfDate = 	AsOfDate
update Staging.TGC_Consumption_LTDSmryTEMP	set [totalplaysBins] =	case when totalplays_LTD between 1 and 3 then '1. 1-3 Plays'	when totalplays_LTD between 4 and 6 then '2. 4-6 Plays' when totalplays_LTD between 7 and 9 then '3. 7-9 Plays'	WHEN totalplays_LTD >= 10 THEN '4. >=10 Plays' ELSE '5. None'   end			
update Staging.TGC_Consumption_LTDSmryTEMP	set TotalMinBins =	case when StreamedMins_LTD between 1 and 30 then '1. 1-30 Mins' when StreamedMins_LTD between 31 and 60 then '2. 31-60 Mins' when StreamedMins_LTD between 61 and 90 then '3. 61-90 Mins' WHEN StreamedMins_LTD >= 91 THEN '4. >= 91 Mins' else '5. None' END 
		
	-- delete if AsOfDate is already in the table 
	delete a
	-- select a.*
	from Marketing.TGC_Consumption_LTDSmry a join
		(select distinct AsOfDate
		from Staging.TGC_Consumption_LTDSmryTEMP)b on a.AsofDate = b.AsOfDate

	insert into Marketing.TGC_Consumption_LTDSmry
	select * 
	from Staging.TGC_Consumption_LTDSmryTEMP


end




GO
