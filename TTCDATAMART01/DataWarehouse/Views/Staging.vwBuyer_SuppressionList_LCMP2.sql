SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Staging].[vwBuyer_SuppressionList_LCMP2]
AS

select a.AcquisitionWeek, a.customerID, b.FMPullDate, b.NewSeg, b.Name, b.a12mf, 
	b.EmailAddress
from rfm..WPTest_Random2013 a join
	Marketing.CampaignCustomerSignature b on a.CustomerID = b.CustomerID
where a.AcquisitionWeek >= dateadd(month,-6,getdate())--'6/3/2013'
--and b.FlagEmail = 1
and b.NewSeg > 2



GO
