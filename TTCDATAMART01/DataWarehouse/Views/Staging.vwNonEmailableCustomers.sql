SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Staging].[vwNonEmailableCustomers]
AS
	
	select CustomerID, EmailAddress, 
			FlagEmail, FlagEmailPref, 
			FlagValidEmail, FMPullDate as PullDate
	from DataWarehouse.Marketing.CampaignCustomerSignature
	where FlagEmail = 0

GO
