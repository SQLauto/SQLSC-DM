SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create procedure [Staging].[TGCPlus_LoadRFMData_AllBKPDEL]
	@LoadType varchar(50) = 'Load'
	,@AsOfDate datetime = null

as
	--declare 
 --   	@a12mF_EndDate datetime,
 --   	@a12mF_StartDate datetime, 
 --   	@DSStartDate datetime, 
 --   	@DSEndDate datetime, 
	--	@DSDays int, 
	--    @MaxDays int
begin

	if @LoadType = 'Update'
	begin

	if @AsOfDate is null 
		select @AsOfDate = max(AsofDate)
		from marketing.TGCPlus_CustomerSignature_Snapshot
	else
		select @AsOfDate = DATEADD(month, DATEDIFF(month, 0, @AsOfDate), 0)

		select @AsOfDate

	PRINT 'Loading RFM for ' + convert(varchar, @Asofdate, 101)

	Select 	a.AsofDate
			,a.CustomerID
			,a.IntlSubDate
			,a.LTDPaidAmt 
			,max(b.tstamp) DateLastPlayed
			,sum(b.StreamedMins) StreamedMinutes
			,DATEDIFF(day, max(b.TSTAMP),a.AsoFDate) DaysSinceLastStream
			,DATEDIFF(day, a.IntlSubDate, a.AsofDate) Tenure
			,(sum(b.StreamedMins)/DATEDIFF(day, a.IntlSubDate, a.AsofDate)) MinutesPerDay
			,convert(int, null) Recency_Decile
			,convert(int, null) Frequency_Decile
			,convert(int, null) Monetary_Decile
	into #TGCPlus_RFMBaseUpdate
	from marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
		left join Marketing.tgcplus_Videoevents_smry b on a.uuid = b.UUID
												and b.TSTAMP < a.AsofDate
	where a.CustStatusFlag = 1 
	and a.PaidFlag = 1-- and b.CustStatusFlag = 1
	--and a.CustomerID in (2130333) --,2998034,3617941,2528907)
	and a.AsofDate = @AsOfDate
	group by a.AsofDate
	,a.CustomerID
	,a.IntlSubDate
	,a.LTDPaidAmt

	update #TGCPlus_RFMBaseUpdate
	set Recency_Decile = 1,
		Frequency_Decile = 1
	where DaysSinceLastStream is null

	
	update a
	set a.Recency_Decile = b.Recency_Decile,
		a.Frequency_Decile = b.Frequency_Decile
	from #TGCPlus_RFMBaseUpdate a
	join (Select AsofDate
			,CustomerID
			,DaysSinceLastStream
			,ntile(10) over (partition by Asofdate order by DaysSinceLastStream desc)+1 as Recency_Decile
			,MinutesPerDay
			,ntile(10) over (partition by Asofdate order by MinutesPerDay)+1 as Frequency_Decile
		from #TGCPlus_RFMBaseUpdate 
		where DaysSinceLastStream >= 0)b on a.AsofDate = b.AsofDate
									and a.CustomerID = b.CustomerID

	update a
	set a.Monetary_Decile = b.Monetary_Decile
	from #TGCPlus_RFMBaseUpdate a
	join (Select AsofDate
			,CustomerID
			,LTDPaidAmt
			,ntile(10) over (partition by Asofdate order by LTDPaidAmt) as Monetary_Decile
		from #TGCPlus_RFMBaseUpdate)b on a.AsofDate = b.AsofDate
									and a.CustomerID = b.CustomerID

	Print 'Deleting data that already exists'
	delete a
	from Marketing.TGCPlus_RFM a 
	join #TGCPlus_RFMBaseUpdate b on a.AsofDate = b.AsofDate

	Print 'Loading data into final table'
	insert into Marketing.TGCPlus_RFM
	select *
	from #TGCPlus_RFMBaseUpdate

	end

	else 
	begin

		Select 	a.AsofDate
			,a.CustomerID
			,a.IntlSubDate
			,a.LTDPaidAmt 
			,max(b.tstamp) DateLastPlayed
			,sum(b.StreamedMins) StreamedMinutes
			,DATEDIFF(day, max(b.TSTAMP),a.AsoFDate) DaysSinceLastStream
			,DATEDIFF(day, a.IntlSubDate, a.AsofDate) Tenure
			,(sum(b.StreamedMins)/DATEDIFF(day, a.IntlSubDate, a.AsofDate)) MinutesPerDay
			,convert(int, null) Recency_Decile
			,convert(int, null) Frequency_Decile
			,convert(int, null) Monetary_Decile
	into #TGCPlus_RFMBase
	from marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
		left join Marketing.tgcplus_Videoevents_smry b on a.uuid = b.UUID
												and b.TSTAMP < a.AsofDate
	where a.CustStatusFlag = 1 
	and a.PaidFlag = 1-- and b.CustStatusFlag = 1
	--and a.CustomerID in (2130333) --,2998034,3617941,2528907)
	--and a.AsofDate >= '1/1/2017'
	group by a.AsofDate
	,a.CustomerID
	,a.IntlSubDate
	,a.LTDPaidAmt

	update #TGCPlus_RFMBase
	set Recency_Decile = 1,
		Frequency_Decile = 1
	where DaysSinceLastStream is null

	
	update a
	set a.Recency_Decile = b.Recency_Decile,
		a.Frequency_Decile = b.Frequency_Decile
	from #TGCPlus_RFMBase a
	join (Select AsofDate
			,CustomerID
			,DaysSinceLastStream
			,ntile(10) over (partition by Asofdate order by DaysSinceLastStream desc)+1 as Recency_Decile
			,StreamedMinutes
			,ntile(10) over (partition by Asofdate order by MinutesPerDay)+1 as Frequency_Decile
		from #TGCPlus_RFMBase 
		where DaysSinceLastStream >= 0)b on a.AsofDate = b.AsofDate
									and a.CustomerID = b.CustomerID

	
	update a
	set a.Monetary_Decile = b.Monetary_Decile
	from #TGCPlus_RFMBase a
	join (Select AsofDate
			,CustomerID
			,LTDPaidAmt
			,ntile(10) over (partition by Asofdate order by LTDPaidAmt) as Monetary_Decile
		from #TGCPlus_RFMBase )b on a.AsofDate = b.AsofDate
									and a.CustomerID = b.CustomerID


    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'TGCPlus_Acqsn_Summary_TEMPReg')
        DROP TABLE Marketing.TGCPlus_RFM
	
	select *
	into Marketing.TGCPlus_RFM
	from #TGCPlus_RFMBase

	
	end
    
end
GO
