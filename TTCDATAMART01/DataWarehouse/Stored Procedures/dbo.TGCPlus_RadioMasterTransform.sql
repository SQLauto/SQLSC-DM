SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[TGCPlus_RadioMasterTransform]


AS
begin

-- To transform Radio Master from spreadsheet to DM
-- Preethi Ramanujam 



	truncate table  [Staging].[TempTGCPlus_RadioMasterTrnsfrm]

	declare @NumSpot1 int = 1,
		@NumSpot2 int = 2,
		@RunSpotCol1 varchar(40),
		@RunSpotCol2 varchar(40),
		@Qry varchar(max)


	WHILE @NumSpot1 <= 10
	BEGIN  
	
		select @RunSpotCol1 = 'RunDateSpot' + convert(varchar,@NumSpot1),
			@RunSpotCol2 = case when @NumSpot2 = 11 then 'null'	
								else 'dateadd(day,-1,RunDateSpot' + convert(varchar,@NumSpot2) + ')'
								end

		select @RunSpotCol1, @RunSpotCol2
 
		set @Qry = 'insert into Staging.TempTGCPlus_RadioMasterTrnsfrm
				Select null as OfferIdUnq
				,OfferID 
				,OfferCodeDescription 
				,Program 
				,Offer 
				,Course 
				,Creative 
				,LandingPageTemplate 
				,NumSpots as NumberOfSpots 
				,' + convert(varchar,@NumSpot1) + ' as SpotNumber
				,(case when RunDateSpot1 is null then 0 else 1 end +
				case when RunDateSpot2 is null then 0 else 1 end +
				case when RunDateSpot3 is null then 0 else 1 end +
				case when RunDateSpot4 is null then 0 else 1 end +
				case when RunDateSpot5 is null then 0 else 1 end +
				case when RunDateSpot6 is null then 0 else 1 end +
				case when RunDateSpot7 is null then 0 else 1 end +
				case when RunDateSpot8 is null then 0 else 1 end +
				case when RunDateSpot9 is null then 0 else 1 end +
				case when RunDateSpot10 is null then 0 else 1 end) as TotalPaidSpots
				,' + @RunSpotCol1 + ' as RunStartDate 
				,' + @RunSpotCol2 + ' as RunStopDate
				,SourceCode1 as SourceCodeMain 
				,SourceCode2 as SourceCodeTGCRedirect
				,convert(int,0) as FlagTest
				,staging.GetMonday(' + @RunSpotCol1 + ') as StartWeek
				,year(' + @RunSpotCol1 + ') as StartYear
				,month(' + @RunSpotCol1 + ') as StartMonth
				,ExpirationDate
				,FlagComplete
				,AgencyOrDirectBuy 
				,ProgramAbbreviation 
				,URLAdvertised 
				,AdvertisementType
				,TestOrRenewal
				,SpotType 
				,SpotLength 
				,SpotsPerEpisode 
				,ProgramCategoryOrFormat 
				,CostPerEpisodeOrSOV 
				,AvgEpisodeImpressions 
				,(AvgEpisodeImpressions * NumSpots) TotalImpressionsForOfferID
				,TotalCost as TotalCostForOfferID
				,Convert(int,0) as  GA_PageView_SrcMain
				,Convert(int,0) as  GA_Sessions_SrcMain
				,Convert(date,null) as MinIntlSubDate_SrcMain
				,Convert(date,null) as MaxIntlSubDate_SrcMain
				,Convert(int,0) as IntlRegistrations_SrcMain
				,Convert(int,0) as IntlSubscribers_SrcMain
				,Convert(int,0) as IntlMonthlySubs_SrcMain
				,Convert(int,0) as IntlYearlySubs_SrcMain

				,Convert(int,0) as IntlMonthlyActvs_SrcMain
				,Convert(int,0) as IntlYearlyActvs_SrcMain
				,Convert(int,0) as IntlMonthlyCancls_SrcMain
				,Convert(int,0) as IntlYearlyCancls_SrcMain
				,Convert(int,0) as IntlMonthlyPaid_SrcMain
				,Convert(int,0) as IntlYearlyPaid_SrcMain

				,Convert(int,0) as  GA_PageView_SrcTGCRdrct
				,Convert(int,0) as  GA_Sessions_SrcTGCRdrct
				,convert(date,null) as MinIntlSubDate_SrcTGCRdrct
				,Convert(date,null) as MaxIntlSubDate_SrcTGCRdrct 
				,Convert(int,0) as IntlRegistrations_SrcTGCRdrct
				,Convert(int,0) as IntlSubscribers_SrcTGCRdrct
				,Convert(int,0) as IntlMonthlySubs_SrcTGCRdrct
				,Convert(int,0) as IntlYearlySubs_SrcTGCRdrct

				,Convert(int,0) as IntlMonthlyActvs_SrcTGCRdrct
				,Convert(int,0) as IntlYearlyActvs_SrcTGCRdrct
				,Convert(int,0) as IntlMonthlyCancls_SrcTGCRdrct
				,Convert(int,0) as IntlYearlyCancls_SrcTGCRdrct
				,Convert(int,0) as IntlMonthlyPaid_SrcTGCRdrct
				,Convert(int,0) as IntlYearlyPaid_SrcTGCRdrct
			from [Staging].[TempTGCPlus_RadioMaster]
			where ' + @RunSpotCol1 + ' is not null
			union
			select null as OfferIdUnq
				,OfferID 
				,OfferCodeDescription 
				,Program 
				,Offer 
				,Course 
				,Creative 
				,LandingPageTemplate 
				,NumSpots as NumberOfSpots 
				,' + convert(varchar,@NumSpot1) + ' as SpotNumber
				,(case when RunDateSpot1 is null then 0 else 1 end +
				case when RunDateSpot2 is null then 0 else 1 end +
				case when RunDateSpot3 is null then 0 else 1 end +
				case when RunDateSpot4 is null then 0 else 1 end +
				case when RunDateSpot5 is null then 0 else 1 end +
				case when RunDateSpot6 is null then 0 else 1 end +
				case when RunDateSpot7 is null then 0 else 1 end +
				case when RunDateSpot8 is null then 0 else 1 end +
				case when RunDateSpot9 is null then 0 else 1 end +
				case when RunDateSpot10 is null then 0 else 1 end) as TotalPaidSpots
				,' + @RunSpotCol1 + ' as RunStartDate 
				,' + @RunSpotCol2 + ' as RunStopDate
				,SourceCode3 as SourceCodeMain 
				,SourceCode4 as SourceCodeTGCRedirect
				,convert(int,1) as FlagTest
				,staging.GetMonday(' + @RunSpotCol1 + ') as StartWeek
				,year(' + @RunSpotCol1 + ') as StartYear
				,month(' + @RunSpotCol1 + ') as StartMonth
				,ExpirationDate
				,FlagComplete
				,AgencyOrDirectBuy 
				,ProgramAbbreviation 
				,URLAdvertised 
				,AdvertisementType
				,TestOrRenewal
				,SpotType 
				,SpotLength 
				,SpotsPerEpisode 
				,ProgramCategoryOrFormat 
				,CostPerEpisodeOrSOV 
				,AvgEpisodeImpressions 
				,(AvgEpisodeImpressions * NumSpots) TotalImpressionsForOfferID
				,TotalCost as TotalCostForOfferID
				,Convert(int,0) as  GA_PageView_SrcMain
				,Convert(int,0) as  GA_Sessions_SrcMain
				,Convert(date,null) as MinIntlSubDate_SrcMain
				,Convert(date,null) as MaxIntlSubDate_SrcMain
				,Convert(int,0) as IntlRegistrations_SrcMain
				,Convert(int,0) as IntlSubscribers_SrcMain
				,Convert(int,0) as IntlMonthlySubs_SrcMain
				,Convert(int,0) as IntlYearlySubs_SrcMain

				,Convert(int,0) as IntlMonthlyActvs_SrcMain
				,Convert(int,0) as IntlYearlyActvs_SrcMain
				,Convert(int,0) as IntlMonthlyCancls_SrcMain
				,Convert(int,0) as IntlYearlyCancls_SrcMain
				,Convert(int,0) as IntlMonthlyPaid_SrcMain
				,Convert(int,0) as IntlYearlyPaid_SrcMain

				,Convert(int,0) as  GA_PageView_SrcTGCRdrct
				,Convert(int,0) as  GA_Sessions_SrcTGCRdrct
				,convert(date,null) as MinIntlSubDate_SrcTGCRdrct
				,Convert(date,null) as MaxIntlSubDate_SrcTGCRdrct 
				,Convert(int,0) as IntlRegistrations_SrcTGCRdrct
				,Convert(int,0) as IntlSubscribers_SrcTGCRdrct
				,Convert(int,0) as IntlMonthlySubs_SrcTGCRdrct
				,Convert(int,0) as IntlYearlySubs_SrcTGCRdrct

				,Convert(int,0) as IntlMonthlyActvs_SrcTGCRdrct
				,Convert(int,0) as IntlYearlyActvs_SrcTGCRdrct
				,Convert(int,0) as IntlMonthlyCancls_SrcTGCRdrct
				,Convert(int,0) as IntlYearlyCancls_SrcTGCRdrct
				,Convert(int,0) as IntlMonthlyPaid_SrcTGCRdrct
				,Convert(int,0) as IntlYearlyPaid_SrcTGCRdrct
			from [Staging].[TempTGCPlus_RadioMaster]
			where ' + @RunSpotCol1 + ' is not null
			and SourceCode3 is not null'
		 --   BREAK;  
		 print @Qry
		 exec (@Qry)

	 
		SET @NumSpot1 = @NumSpot1 + 1
		SET @NumSpot2 = @NumSpot2 + 1

	END  


	update Staging.TempTGCPlus_RadioMasterTrnsfrm
	set offeridUnq = convert(varchar,offerid) + '_' + convert(varchar,RunStartdate,112) + '_' +  case when Flagtest = 1 then 'Test' else 'Control' end

	update a
	set a.GA_PageView_SrcMain = isnull(b.GA_PageView_SrcMain,0), 
		a.GA_Sessions_SrcMain = isnull(b.GA_Sessions_SrcMain,0),
		a.IntlRegistrations_SrcMain = isnull(b.IntlRegistrations_SrcMain,0)
	from Staging.TempTGCPlus_RadioMasterTrnsfrm a
		join (select a.OfferIDUnq,
					a.SourceCodeMain, 
					a.RunStartDate, 
					a.RunStopDate, 
					sum(b.GA_PageView) GA_PageView_SrcMain, 
					sum(b.GA_Sessions) GA_Sessions_SrcMain,
					sum(b.DM_Registrations) IntlRegistrations_SrcMain
				from Staging.TempTGCPlus_RadioMasterTrnsfrm a 
					left join Marketing.TGCPlus_Acqsn_Summary b on a.SourceCodeMain = b.IntlCampaign
																	and b.ActivityDate between a.RunStartDate and isnull(a.RunStopDate, cast(getdate() as date))
				where a.SourceCodeMain is not null
				group by a.OfferIDUnq,
					a.SourceCodeMain, 
					a.RunStartDate, 
					a.RunStopDate)b on a.OfferIDUnq = b.OfferIDUnq

	update a
	set a.GA_PageView_SrcTGCRdrct = isnull(b.GA_PageView_SrcTGCRdrct,0), 
		a.GA_Sessions_SrcTGCRdrct = isnull(b.GA_Sessions_SrcTGCRdrct,0),
		a.IntlRegistrations_SrcMain = isnull(b.IntlRegistrations_SrcMain,0)
	from Staging.TempTGCPlus_RadioMasterTrnsfrm a
		join (select a.OfferIDUnq,
					a.SourceCodeTGCRedirect,
					a.RunStartDate, 
					a.RunStopDate, 
					sum(b.GA_PageView) GA_PageView_SrcTGCRdrct, 
					sum(b.GA_Sessions) GA_Sessions_SrcTGCRdrct,
					sum(b.DM_Registrations) IntlRegistrations_SrcMain
				from Staging.TempTGCPlus_RadioMasterTrnsfrm a 
					left join Marketing.TGCPlus_Acqsn_Summary b on a.SourceCodeTGCRedirect = b.IntlCampaign
																	and b.ActivityDate between a.RunStartDate and isnull(a.RunStopDate, cast(getdate() as date))
				where a.SourceCodeTGCRedirect is not null
				group by a.OfferIDUnq,
					a.SourceCodeTGCRedirect, 
					a.RunStartDate, 
					a.RunStopDate)b on a.OfferIDUnq = b.OfferIDUnq

	select * from Staging.TempTGCPlus_RadioMasterTrnsfrm

	exec sp_help 'Staging.TempTGCPlus_RadioMasterTrnsfrm'

	update a
	set a.MinIntlSubDate_SrcMain = b.MinIntlSubDate_SrcMain,
		a.MaxIntlSubDate_SrcMain = b.MaxIntlSubDate_SrcMain,

		a.IntlSubscribers_SrcMain = isnull(b.IntlSubscribers_SrcMain,0),
		a.IntlMonthlySubs_SrcMain = isnull(b.IntlMonthlySubs_SrcMain,0),
		a.IntlYearlySubs_SrcMain = isnull(b.IntlYearlySubs_SrcMain,0),
		a.IntlMonthlyActvs_SrcMain = isnull(b.IntlMonthlyActvs_SrcMain,0),
		a.IntlYearlyActvs_SrcMain = isnull(b.IntlYearlyActvs_SrcMain,0),
		a.IntlMonthlyCancls_SrcMain = isnull(b.IntlMonthlyCancls_SrcMain,0),
		a.IntlYearlyCancls_SrcMain = isnull(b.IntlYearlyCancls_SrcMain,0),
		a.IntlMonthlyPaid_SrcMain = isnull(b.IntlMonthlyPaid_SrcMain,0),
		a.IntlYearlyPaid_SrcMain = isnull(b.IntlYearlyPaid_SrcMain,0)
	from Staging.TempTGCPlus_RadioMasterTrnsfrm a
	join (select a.OfferIDUnq,
				a.SourceCodeMain,
				a.RunStartDate, 
				a.RunStopDate, 
				min(b.IntlSubDate) MinIntlSubDate_SrcMain,
				max(b.IntlSubDate) MaxIntlSubDate_SrcMain,
				count(b.customerid) IntlSubscribers_SrcMain,
				sum(case when b.intlsubtype = 'Month' then 1 else 0 end) IntlMonthlySubs_SrcMain,
				sum(case when b.intlsubtype = 'Year' then 1 else 0 end) IntlYearlySubs_SrcMain,
				sum(case when b.intlsubtype = 'Month' and b.CustStatusFlag <> -1 then 1 else 0 end) as IntlMonthlyActvs_SrcMain,
				sum(case when b.intlsubtype = 'Year' and b.CustStatusFlag <> -1 then 1 else 0 end) as IntlYearlyActvs_SrcMain,
				sum(case when b.intlsubtype = 'Month' and b.CustStatusFlag = -1 then 1 else 0 end) as IntlMonthlyCancls_SrcMain,
				sum(case when b.intlsubtype = 'Year' and b.CustStatusFlag = -1 then 1 else 0 end) as IntlYearlyCancls_SrcMain,
				sum(case when b.intlsubtype = 'Month' and b.PaidFlag = 1 then 1 else 0 end) as IntlMonthlyPaid_SrcMain,
				sum(case when b.intlsubtype = 'Year' and b.PaidFlag = 1 then 1 else 0 end) as IntlYearlyPaid_SrcMain
		from Staging.TempTGCPlus_RadioMasterTrnsfrm a join
				Marketing.TGCPlus_CustomerSignature b on a.SourceCodeMain = b.IntlCampaignID 
																and b.IntlSubDate between a.RunStartDate and isnull(a.RunStopDate,cast(getdate() as date))
		group by a.OfferIDUnq,
				a.SourceCodeMain,
				a.RunStartDate, 
				a.RunStopDate)b on a.OfferIDUnq = b.OfferIDUnq



	update a
	set a.MinIntlSubDate_SrcTGCRdrct = b.MinIntlSubDate_SrcTGCRdrct,
		a.MaxIntlSubDate_SrcTGCRdrct = b.MaxIntlSubDate_SrcTGCRdrct,

		a.IntlSubscribers_SrcTGCRdrct = isnull(b.IntlSubscribers_SrcTGCRdrct,0),
		a.IntlMonthlySubs_SrcTGCRdrct = isnull(b.IntlMonthlySubs_SrcTGCRdrct,0),
		a.IntlYearlySubs_SrcTGCRdrct = isnull(b.IntlYearlySubs_SrcTGCRdrct,0),
		a.IntlMonthlyActvs_SrcTGCRdrct = isnull(b.IntlMonthlyActvs_SrcTGCRdrct,0),
		a.IntlYearlyActvs_SrcTGCRdrct = isnull(b.IntlYearlyActvs_SrcTGCRdrct,0),
		a.IntlMonthlyCancls_SrcTGCRdrct = isnull(b.IntlMonthlyCancls_SrcTGCRdrct,0),
		a.IntlYearlyCancls_SrcTGCRdrct = isnull(b.IntlYearlyCancls_SrcTGCRdrct,0),
		a.IntlMonthlyPaid_SrcTGCRdrct = isnull(b.IntlMonthlyPaid_SrcTGCRdrct,0),
		a.IntlYearlyPaid_SrcTGCRdrct = isnull(b.IntlYearlyPaid_SrcTGCRdrct,0)
	from Staging.TempTGCPlus_RadioMasterTrnsfrm a
	join (select a.OfferIDUnq,
				a.SourceCodeTGCRedirect,
				a.RunStartDate, 
				a.RunStopDate, 
				min(b.IntlSubDate) MinIntlSubDate_SrcTGCRdrct,
				max(b.IntlSubDate) MaxIntlSubDate_SrcTGCRdrct,
				count(b.customerid) IntlSubscribers_SrcTGCRdrct,
				sum(case when b.intlsubtype = 'Month' then 1 else 0 end) IntlMonthlySubs_SrcTGCRdrct,
				sum(case when b.intlsubtype = 'Year' then 1 else 0 end) IntlYearlySubs_SrcTGCRdrct,
				sum(case when b.intlsubtype = 'Month' and b.CustStatusFlag <> -1 then 1 else 0 end) as IntlMonthlyActvs_SrcTGCRdrct,
				sum(case when b.intlsubtype = 'Year' and b.CustStatusFlag <> -1 then 1 else 0 end) as IntlYearlyActvs_SrcTGCRdrct,
				sum(case when b.intlsubtype = 'Month' and b.CustStatusFlag = -1 then 1 else 0 end) as IntlMonthlyCancls_SrcTGCRdrct,
				sum(case when b.intlsubtype = 'Year' and b.CustStatusFlag = -1 then 1 else 0 end) as IntlYearlyCancls_SrcTGCRdrct,
				sum(case when b.intlsubtype = 'Month' and b.PaidFlag = 1 then 1 else 0 end) as IntlMonthlyPaid_SrcTGCRdrct,
				sum(case when b.intlsubtype = 'Year' and b.PaidFlag = 1 then 1 else 0 end) as IntlYearlyPaid_SrcTGCRdrct
		from Staging.TempTGCPlus_RadioMasterTrnsfrm a join
				Marketing.TGCPlus_CustomerSignature b on a.SourceCodeTGCRedirect = b.IntlCampaignID 
																and b.IntlSubDate between a.RunStartDate and isnull(a.RunStopDate,cast(getdate() as date))
		group by a.OfferIDUnq,
				a.SourceCodeTGCRedirect,
				a.RunStartDate, 
				a.RunStopDate)b on a.OfferIDUnq = b.OfferIDUnq

	if object_id('marketing.TGCPlus_RadioMasterTrnsfrm')  is not null 
	drop table marketing.TGCPlus_RadioMasterTrnsfrm
	
	select *, getdate() as DMlastupdated
	into marketing.TGCPlus_RadioMasterTrnsfrm
	from Staging.TempTGCPlus_RadioMasterTrnsfrm

	truncate table Staging.TempTGCPlus_RadioMasterTrnsfrm

end
 

GO
