SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[SP_MC_LoadTGCDigitalConsumptionL12MnthSmry_TEST]
	@AsOfDate date = null
AS
BEGIN
	set nocount on
    set @AsOfDate = isnull(@AsOfDate, dateadd(month,-1,getdate()))  
	
	select @AsOfDate  as AsOfDate
    
	if object_id('Staging.MC_TGC_Consumption_BaseTEMPL12Mnth_TEST') is not null drop table Staging.MC_TGC_Consumption_BaseTEMPL12Mnth_TEST

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
			into Staging.MC_TGC_Consumption_BaseTEMPL12Mnth_TEST
			from Archive.Vw_TGC_DigitalConsumptionAllYrs
			where ActionDate < '1/1/2018' --@AsOfDate
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
			into Staging.MC_TGC_Consumption_BaseTEMPL12Mnth_TEST
			from Archive.DigitalConsumptionHistory
			where StreamingDate < @AsOfDate
			and CustomerID is not null
			and TransactionType = 'Purchased'
		end
	
	-- Need streaming information for three different combinations
	--1. Subsequent Month
	--2. L12Mnth
	--3. Last 12 Month before the last order

	-- Get Last Order Date for customers as of the @asofdate
	-- drop table #LastOrder
	select a.CustomerID
			,a.DateOrdered --dateadd(day,-1,a.DateOrdered) EndDate,
			,dateadd(year,-1,a.DateOrdered) StartDate
			,a.OrderID
			,a.SequenceNum
	into #LastOrder
	from Marketing.DMPurchaseOrders a join
		(select CustomerID, Max(SequenceNum) MaxSequenceNum
		from Marketing.DMPurchaseOrders
		where DateOrdered < '1/1/2018' --@AsOfDate
		group by CustomerID)b on a.CustomerID = b.CustomerID
							and a.SequenceNum = b.MaxSequenceNum
	where a.SequenceNum > 1

	delete a
	from #LastOrder a left join
		(select distinct customerid 
		from Staging.MC_TGC_Consumption_BaseTEMPL12Mnth_TEST)b on a.CustomerID = b.Customerid
	where b.Customerid is null


	if object_id('Staging.MC_TGC_Consumption_L12MnthStrmTempAll_TEST') is not null drop table Staging.MC_TGC_Consumption_L12MnthStrmTempAll_TEST

	select a.Customerid
			,b.DateOrdered
			,b.StartDate
			, Min(a.ActionDate) MinActionDate
			, Max(a.ActionDate) MaxActionDate
			,sum(TotalActions) TotalPlays
			,convert(numeric(18,2),sum(MediaTimePlayed)) StreamedMins
			,count(distinct CourseID) CoursesStreamed
			,count(distinct convert(varchar,CourseID) + convert(varchar,Lecturenumber)) LecturesStreamed
			,1 as FlagStreamed
		into Staging.MC_TGC_Consumption_L12MnthStrmTempAll_TEST
		from Staging.MC_TGC_Consumption_BaseTEMPL12Mnth_TEST a 
		join #LastOrder b on a.Customerid = b.CustomerID
					and a.ActionDate between b.StartDate and b.DateOrdered
		where MediaTimePlayed > 0
		and Action = 'Stream'
		group by a.CustomerID
			,b.DateOrdered
			,b.StartDate

		/*	select top 100 * from Staging.MC_TGC_Consumption_L12MnthStrmTempAll_TEST
			where Customerid = 42118435*/



	if object_id('Staging.MC_TGC_Consumption_L12MnthStrmTemp_TEST') is not null drop table Staging.MC_TGC_Consumption_L12MnthStrmTemp_TEST

	select a.Customerid
			,b.DateOrdered
			,b.StartDate
			--,b.EndDate
			, Min(a.ActionDate) MinActionDate
			, Max(a.ActionDate) MaxActionDate
			,replace(FormatPurchased,' ','') FormatPurchased
			,sum(TotalActions) TotalPlays
			,convert(numeric(18,2),sum(MediaTimePlayed)) StreamedMins
			,count(distinct CourseID) CoursesStreamed
			,count(distinct convert(varchar,CourseID) + convert(varchar,Lecturenumber)) LecturesStreamed
			,1 as FlagStreamed
		into Staging.MC_TGC_Consumption_L12MnthStrmTemp_TEST
		from Staging.MC_TGC_Consumption_BaseTEMPL12Mnth_TEST a 
		join #LastOrder b on a.Customerid = b.CustomerID
					and a.ActionDate between b.StartDate and b.DateOrdered
		where MediaTimePlayed > 0
		and Action = 'Stream'
		group by a.CustomerID
			,b.DateOrdered
			,b.StartDate
			--,b.EndDate
			,replace(FormatPurchased,' ','')

			select top 100 * from Staging.MC_TGC_Consumption_L12MnthStrmTemp_TEST


	-- Metrics
	-- Flag Streamed, Total Streamed Mins, Total Actions, Number of Lectures and Number of Courses

	--drop table #conformatSmry
	
	select a.CustomerID
		,'1/1/2018' as AsoFdate --@AsOfDate as AsOfDate
		,a.DateOrdered as LastOrderDate
		,a.StartDate
		,a.MinActionDate
		,a.MaxActionDate
		,a.TotalPlays
		,a.StreamedMins
		,a.CoursesStreamed
		,a.LecturesStreamed
		,a.FlagStreamed
		/* For DVD */
		,sum(case when FormatPurchased = 'DVD' then b.TotalPlays else 0 end) TotalPlays_DVD
		,sum(case when FormatPurchased = 'DVD' then b.StreamedMins else 0 end) StreamedMins_DVD
		,sum(case when FormatPurchased = 'DVD' then b.Coursesstreamed else 0 end) CoursesStreamed_DVD
		,sum(case when FormatPurchased = 'DVD' then b.LecturesStreamed else 0 end) LecturesStreamed_DVD
		/* For CD */
		,sum(case when FormatPurchased = 'CD' then b.TotalPlays else 0 end) TotalPlays_CD
		,sum(case when FormatPurchased = 'CD' then b.StreamedMins else 0 end) StreamedMins_CD
		,sum(case when FormatPurchased = 'CD' then b.Coursesstreamed else 0 end) CoursesStreamed_CD
		,sum(case when FormatPurchased = 'CD' then b.LecturesStreamed else 0 end) LecturesStreamed_CD
		/* For DownloadV */
		,sum(case when FormatPurchased = 'DownloadV' then b.TotalPlays else 0 end) TotalPlays_DownloadV
		,sum(case when FormatPurchased = 'DownloadV' then b.StreamedMins else 0 end) StreamedMins_DownloadV
		,sum(case when FormatPurchased = 'DownloadV' then b.Coursesstreamed else 0 end) CoursesStreamed_DownloadV
		,sum(case when FormatPurchased = 'DownloadV' then b.LecturesStreamed else 0 end) LecturesStreamed_DownloadV
		/* For DownloadA */
		,sum(case when FormatPurchased = 'DownloadA' then b.TotalPlays else 0 end) TotalPlays_DownloadA
		,sum(case when FormatPurchased = 'DownloadA' then b.StreamedMins else 0 end) StreamedMins_DownloadA
		,sum(case when FormatPurchased = 'DownloadA' then b.Coursesstreamed else 0 end) CoursesStreamed_DownloadA
		,sum(case when FormatPurchased = 'DownloadA' then b.LecturesStreamed else 0 end) LecturesStreamed_DownloadA
	into #conformatSmry
	from staging.MC_TGC_Consumption_L12MnthStrmTempAll_TEST a
	left join Staging.MC_TGC_Consumption_L12MnthStrmTemp_TEST b on a.Customerid = b.Customerid
	group by a.CustomerID
		,a.DateOrdered
		,a.StartDate
		,a.MinActionDate
		,a.MaxActionDate
		,a.TotalPlays
		,a.StreamedMins
		,a.CoursesStreamed
		,a.LecturesStreamed
		,a.FlagStreamed
	
	select top 100 * from #conformatSmry

	if object_id('Staging.MC_TGC_Consumption_L12MnthDnldTempAll_TEST') is not null drop table Staging.MC_TGC_Consumption_L12MnthDnldTempAll_TEST

	select a.Customerid
			,b.DateOrdered
			,b.StartDate
			, Min(a.ActionDate) MinActionDate
			, Max(a.ActionDate) MaxActionDate
			,sum(TotalActions) TotalDnlds
			,count(distinct CourseID) CoursesDnld
			,count(distinct convert(varchar,CourseID) + convert(varchar,Lecturenumber)) LecturesDnld
			,1 as FlagDnld
	into Staging.MC_TGC_Consumption_L12MnthDnldTempAll_TEST
	from Staging.MC_TGC_Consumption_BaseTEMPL12Mnth_TEST a 
	join #LastOrder b on a.Customerid = b.CustomerID
				and a.ActionDate between b.StartDate and b.DateOrdered
	where action = 'Download'
	and TotalActions > 0
	group by a.CustomerID
		,b.DateOrdered
		,b.StartDate
		
			select top 100 * from Staging.MC_TGC_Consumption_L12MnthDnldTempAll_TEST

	
	if object_id('Staging.MC_TGC_Consumption_L12MnthDnldTemp_TEST') is not null drop table Staging.MC_TGC_Consumption_L12MnthDnldTemp_TEST

	select a.Customerid
			,b.DateOrdered
			,b.StartDate
			--,b.EndDate
			, Min(a.ActionDate) MinActionDate
			, Max(a.ActionDate) MaxActionDate
			,replace(FormatPurchased,' ','') FormatPurchased
			,sum(TotalActions) TotalDnlds
			,count(distinct CourseID) CoursesDnld
			,count(distinct convert(varchar,CourseID) + convert(varchar,Lecturenumber)) LecturesDnld
			,1 as FlagDnld
	into Staging.MC_TGC_Consumption_L12MnthDnldTemp_TEST
	from Staging.MC_TGC_Consumption_BaseTEMPL12Mnth_TEST a 
	join #LastOrder b on a.Customerid = b.CustomerID
				and a.ActionDate between b.StartDate and b.DateOrdered
	where action = 'Download'
	and TotalActions > 0
	group by a.CustomerID
		,b.DateOrdered
		,b.StartDate
		--,b.EndDate
		,cast(DATEADD(month, DATEDIFF(month, 0, ActionDate), 0) as date)
		,replace(FormatPurchased,' ','')

			select top 100 * from Staging.MC_TGC_Consumption_L12MnthDnldTemp_TEST

	--drop table #Condlsmry
	select a.CustomerID
		,'1/1/2018' as AsoFdate --@AsOfDate as AsOfDate
		,a.DateOrdered as LastOrderDate
		,a.StartDate
		,a.MinActionDate
		,a.MaxActionDate
		,a.TotalDnlds
		,a.CoursesDnld
		,a.LecturesDnld
		,a.FlagDnld
		/* For DownloadV */
		,sum(case when FormatPurchased = 'DownloadV' then b.TotalDnlds else 0 end) TotalDnlds_DownloadV
		,sum(case when FormatPurchased = 'DownloadV' then b.CoursesDnld else 0 end) CoursesDnld_DownloadV
		,sum(case when FormatPurchased = 'DownloadV' then b.LecturesDnld else 0 end) LecturesDnld_DownloadV
		/* For DownloadA */
		,sum(case when FormatPurchased = 'DownloadA' then b.TotalDnlds else 0 end) TotalDnlds_DownloadA
		,sum(case when FormatPurchased = 'DownloadA' then b.CoursesDnld else 0 end) CoursesDnld_DownloadA
		,sum(case when FormatPurchased = 'DownloadA' then b.LecturesDnld else 0 end) LecturesDnld_DownloadA
	into #Condlsmry
	from Staging.MC_TGC_Consumption_L12MnthDnldTempAll_TEST a
	left join Staging.MC_TGC_Consumption_L12MnthDnldTemp_TEST b on a.Customerid = b.Customerid
	group by a.CustomerID
		,a.DateOrdered
		,a.StartDate
		,a.MinActionDate
		,a.MaxActionDate
		,a.TotalDnlds
		,a.CoursesDnld
		,a.LecturesDnld
		,a.FlagDnld

 --   truncate table Staging.MC_TGC_Consumption_L12MnthSmryTEMP_TEST
	if object_id('Staging.MC_TGC_Consumption_L12MnthSmryTEMP_TEST') is not null drop table Staging.MC_TGC_Consumption_L12MnthSmryTEMP_TEST

	-- Get information for subsequent month
	select distinct isnull(a.CustomerID, b.customerid) CustomerID
		,isnull(a.AsOfDate, b.AsOfDate) AsOfDate
		,isnull(a.LastOrderDate, b.LastOrderDate) LastOrderDate
		,isnull(a.StartDate, b.StartDate) StartDate
		,isnull(a.TotalPlays, 0) TotalPlays_L12Mnth
		,isnull(a.StreamedMins, 0) StreamedMins_L12Mnth
		,isnull(a.CoursesStreamed, 0) CoursesStreamed_L12Mnth
		,isnull(a.LecturesStreamed, 0) LecturesStreamed_L12Mnth
		,isnull(a.FlagStreamed, 0) FlagStreamed_L12Mnth
		/* For DVD */
		,isnull(a.TotalPlays_DVD, 0) TotalPlays_DVD_L12Mnth
		,isnull(a.StreamedMins_DVD, 0) StreamedMins_DVD_L12Mnth
		,isnull(a.CoursesStreamed_DVD, 0) CoursesStreamed_DVD_L12Mnth
		,isnull(a.LecturesStreamed_DVD, 0) LecturesStreamed_DVD_L12Mnth
		,case when a.StreamedMins_DVD > 0 then 1 else 0 end as FlagStreamed_DVD_L12Mnth
		/* For CD */
		,isnull(a.TotalPlays_CD, 0) TotalPlays_CD_L12Mnth
		,isnull(a.StreamedMins_CD, 0) StreamedMins_CD_L12Mnth
		,isnull(a.CoursesStreamed_CD, 0) CoursesStreamed_CD_L12Mnth
		,isnull(a.LecturesStreamed_CD, 0) LecturesStreamed_CD_L12Mnth
		,case when a.StreamedMins_CD > 0 then 1 else 0 end as FlagStreamed_CD_L12Mnth
		/* For DownloadV */
		,isnull(a.TotalPlays_DownloadV, 0) TotalPlays_DownloadV_L12Mnth
		,isnull(a.StreamedMins_DownloadV, 0) StreamedMins_DownloadV_L12Mnth
		,isnull(a.CoursesStreamed_DownloadV, 0) CoursesStreamed_DownloadV_L12Mnth
		,isnull(a.LecturesStreamed_DownloadV, 0) LecturesStreamed_DownloadV_L12Mnth
		,case when a.StreamedMins_DownloadV > 0 then 1 else 0 end as FlagStreamed_DownloadV_L12Mnth
		/* For DownloadA */
		,isnull(a.TotalPlays_DownloadA, 0) TotalPlays_DownloadA_L12Mnth
		,isnull(a.StreamedMins_DownloadA, 0) StreamedMins_DownloadA_L12Mnth
		,isnull(a.CoursesStreamed_DownloadA, 0) CoursesStreamed_DownloadA_L12Mnth
		,isnull(a.LecturesStreamed_DownloadA, 0) LecturesStreamed_DownloadA_L12Mnth
		,case when a.StreamedMins_DownloadA > 0 then 1 else 0 end as FlagStreamed_DownloadA_L12Mnth
		/* For Downloads */
		,isnull(b.TotalDnlds,0) TotalDnlds_L12Mnth
		,isnull(b.CoursesDnld,0) CoursesDnld_L12Mnth
		,isnull(b.LecturesDnld,0) LecturesDnld_L12Mnth
		,isnull(b.FlagDnld,0) FlagDnld_L12Mnth
		/* For DownloadV */
		,isnull(b.TotalDnlds_DownloadV,0) TotalDnlds_DownloadV_L12Mnth
		,isnull(b.CoursesDnld_DownloadV,0) CoursesDnld_DownloadV_L12Mnth
		,isnull(b.LecturesDnld_DownloadV,0) LecturesDnld_DownloadV_L12Mnth
		,case when b.CoursesDnld_DownloadV > 0 then 1 else 0 end as FlagDnld_DownloadV_L12Mnth
		/* For DownloadA */
		,isnull(b.TotalDnlds_DownloadA,0) TotalDnlds_DownloadA_L12Mnth
		,isnull(b.CoursesDnld_DownloadA,0) CoursesDnld_DownloadA_L12Mnth
		,isnull(b.LecturesDnld_DownloadA,0) LecturesDnld_DownloadA_L12Mnth
		,case when b.CoursesDnld_DownloadA > 0 then 1 else 0 end as FlagDnld_DownloadA_L12Mnth
	into Staging.MC_TGC_Consumption_L12MnthSmryTEMP_TEST
	from #conformatSmry a
	full outer join #Condlsmry b on a.CustomerID = b.CustomerID
							and a.asofdate = b.asofdate
							

	select top 100 * from Staging.MC_TGC_Consumption_L12MnthSmryTEMP_TEST
		
	-- delete if AsOfDate is already in the table 
	delete a
	-- select a.*
	from Marketing.MC_TGC_Consumption_L12MnthSmry_TEST a join
		(select distinct AsOfDate
		from Staging.MC_TGC_Consumption_L12MnthSmryTEMP_TEST)b on a.AsofDate = b.AsOfDate

	insert into Marketing.MC_TGC_Consumption_L12MnthSmry_TEST
	select * 
	from Staging.MC_TGC_Consumption_L12MnthSmryTEMP_TEST


end
GO
