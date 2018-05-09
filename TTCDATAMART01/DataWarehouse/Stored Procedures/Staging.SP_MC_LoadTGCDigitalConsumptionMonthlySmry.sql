SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Staging].[SP_MC_LoadTGCDigitalConsumptionMonthlySmry]
	@AsOfDate date = null
AS
BEGIN
	set nocount on
	-- declare @AsOfDate date

	--BEGIN TRANSACTION Inner1; 
    set @AsOfDate = isnull(@AsOfDate, dateadd(month,-1,getdate()))  

	Declare @EndOfMonth date
	select @EndOfMonth = dateadd(day,-1,dateadd(month,1,@AsOfDate))
	
	select @AsOfDate  as AsOfDate, @EndOfMonth as EndOfMonth
	--commit TRANSACTION Inner1; 


	--BEGIN TRANSACTION Inner2; 
	if object_id('Staging.MC_TGC_Consumption_BaseTEMPMonth') is not null drop table Staging.MC_TGC_Consumption_BaseTEMPMonth

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
				,convert(varchar,CourseID) + convert(varchar,Lecturenumber) as CourseLecture
			into Staging.MC_TGC_Consumption_BaseTEMPMonth
			from Archive.Vw_TGC_DigitalConsumption
			where ActionDate between @AsOfDate and @EndOfMonth
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
			into Staging.MC_TGC_Consumption_BaseTEMPMonth
			from Archive.DigitalConsumptionHistory
			where StreamingDate between @AsOfDate and @EndOfMonth
			and CustomerID is not null
			and TransactionType = 'Purchased'
		end
	--commit TRANSACTION Inner2; 
	-- Need streaming information for three different combinations
	--1. Subsequent Month
	--2. LTD
	--3. Last 12 Month before the last order

	-- Metrics
	-- Flag Streamed, Total Streamed Mins, Total Actions, Number of Lectures and Number of Courses

	-- drop table #conformatSmryMnthly1
	select CustomerID
			,sum(TotalActions) TotalPlays
			,convert(numeric(18,2),sum(MediaTimePlayed)) StreamedMins
			,count(distinct CourseID) CoursesStreamed
			,count(distinct convert(varchar,CourseID) + convert(varchar,Lecturenumber)) LecturesStreamed
			,1 as FlagStreamed
	into #conformatSmryMnthly1
	from Staging.MC_TGC_Consumption_BaseTEMPMonth
	where MediaTimePlayed > 0
	and Action = 'Stream'
	group by CustomerID

	--drop table #conformatSmryMnthly
	--BEGIN TRANSACTION Inner3; 
	select a.CustomerID
		,@AsOfDate as AsOfDate
		,a.TotalPlays
		,a.StreamedMins
		,a.CoursesStreamed
		,a.LecturesStreamed
		,a.FlagStreamed
		/* For DVD */
		,sum(case when FormatPurchased = 'DVD' then Strm.TotalPlays else 0 end) TotalPlays_DVD
		,sum(case when FormatPurchased = 'DVD' then Strm.StreamedMins else 0 end) StreamedMins_DVD
		,sum(case when FormatPurchased = 'DVD' then Strm.Coursesstreamed else 0 end) CoursesStreamed_DVD
		,sum(case when FormatPurchased = 'DVD' then Strm.LecturesStreamed else 0 end) LecturesStreamed_DVD
		/* For CD */
		,sum(case when FormatPurchased = 'CD' then Strm.TotalPlays else 0 end) TotalPlays_CD
		,sum(case when FormatPurchased = 'CD' then Strm.StreamedMins else 0 end) StreamedMins_CD
		,sum(case when FormatPurchased = 'CD' then Strm.Coursesstreamed else 0 end) CoursesStreamed_CD
		,sum(case when FormatPurchased = 'CD' then Strm.LecturesStreamed else 0 end) LecturesStreamed_CD
		/* For DownloadV */
		,sum(case when FormatPurchased = 'DownloadV' then Strm.TotalPlays else 0 end) TotalPlays_DownloadV
		,sum(case when FormatPurchased = 'DownloadV' then Strm.StreamedMins else 0 end) StreamedMins_DownloadV
		,sum(case when FormatPurchased = 'DownloadV' then Strm.Coursesstreamed else 0 end) CoursesStreamed_DownloadV
		,sum(case when FormatPurchased = 'DownloadV' then Strm.LecturesStreamed else 0 end) LecturesStreamed_DownloadV
		/* For DownloadA */
		,sum(case when FormatPurchased = 'DownloadA' then Strm.TotalPlays else 0 end) TotalPlays_DownloadA
		,sum(case when FormatPurchased = 'DownloadA' then Strm.StreamedMins else 0 end) StreamedMins_DownloadA
		,sum(case when FormatPurchased = 'DownloadA' then Strm.Coursesstreamed else 0 end) CoursesStreamed_DownloadA
		,sum(case when FormatPurchased = 'DownloadA' then Strm.LecturesStreamed else 0 end) LecturesStreamed_DownloadA
	into #conformatSmryMnthly
	from #conformatSmryMnthly1 a
	left join (select CustomerID
				,replace(FormatPurchased,' ','') FormatPurchased
				,sum(TotalActions) TotalPlays
				,convert(numeric(18,2),sum(MediaTimePlayed)) StreamedMins
				,count(distinct CourseID) CoursesStreamed
				,count(distinct convert(varchar,CourseID) + convert(varchar,Lecturenumber)) LecturesStreamed
				,1 as FlagStreamed
			from Staging.MC_TGC_Consumption_BaseTEMPMonth
			where MediaTimePlayed > 0
			and Action = 'Stream'
			--and TransactionType = 'Purchased'
			group by CustomerID
				,replace(FormatPurchased,' ',''))Strm on a.CustomerID = Strm.CustomerID
	group by a.CustomerID
		,a.TotalPlays
		,a.StreamedMins
		,a.CoursesStreamed
		,a.LecturesStreamed
		,a.FlagStreamed

	print 'Done #conformatSmryMnthly'
	--commit TRANSACTION Inner3; 

	
	--drop table #CondlsmryMnthly1
	select CustomerID
			,sum(TotalActions) TotalDnlds
			,count(distinct CourseID) CoursesDnld
			,count(distinct convert(varchar,CourseID) + convert(varchar,Lecturenumber)) LecturesDnld
			,1 as FlagDnld
	into #CondlsmryMnthly1
	from Staging.MC_TGC_Consumption_BaseTEMPMonth
	where action = 'Download'
	and TotalActions > 0
	group by CustomerID

	--BEGIN TRANSACTION Inner4; 
	--drop table #CondlsmryMnthly
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
	into #CondlsmryMnthly
	from #CondlsmryMnthly1 a 
	left join (select CustomerID
					,replace(FormatPurchased,' ','') FormatPurchased
					,sum(TotalActions) TotalDnlds
					,count(distinct CourseID) CoursesDnld
					,count(distinct convert(varchar,CourseID) + convert(varchar,Lecturenumber)) LecturesDnld
					,1 as FlagDnld
				from Staging.MC_TGC_Consumption_BaseTEMPMonth
				where action = 'Download'
				and TotalActions > 0
				group by CustomerID
					,cast(DATEADD(month, DATEDIFF(month, 0, ActionDate), 0) as date)
					,replace(FormatPurchased,' ',''))Fnl on a.CustomerID = Fnl.CustomerID
	group by a.CustomerID
		,a.TotalDnlds
		,a.CoursesDnld
		,a.LecturesDnld
		,a.FlagDnld
	--,AsOfDate

	print 'Done #CondlsmryMnthly'
	--commit TRANSACTION Inner4; 


	--BEGIN TRANSACTION Inner5; 
 --   truncate table Staging.MC_TGC_Consumption_MonthlySmryTEMP
	if object_id('Staging.MC_TGC_Consumption_MonthlySmryTEMP') is not null drop table Staging.MC_TGC_Consumption_MonthlySmryTEMP

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
	into Staging.MC_TGC_Consumption_MonthlySmryTEMP
	from #conformatSmryMnthly a
	full outer join #CondlsmryMnthly b on a.CustomerID = b.CustomerID
							and a.asofdate = b.asofdate
							
	print 'Done tempfinal'
	--commit TRANSACTION Inner5; 
		
	-- delete if AsOfDate is already in the table 
	delete a
	-- select a.*
	from Marketing.MC_TGC_Consumption_MonthlySmry a join
		(select distinct AsOfDate
		from Staging.MC_TGC_Consumption_MonthlySmryTEMP)b on a.AsofDate = b.AsOfDate

	insert into Marketing.MC_TGC_Consumption_MonthlySmry
	select * 
	from Staging.MC_TGC_Consumption_MonthlySmryTEMP


end

GO
