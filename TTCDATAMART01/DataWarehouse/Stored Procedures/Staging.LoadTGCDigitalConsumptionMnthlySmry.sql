SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[LoadTGCDigitalConsumptionMnthlySmry]
	@AsOfDate datetime = null
AS
BEGIN
	set nocount on
    set @AsOfDate = isnull(@AsOfDate, dateadd(month,-1,getdate()))    
    
	
	--drop table #consumption
	select *, convert(varchar,CourseID) + convert(varchar,Lecturenumber) as CourseLecture
	into #consumption
	FROM Archive.DigitalConsumptionHistory
	where StreamingDate >= @AsOfDate and StreamingDate < DATEADD(mm, 1, @AsOfDate)

	-- Need streaming information for three different combinations
	--1. Subsequent Month
	--2. LTD
	--3. Last 12 Month before the last order

	-- Metrics
	-- Flag Streamed, Total Streamed Mins, Total Actions, Number of Lectures and Number of Courses

	
		select CustomerID
		,AsOfDate
		,AsOfYear
		,AsOfMonth
		,AsOfMnthYr
		,sum(TotalActions) TotalActions
		,sum(StreamedMins) StreamedMins
		,sum(CoursesStreamed) CoursesStreamed
		,sum(LecturesStreamed) LecturesStreamed
		,1 as FlagStreamed
		/* For DVD */
		,sum(case when FormatPurchased = 'DVD' then TotalActions else 0 end) TotalActions_DVD
		,sum(case when FormatPurchased = 'DVD' then StreamedMins else 0 end) StreamedMins_DVD
		,sum(case when FormatPurchased = 'DVD' then Coursesstreamed else 0 end) CoursesStreamed_DVD
		,sum(case when FormatPurchased = 'DVD' then LecturesStreamed else 0 end) LecturesStreamed_DVD
		/* For CD */
		,sum(case when FormatPurchased = 'CD' then TotalActions else 0 end) TotalActions_CD
		,sum(case when FormatPurchased = 'CD' then StreamedMins else 0 end) StreamedMins_CD
		,sum(case when FormatPurchased = 'CD' then Coursesstreamed else 0 end) CoursesStreamed_CD
		,sum(case when FormatPurchased = 'CD' then LecturesStreamed else 0 end) LecturesStreamed_CD
		/* For DownloadV */
		,sum(case when FormatPurchased = 'DownloadV' then TotalActions else 0 end) TotalActions_DownloadV
		,sum(case when FormatPurchased = 'DownloadV' then StreamedMins else 0 end) StreamedMins_DownloadV
		,sum(case when FormatPurchased = 'DownloadV' then Coursesstreamed else 0 end) CoursesStreamed_DownloadV
		,sum(case when FormatPurchased = 'DownloadV' then LecturesStreamed else 0 end) LecturesStreamed_DownloadV
		/* For DownloadA */
		,sum(case when FormatPurchased = 'DownloadA' then TotalActions else 0 end) TotalActions_DownloadA
		,sum(case when FormatPurchased = 'DownloadA' then StreamedMins else 0 end) StreamedMins_DownloadA
		,sum(case when FormatPurchased = 'DownloadA' then Coursesstreamed else 0 end) CoursesStreamed_DownloadA
		,sum(case when FormatPurchased = 'DownloadA' then LecturesStreamed else 0 end) LecturesStreamed_DownloadA
	into #conformatSmry
	from (select CustomerID
				,cast(DATEADD(month, DATEDIFF(month, 0, StreamingDate), 0) as date) AsOfDate
				,year(StreamingDate) AsOfYear
				,month(StreamingDate) AsOfMonth
				,replace(FormatPurchased,' ','') FormatPurchased
				,convert(varchar,year(StreamingDate)) + convert(varchar,month(StreamingDate)) AsOfMnthYr
				,sum(TotalActions) TotalActions
				,convert(numeric(18,2),sum(StreamSeconds/60)) StreamedMins
				,count(distinct CourseID) CoursesStreamed
				,count(distinct convert(varchar,CourseID) + convert(varchar,Lecturenumber)) LecturesStreamed
				,1 as FlagStreamed
			from #consumption
			where StreamSeconds > 0
			and Action = 'Stream'
			group by CustomerID
				,cast(DATEADD(month, DATEDIFF(month, 0, StreamingDate), 0) as date)
				,year(StreamingDate)
				,month(StreamingDate)
				,convert(varchar,year(StreamingDate)) + convert(varchar,month(StreamingDate))
				,replace(FormatPurchased,' ',''))Strm
	group by CustomerID
		,AsOfDate
		,AsOfYear
		,AsOfMonth
		,AsOfMnthYr
	


		select CustomerID
		,AsOfDate
		,AsOfYear
		,AsOfMonth
		,AsOfMnthYr
		,sum(TotalActionsDnld) TotalActionsDnld
		,sum(CoursesDnld) CoursesDnld
		,sum(LecturesDnld) LecturesDnld
		,1 as FlagDnld
		/* For DownloadV */
		,sum(case when FormatPurchased = 'DownloadV' then TotalActionsDnld else 0 end) TotalActionsDnld_DownloadV
		,sum(case when FormatPurchased = 'DownloadV' then CoursesDnld else 0 end) CoursesDnld_DownloadV
		,sum(case when FormatPurchased = 'DownloadV' then LecturesDnld else 0 end) LecturesDnld_DownloadV
		/* For DownloadA */
		,sum(case when FormatPurchased = 'DownloadA' then TotalActionsDnld else 0 end) TotalActionsDnld_DownloadA
		,sum(case when FormatPurchased = 'DownloadA' then CoursesDnld else 0 end) CoursesDnld_DownloadA
		,sum(case when FormatPurchased = 'DownloadA' then LecturesDnld else 0 end) LecturesDnld_DownloadA
	into #Condlsmry
	from (
	select CustomerID
		,cast(DATEADD(month, DATEDIFF(month, 0, StreamingDate), 0) as date) AsOfDate
		,year(StreamingDate) AsOfYear
		,month(StreamingDate) AsOfMonth
		,replace(FormatPurchased,' ','') FormatPurchased
		,convert(varchar,year(StreamingDate)) + convert(varchar,month(StreamingDate)) AsOfMnthYr
		,sum(TotalActions) TotalActionsDnld
		,count(distinct CourseID) CoursesDnld
		,count(distinct convert(varchar,CourseID) + convert(varchar,Lecturenumber)) LecturesDnld
		,1 as FlagDnld
	from #consumption
	where action = 'Download'
	group by CustomerID
		,cast(DATEADD(month, DATEDIFF(month, 0, StreamingDate), 0) as date)
		,year(StreamingDate)
		,month(StreamingDate)
		,convert(varchar,year(StreamingDate)) + convert(varchar,month(StreamingDate))
		,replace(FormatPurchased,' ',''))Fnl
	group by CustomerID
		,AsOfDate
		,AsOfYear
		,AsOfMonth
		,AsOfMnthYr


 --   truncate table Staging.TGC_Consumption_MonthlySmryTEMP
	if object_id('Staging.TGC_Consumption_MonthlySmryTEMP') is not null drop table Staging.TGC_Consumption_MonthlySmryTEMP

	-- Get information for subsequent month
	select isnull(a.CustomerID, b.customerid) CustomerID
		,isnull(a.AsOfDate, b.AsOfDate) AsOfDate
		,isnull(a.AsOfYear, b.AsOfYear) AsOfYear
		,isnull(a.AsOfMonth, b.AsOfMonth) AsOfMonth
		,isnull(a.AsOfMnthYr, b.AsOfMnthYr) AsOfMnthYr
		,isnull(a.TotalActions, 0) TotalActions
		,isnull(a.StreamedMins, 0) StreamedMins
		,isnull(a.CoursesStreamed, 0) CoursesStreamed
		,isnull(a.LecturesStreamed, 0) LecturesStreamed
		,isnull(a.FlagStreamed, 0) FlagStreamed
		/* For DVD */
		,isnull(a.TotalActions_DVD, 0) TotalActions_DVD
		,isnull(a.StreamedMins_DVD, 0) StreamedMins_DVD
		,isnull(a.CoursesStreamed_DVD, 0) CoursesStreamed_DVD
		,isnull(a.LecturesStreamed_DVD, 0) LecturesStreamed_DVD
		,case when a.StreamedMins_DVD > 0 then 1 else 0 end as FlagStreamed_DVD
		/* For CD */
		,isnull(a.TotalActions_CD, 0) TotalActions_CD
		,isnull(a.StreamedMins_CD, 0) StreamedMins_CD
		,isnull(a.CoursesStreamed_CD, 0) CoursesStreamed_CD
		,isnull(a.LecturesStreamed_CD, 0) LecturesStreamed_CD
		,case when a.StreamedMins_CD > 0 then 1 else 0 end as FlagStreamed_CD
		/* For DownloadV */
		,isnull(a.TotalActions_DownloadV, 0) TotalActions_DownloadV
		,isnull(a.StreamedMins_DownloadV, 0) StreamedMins_DownloadV
		,isnull(a.CoursesStreamed_DownloadV, 0) CoursesStreamed_DownloadV
		,isnull(a.LecturesStreamed_DownloadV, 0) LecturesStreamed_DownloadV
		,case when a.StreamedMins_DownloadV > 0 then 1 else 0 end as FlagStreamed_DownloadV
		/* For DownloadA */
		,isnull(a.TotalActions_DownloadA, 0) TotalActions_DownloadA
		,isnull(a.StreamedMins_DownloadA, 0) StreamedMins_DownloadA
		,isnull(a.CoursesStreamed_DownloadA, 0) CoursesStreamed_DownloadA
		,isnull(a.LecturesStreamed_DownloadA, 0) LecturesStreamed_DownloadA
		,case when a.StreamedMins_DownloadA > 0 then 1 else 0 end as FlagStreamed_DownloadA
		,isnull(b.CoursesDnld, 0) CoursesDnld
		,isnull(b.CoursesDnld_DownloadA, 0) CoursesDnld_DownloadA
		,case when b.CoursesDnld_DownloadA > 0 then 1 else 0 end as FlagDnld_DownloadA
		,isnull(b.CoursesDnld_DownloadV, 0) CoursesDnld_DownloadV
		,case when b.CoursesDnld_DownloadV > 0 then 1 else 0 end as FlagDnld_DownloadV
		,isnull(b.FlagDnld, 0) FlagDnld
	into Staging.TGC_Consumption_MonthlySmryTEMP
	from #conformatSmry a
	full outer join #Condlsmry b on a.CustomerID = b.CustomerID
							and a.asofdate = b.asofdate
							

		
	-- delete if AsOfDate is already in the table 
	delete a
	-- select a.*
	from Marketing.TGC_Consumption_MonthlySmry a join
		(select distinct AsOfDate
		from Staging.TGC_Consumption_MonthlySmryTEMP)b on a.AsofDate = b.AsOfDate

	--insert into Marketing.TGC_Consumption_MonthlySmry
	insert into Marketing.TGC_Consumption_MonthlySmry
	select * 
	from Staging.TGC_Consumption_MonthlySmryTEMP


end
GO
