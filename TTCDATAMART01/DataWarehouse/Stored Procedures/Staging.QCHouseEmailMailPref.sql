SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[QCHouseEmailMailPref] 
	@CourseID Int = 0
AS
	-- Preethi Ramanujam    3/13/2012 To QC FlagEmail and Mail preferences and flags
begin

-- check if this data is already in the table.
delete
from Marketing.DailyEmailMailFlagCheck 
where AsOfDate = (select distinct CONVERT(datetime, CONVERT(varchar,fmpulldate))
				from Marketing.CampaignCustomerSignature)


insert into Marketing.DailyEmailMailFlagCheck
select YEAR(FMPullDate) YearOf,
	MONTH(fmpulldate) MonthOf,
	DAY(FMPullDate) DayOf, 
	CONVERT(datetime, CONVERT(varchar,fmpulldate)) AsOfDate,
	CustomerSegment, Frequency, CustomerSegmentNew, 
	case when CountryCode IN ('US','CA','AU','GB') then Countrycode
		else 'Others'
	end CountryCode,
	FlagEmail, FlagEmailPref, FlagValidEmail,
	FlagMail, FlagValidRegionUS, 
	COUNT(CustomerID) CustCount	
from Marketing.CampaignCustomerSignature
group by YEAR(FMPullDate),
	MONTH(fmpulldate),
	DAY(FMPullDate),
	CONVERT(datetime, CONVERT(varchar,fmpulldate)),
	CustomerSegment, Frequency, CustomerSegmentNew, 
	case when CountryCode IN ('US','CA','AU','GB') then Countrycode
		else 'Others'
	end,
	FlagEmail, FlagEmailPref, FlagValidEmail,
	FlagMail, FlagValidRegionUS


end
GO
