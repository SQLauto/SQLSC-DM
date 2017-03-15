SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[AggregateDynamicForDomo]
	@AsOfDate datetime
AS
--- Proc Name:    [AggregateDynamicForDomo]
--- Purpose:      To capture aggregated summary table for House spending information for DOMO as it cannot directly
---					connect to cube.
--- Input Parameters: None
---               
--- Updates:
--- Name                    Date         Comments
--- Preethi Ramanujam		3/10/2014    New


BEGIN
	set nocount on

    if DAY(@AsOfDate) <> 1 
		select @AsOfDate = CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(@AsOfDate)-1),@AsOfDate),101) 

    -- drop working table if exist
    if object_id('Staging.DOMO_HouseSpendSummary_Temp') is not null drop table Staging.DOMO_HouseSpendSummary_Temp

	-- Create summary table for the given @AsOfDate
	select AsOfDate, AsOfMonth, AsOfYear, NewSeg, Name, A12MF, 
	case when ActiveOrSwamp = '1' then 'Active'
		when ActiveOrSwamp = '0' then 'Swamp'
		else 'None'
	end as CustomerSegment, 
	case when Frequency = 'F1' then 'Single'
		when Frequency = 'F2' then 'Multi'
		else 'None'
	end as Frequency, 
	R3FormatMediaPref, R3SubjectPref, R3OrderSource, 
	FlagEmailPref, FlagEmailValid, FlagEmailable, FlagMailPref, 
	case when CountryCode like '%US%' then 'US'
		when CountryCode in ('CA','GB','AU') then CountryCode
		else 'ROW'
	end as CountryCode, 
	sum(PurchAmountSubsqMth) SalesSubsqMnth, 
	sum(PurchasesSubsqMth) OrdersSubsqMnth, 
	sum(UnitsPurchSubsqMth) UnitsSubsqMnth,
	sum(PartsPurchSubsqMth) PartsSubsqMnth, 
	sum(HoursPurchSubsqMth) HoursSubsqMnt,
	count(CustomerID) CustCount
	into Staging.DOMO_HouseSpendSummary_Temp
	from Marketing.DMCustomerDynamic
	where AsOfDate = @AsOfDate
	group by AsOfDate, AsOfMonth, AsOfYear, NewSeg, Name, A12MF, 
	case when ActiveOrSwamp = '1' then 'Active'
		when ActiveOrSwamp = '0' then 'Swamp'
		else 'None'
	end, 
	case when Frequency = 'F1' then 'Single'
		when Frequency = 'F2' then 'Multi'
		else 'None'
	end, 
	R3FormatMediaPref, R3SubjectPref, R3OrderSource, 
	FlagEmailPref, FlagEmailValid, FlagEmailable, FlagMailPref, 
	case when CountryCode like '%US%' then 'US'
		when CountryCode in ('CA','GB','AU') then CountryCode
		else 'ROW'
	end

    -- Update the main table

	-- Drop data if already exist in the main table for the given @AsOfDate and load new data
	delete from Marketing.DOMO_HouseSpendSummary
	where asofdate = @AsOfDate
	
	insert into Marketing.DOMO_HouseSpendSummary
    select * from Staging.DOMO_HouseSpendSummary_Temp 
	


    -- Drop all the temp tables
    if object_id('Staging.DOMO_HouseSpendSummary_Temp') is not null drop table Staging.DOMO_HouseSpendSummary_Temp
    
END
GO
