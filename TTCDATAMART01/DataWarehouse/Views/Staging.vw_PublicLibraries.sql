SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [Staging].[vw_PublicLibraries]
AS
			
						
select CustomerID, 
	FirstName, 
	LastName,	
	EmailAddress, 
	FlagEmail,
	Phone, 
	Phone2, 
	CompanyName,
	Address1, 
	Address2, 
	Address3, 
	City, 
	State, 
	PostalCode, 
	CountryCode,
	FlagMail, 
	CustomerSegment,
	case when Frequency = 'F2' then 'Multi'
		when Frequency = 'F1' then 'Single'
		else 'None'
	end as Frequency,
	CustomerSegmentFnl,
	FMPullDate
from DataWarehouse.Marketing.CampaignCustomerSignature	
where CountryCode = 'US'	
and PublicLibrary = 1	
						


GO
