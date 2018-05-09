SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[SP_MC_LoadTGCDigitalConsumptionLTDSmry]
	@AsOfDate date = null
AS
BEGIN
	set nocount on
    set @AsOfDate = isnull(@AsOfDate, dateadd(month,-1,getdate()))  
	
	select @AsOfDate  as AsOfDate
    
	if object_id('Staging.MC_TGC_Consumption_BaseTEMPLTD') is not null drop table Staging.MC_TGC_Consumption_BaseTEMPLTD

	if @AsOfDate >= '1/1/2017'
		begin
			select Customerid
				,ActionDate
				,Courseid
				,LectureNumber
				,FormatPurchased
				,TransactionType
				,Action
				,TotalActions
				,MediaTimePlayed
				,CourseLecture
			into Staging.MC_TGC_Consumption_BaseTEMPLTD
			from Archive.Vw_TGC_DigitalConsumptionAllYrs
			where ActionDate < @AsOfDate
			and TransactionType = 'Purchased'
		end
	else
		begin
			select Customerid, StreamingDate as ActionDate
			,Courseid, LectureNumber
			,FormatPurchased, TransactionType
			,Action, TotalActions
			,(StreamSeconds/60) MediaTimePlayed
			,convert(varchar,CourseID) + convert(varchar,Lecturenumber) as CourseLecture
			into Staging.MC_TGC_Consumption_BaseTEMPLTD
			from Archive.DigitalConsumptionHistory
			where StreamingDate < @AsOfDate
			and CustomerID is not null
			and TransactionType = 'Purchased'
		end
	
	-- Need streaming information for three different combinations
	--1. Subsequent Month
	--2. LTD
	--3. Last 12 Month before the last order

	-- Metrics
	-- Flag Streamed, Total Streamed Mins, Total Actions, Number of Lectures and Number of Courses

	--drop table #conformatSmry1
	select CustomerID
			,sum(TotalActions) TotalPlays
			,convert(numeric(18,2),sum(MediaTimePlayed)) StreamedMins
			,count(distinct CourseID) CoursesStreamed
			,count(distinct convert(varchar,CourseID) + convert(varchar,Lecturenumber)) LecturesStreamed
			,1 as FlagStreamed
	into #conformatSmry1
	from Staging.MC_TGC_Consumption_BaseTEMPLTD
	where MediaTimePlayed > 0
	and Action = 'Stream'
	group by CustomerID

	--drop table #conformatSmry
	
	select a.CustomerID
		,@AsOfDate as AsOfDate
		,a.TotalPlays
		,a.StreamedMins
		,a.CoursesStreamed
		,a.LecturesStreamed
		,a.FlagStreamed
		/* For DVD */
		,sum(case when FormatPurchased = 'DVD' then strm.TotalPlays else 0 end) TotalPlays_DVD
		,sum(case when FormatPurchased = 'DVD' then strm.StreamedMins else 0 end) StreamedMins_DVD
		,sum(case when FormatPurchased = 'DVD' then strm.Coursesstreamed else 0 end) CoursesStreamed_DVD
		,sum(case when FormatPurchased = 'DVD' then strm.LecturesStreamed else 0 end) LecturesStreamed_DVD
		/* For CD */
		,sum(case when FormatPurchased = 'CD' then strm.TotalPlays else 0 end) TotalPlays_CD
		,sum(case when FormatPurchased = 'CD' then strm.StreamedMins else 0 end) StreamedMins_CD
		,sum(case when FormatPurchased = 'CD' then strm.Coursesstreamed else 0 end) CoursesStreamed_CD
		,sum(case when FormatPurchased = 'CD' then strm.LecturesStreamed else 0 end) LecturesStreamed_CD
		/* For DownloadV */
		,sum(case when FormatPurchased = 'DownloadV' then strm.TotalPlays else 0 end) TotalPlays_DownloadV
		,sum(case when FormatPurchased = 'DownloadV' then strm.StreamedMins else 0 end) StreamedMins_DownloadV
		,sum(case when FormatPurchased = 'DownloadV' then strm.Coursesstreamed else 0 end) CoursesStreamed_DownloadV
		,sum(case when FormatPurchased = 'DownloadV' then strm.LecturesStreamed else 0 end) LecturesStreamed_DownloadV
		/* For DownloadA */
		,sum(case when FormatPurchased = 'DownloadA' then strm.TotalPlays else 0 end) TotalPlays_DownloadA
		,sum(case when FormatPurchased = 'DownloadA' then strm.StreamedMins else 0 end) StreamedMins_DownloadA
		,sum(case when FormatPurchased = 'DownloadA' then strm.Coursesstreamed else 0 end) CoursesStreamed_DownloadA
		,sum(case when FormatPurchased = 'DownloadA' then strm.LecturesStreamed else 0 end) LecturesStreamed_DownloadA
	into #conformatSmry
	from #conformatSmry1 a
	left join (select CustomerID
				,replace(FormatPurchased,' ','') FormatPurchased
				,sum(TotalActions) TotalPlays
				,convert(numeric(18,2),sum(MediaTimePlayed)) StreamedMins
				,count(distinct CourseID) CoursesStreamed
				,count(distinct convert(varchar,CourseID) + convert(varchar,Lecturenumber)) LecturesStreamed
				,1 as FlagStreamed
			from Staging.MC_TGC_Consumption_BaseTEMPLTD
			where MediaTimePlayed > 0
			and Action = 'Stream'
			group by CustomerID
				,replace(FormatPurchased,' ',''))Strm on a.Customerid = strm.Customerid
	group by a.CustomerID
		,a.TotalPlays
		,a.StreamedMins
		,a.CoursesStreamed
		,a.LecturesStreamed
		,a.FlagStreamed
	

	-- drop table #Condlsmry1
	select CustomerID
		--,cast(DATEADD(month, DATEDIFF(month, 0, ActionDate), 0) as date) AsOfDate
		,@AsOfDate as AsOfDate
		,sum(TotalActions) TotalDnlds
		,count(distinct CourseID) CoursesDnld
		,count(distinct convert(varchar,CourseID) + convert(varchar,Lecturenumber)) LecturesDnld
		,1 as FlagDnld
	into #Condlsmry1
	from Staging.MC_TGC_Consumption_BaseTEMPLTD
	where action = 'Download'
	and TotalActions > 0
	group by CustomerID
		--,cast(DATEADD(month, DATEDIFF(month, 0, ActionDate), 0) as date)

	--drop table #Condlsmry
	select a.CustomerID
		,@AsOfDate as AsOfDate
		,a.TotalDnlds
		,a.CoursesDnld
		,a.LecturesDnld
		,a.FlagDnld
		/* For DownloadV */
		,sum(case when FormatPurchased = 'DownloadV' then Fnl.TotalDnlds else 0 end) TotalDnlds_DownloadV
		,sum(case when FormatPurchased = 'DownloadV' then Fnl.CoursesDnld else 0 end) CoursesDnld_DownloadV
		,sum(case when FormatPurchased = 'DownloadV' then Fnl.LecturesDnld else 0 end) LecturesDnld_DownloadV
		/* For DownloadA */
		,sum(case when FormatPurchased = 'DownloadA' then Fnl.TotalDnlds else 0 end) TotalDnlds_DownloadA
		,sum(case when FormatPurchased = 'DownloadA' then Fnl.CoursesDnld else 0 end) CoursesDnld_DownloadA
		,sum(case when FormatPurchased = 'DownloadA' then Fnl.LecturesDnld else 0 end) LecturesDnld_DownloadA
	into #Condlsmry
	from #Condlsmry1 a left join
		(select CustomerID
			--,cast(DATEADD(month, DATEDIFF(month, 0, ActionDate), 0) as date) AsOfDate
			,@AsOfDate as AsOfDate
			,replace(FormatPurchased,' ','') FormatPurchased
			--,convert(varchar,year(ActionDate)) + convert(varchar,month(ActionDate)) AsOfMnthYr
			,sum(TotalActions) TotalDnlds
			,count(distinct CourseID) CoursesDnld
			,count(distinct convert(varchar,CourseID) + convert(varchar,Lecturenumber)) LecturesDnld
			,1 as FlagDnld
		from Staging.MC_TGC_Consumption_BaseTEMPLTD
		where action = 'Download'
		and TotalActions > 0
		group by CustomerID
			--,cast(DATEADD(month, DATEDIFF(month, 0, ActionDate), 0) as date)
			,replace(FormatPurchased,' ',''))Fnl on a.Customerid = Fnl.Customerid
	group by a.CustomerID
		,a.TotalDnlds
		,a.CoursesDnld
		,a.LecturesDnld
		,a.FlagDnld

 --   truncate table Staging.MC_TGC_Consumption_LTDSmryTEMP
	if object_id('Staging.MC_TGC_Consumption_LTDSmryTEMP') is not null drop table Staging.MC_TGC_Consumption_LTDSmryTEMP

	-- Get information for subsequent month
	select distinct isnull(a.CustomerID, b.customerid) CustomerID
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
		,case when b.CoursesDnld_DownloadA > 0 then 1 else 0 end as FlagDnld_DownloadA_LTD
	into Staging.MC_TGC_Consumption_LTDSmryTEMP
	from #conformatSmry a
	full outer join #Condlsmry b on a.CustomerID = b.CustomerID
							and a.asofdate = b.asofdate
							

		
	-- delete if AsOfDate is already in the table 
	delete a
	-- select a.*
	from Marketing.MC_TGC_Consumption_LTDSmry a join
		(select distinct AsOfDate
		from Staging.MC_TGC_Consumption_LTDSmryTEMP)b on a.AsofDate = b.AsOfDate

	insert into Marketing.MC_TGC_Consumption_LTDSmry
	select * 
	from Staging.MC_TGC_Consumption_LTDSmryTEMP


end
GO
