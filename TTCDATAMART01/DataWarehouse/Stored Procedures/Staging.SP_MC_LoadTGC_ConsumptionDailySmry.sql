SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[SP_MC_LoadTGC_ConsumptionDailySmry]
	@AsOfDate date = null,
	@EndDate date = null
AS
BEGIN
	set nocount on
	-- declare @AsOfDate date, @EndDate date
    --select @AsOfDate = isnull(@AsOfDate, dateadd(day,-1,getdate()))  
    --select @EndDate = isnull(@EndDate, dateadd(DAY,1,@AsOfDate))  

	declare @AsOfDate2 Date, @EndDate2 date

	select @AsOfDate2 = isnull(@AsOfDAte, max(AsofDate))
	from Marketing.MC_TGC_DailyConsumptionHistory

    select @EndDate2 = case when @AsOfDate is null then dateadd(DAY,1,@AsOfDate2)
							when @AsOfDate > @EndDate then @AsOfDate
							else isnull(@EndDate, dateadd(DAY,1,getdate()))  
						end
	
	select @AsOfDate  as AsOfDate
	select @EndDate  as EndDate
    
	select @AsOfdate2  as AsOfdate2
	select @Enddate2  as Enddate2

	if object_id('Staging.MC_TGC_DailyConsumptionBase_TEMP') is not null drop table Staging.MC_TGC_DailyConsumptionBase_TEMP

	if @AsOfDate2 < '1/1/2017'
		begin
				select Customerid, StreamingDate as ActionDate
						,Courseid, LectureNumber
						,FormatPurchased, TransactionType
						,Action, TotalActions
						,(StreamSeconds/60) MediaTimePlayed
						,convert(varchar,CourseID) + convert(varchar,Lecturenumber) as CourseLecture
					into Staging.MC_TGC_DailyConsumptionBase_TEMP
					from Archive.DigitalConsumptionHistory
					where StreamingDate between @AsOfDate2 and @EndDate2
					and CustomerID is not null
						union all
					select CustomerID, Actiondate
						,CourseID, LectureNumber
						,FormatPurchased, TransactionType
						,Action, TotalActions
						,MediaTimePlayed
						,convert(varchar,CourseID) + convert(varchar,Lecturenumber) as CourseLecture
					FROM Archive.Vw_TGC_DigitalConsumption
					where Actiondate between @AsOfDate2 and @EndDate2
					and CustomerID is not null
			end
			else 
				begin
					--select Customerid, StreamingDate as ActionDate
					--	,Courseid, LectureNumber
					--	,FormatPurchased, TransactionType
					--	,Action, TotalActions
					--	,(StreamSeconds/60) MediaTimePlayed
					--	,convert(varchar,CourseID) + convert(varchar,Lecturenumber) as CourseLecture
					--into Staging.MC_TGC_DailyConsumptionBase_TEMP
					--from Archive.DigitalConsumptionHistory
					--where StreamingDate between @AsOfDate2 and @EndDate2
					--and CustomerID is not null
					--	union all
					select CustomerID, Actiondate
						,CourseID, LectureNumber
						,FormatPurchased, TransactionType
						,Action, TotalActions
						,MediaTimePlayed
						,convert(varchar,CourseID) + convert(varchar,Lecturenumber) as CourseLecture
					into Staging.MC_TGC_DailyConsumptionBase_TEMP
					FROM Archive.Vw_TGC_DigitalConsumption
					where Actiondate between @AsOfDate2 and @EndDate2
					and CustomerID is not null
				end


	-- Metrics
	-- Flag Streamed, Total Streamed Mins, Total Actions, Number of Lectures and Number of Courses

		--drop table #conformatSmry
	
	select distinct CustomerID
		,ActionDate as AsOfDate
		,CourseID
		,LectureNumber
		,CourseLecture
		,sum(TotalPlays) TotalPlays
		,sum(StreamedMins) StreamedMins
		,1 as FlagStreamed
		/* For DVD */
		,sum(case when FormatPurchased = 'DVD' then TotalPlays else 0 end) TotalPlays_DVD
		,sum(case when FormatPurchased = 'DVD' then StreamedMins else 0 end) StreamedMins_DVD
		/* For CD */
		,sum(case when FormatPurchased = 'CD' then TotalPlays else 0 end) TotalPlays_CD
		,sum(case when FormatPurchased = 'CD' then StreamedMins else 0 end) StreamedMins_CD
		/* For DownloadV */
		,sum(case when FormatPurchased = 'DownloadV' then TotalPlays else 0 end) TotalPlays_DownloadV
		,sum(case when FormatPurchased = 'DownloadV' then StreamedMins else 0 end) StreamedMins_DownloadV
		/* For DownloadA */
		,sum(case when FormatPurchased = 'DownloadA' then TotalPlays else 0 end) TotalPlays_DownloadA
		,sum(case when FormatPurchased = 'DownloadA' then StreamedMins else 0 end) StreamedMins_DownloadA
	into #conformatSmry
	from (select CustomerID
				,Actiondate
				,CourseID
				,LectureNumber
				,CourseLecture
				,replace(FormatPurchased,' ','') FormatPurchased
				,sum(TotalActions) TotalPlays
				,convert(numeric(18,2),sum(MediaTimePlayed)) StreamedMins
				,1 as FlagStreamed
			from Staging.MC_TGC_DailyConsumptionBase_TEMP
			where MediaTimePlayed > 0
			and Action = 'Stream'
			and TransactionType = 'Purchased'
			group by CustomerID
				,Actiondate
				,CourseID
				,LectureNumber
				,CourseLecture
				,replace(FormatPurchased,' ',''))Strm
	group by CustomerID
		,ActionDate
		,CourseID
		,LectureNumber
		,CourseLecture
	

	--drop table #Condlsmry
	select distinct CustomerID
		,ActionDate as AsOfDate
		,CourseID
		,LectureNumber
		,CourseLecture
		,sum(TotalDnlds) TotalDnlds
		,1 as FlagDnld
		/* For DownloadV */
		,sum(case when FormatPurchased = 'DownloadV' then TotalDnlds else 0 end) TotalDnlds_DownloadV
		/* For DownloadA */
		,sum(case when FormatPurchased = 'DownloadA' then TotalDnlds else 0 end) TotalDnlds_DownloadA
	into #Condlsmry
	from (select CustomerID
			,Actiondate
			,CourseID
			,LectureNumber
			,CourseLecture
			,replace(FormatPurchased,' ','') FormatPurchased
			,sum(TotalActions) TotalDnlds
			,1 as FlagDnld
		from Staging.MC_TGC_DailyConsumptionBase_TEMP
		where action = 'Download'
		and TransactionType = 'Purchased'
		group by CustomerID
			,Actiondate
			,CourseID
			,LectureNumber
			,CourseLecture
			,replace(FormatPurchased,' ',''))Fnl
	group by CustomerID
			,Actiondate
			,CourseID
			,LectureNumber
			,CourseLecture

 --   truncate table Staging.MC_TGC_DailyConsumptionHistoryTEMP
	if object_id('Staging.MC_TGC_DailyConsumptionHistoryTEMP') is not null drop table Staging.MC_TGC_DailyConsumptionHistoryTEMP

	-- Get information for subsequent month
	select distinct 
		isnull(a.CustomerID, b.customerid) CustomerID
		,isnull(a.AsOfDate, b.AsOfDate) AsOfDate
		,isnull(a.CourseID, b.CourseID) CourseID
		,isnull(a.LectureNumber, b.LectureNumber) LectureNumber
		,isnull(a.CourseLecture, b.CourseLecture) CourseLecture
		/* Overall Plays and StreamedMins */
		,isnull(a.TotalPlays, 0) TotalPlays
		,isnull(a.StreamedMins, 0) StreamedMins
		,isnull(a.FlagStreamed, 0) FlagStreamed
		/* For DVD */
		,isnull(a.TotalPlays_DVD, 0) TotalPlays_DVD
		,isnull(a.StreamedMins_DVD, 0) StreamedMins_DVD
		,case when a.StreamedMins_DVD > 0 then 1 else 0 end as FlagStreamed_DVD
		/* For CD */
		,isnull(a.TotalPlays_CD, 0) TotalPlays_CD
		,isnull(a.StreamedMins_CD, 0) StreamedMins_CD
		,case when a.StreamedMins_CD > 0 then 1 else 0 end as FlagStreamed_CD
		/* For DownloadV */
		,isnull(a.TotalPlays_DownloadV, 0) TotalPlays_DownloadV
		,isnull(a.StreamedMins_DownloadV, 0) StreamedMins_DownloadV
		,case when a.StreamedMins_DownloadV > 0 then 1 else 0 end as FlagStreamed_DownloadV
		/* For DownloadA */
		,isnull(a.TotalPlays_DownloadA, 0) TotalPlays_DownloadA
		,isnull(a.StreamedMins_DownloadA, 0) StreamedMins_DownloadA
		,case when a.StreamedMins_DownloadA > 0 then 1 else 0 end as FlagStreamed_DownloadA
		/* For Downloads */
		,isnull(b.TotalDnlds,0) TotalDnlds
		,isnull(b.FlagDnld,0) FlagDnld
		/* For DownloadV */
		,isnull(b.TotalDnlds_DownloadV,0) TotalDnlds_DownloadV
		,case when b.TotalDnlds_DownloadV > 0 then 1 else 0 end as FlagDnld_DownloadV
		/* For DownloadA */
		,isnull(b.TotalDnlds_DownloadA,0) TotalDnlds_DownloadA
		,case when b.TotalDnlds_DownloadA > 0 then 1 else 0 end as FlagDnld_DownloadA
		,Getdate() as DMLastUpdateDate
	into Staging.MC_TGC_DailyConsumptionHistoryTEMP
	from #conformatSmry a
	full outer join #Condlsmry b on a.CustomerID = b.CustomerID
							and a.asofdate = b.asofdate
							and a.CourseLecture = b.CourseLecture

	-- Insert into the main table
	--select * 
	--into Marketing.MC_TGC_DailyConsumptionHistory
	--from Staging.MC_TGC_DailyConsumptionHistoryTEMP
		
	-- delete if AsOfDate is already in the table 
	delete a
	-- select a.*
	from Marketing.MC_TGC_DailyConsumptionHistory a join
		(select distinct AsOfDate
		from Staging.MC_TGC_DailyConsumptionHistoryTEMP)b on a.AsofDate = b.AsOfDate

	insert into Marketing.MC_TGC_DailyConsumptionHistory
	select * 
	from Staging.MC_TGC_DailyConsumptionHistoryTEMP


end
GO
