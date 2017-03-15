SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Staging].[vwDoNOTEmailCustomers]
AS
	
select Emailaddress
from DataWarehouse.Marketing.CampaignCustomerSignature
where FlagEmailPref = 0
and EmailAddress like '%@%'	

GO
