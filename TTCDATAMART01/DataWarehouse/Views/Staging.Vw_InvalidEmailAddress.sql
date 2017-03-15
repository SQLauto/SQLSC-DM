SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [Staging].[Vw_InvalidEmailAddress]
AS
    
select distinct CustomerID, 
	EmailAddress, 
	FlagEmailPref,
	GETDATE() ReportDate
from DataWarehouse.Marketing.CampaignCustomerSignature
where FlagEmailPref = 1
and EmailAddress not like '%@%'
and isnull(EmailAddress,'') <> ''



GO
